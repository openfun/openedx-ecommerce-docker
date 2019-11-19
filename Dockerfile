# OpenEdx ECommerce

ARG DOCKER_UID=1000
ARG DOCKER_GID=1000

# E-Commerce release archive url to build our image with
ARG EDX_EC_ARCHIVE_URL=https://github.com/edx/ecommerce/archive/master.tar.gz

# ---- Base image to inherit from ----
FROM python:2.7-stretch as base


# ---- Release Download ----
FROM base as downloads

WORKDIR /downloads

# Install curl
RUN apt-get update && \
    apt-get install -y curl

# Download ecommerce release
ARG EDX_EC_ARCHIVE_URL
RUN curl -sLo ecommerce.tgz ${EDX_EC_ARCHIVE_URL} && \
    mkdir /downloads/ecommerce && \
    tar xzf ecommerce.tgz -C /downloads/ecommerce --strip-components=1

# ---- Front-end builder image ----
FROM node:10 as front-builder

USER node:node
WORKDIR /home/node

# Install node dependencies
COPY --from=downloads /downloads/ecommerce/package.json ./
RUN npm install

# Copy front-end sources
COPY --from=downloads --chown=node:node /downloads/ecommerce/ecommerce/static ./ecommerce/static

# Install bower dependencies
#
# Note that this should be done after copying front-end sources as the build
# target path is the "ecommerce/static" directory
COPY --from=downloads /downloads/ecommerce/bower.json /downloads/ecommerce/.bowerrc ./
RUN $(npm bin)/bower install

# Build the front-end
COPY --from=downloads /downloads/ecommerce/build.js .
RUN $(npm bin)/r.js -o build.js


# ---- Back-end builder image ----
FROM base as back-builder

WORKDIR /builder

# Install python dependencies
COPY --from=downloads /downloads/ecommerce/requirements ./
RUN mkdir /install && \
    pip install --prefix=/install -r production.txt

# ---- Core application image ----
FROM base as core

# Install gettext
RUN apt-get update && \
    apt-get install -y \
      gettext && \
    rm -rf /var/lib/apt/lists/*

# Copy installed python dependencies
COPY --from=back-builder /install /usr/local

# Copy runtime-required files
COPY --from=downloads /downloads/ecommerce /app

# Copy front-end build
COPY --from=front-builder /home/node/ecommerce/static /app/ecommerce/static

# Copy default entrypoint script
COPY ./docker/files/usr/local/bin/entrypoint /usr/local/bin/entrypoint

# Gunicorn
RUN mkdir -p /usr/local/etc/gunicorn
COPY docker/files/usr/local/etc/gunicorn/edxec.py /usr/local/etc/gunicorn/edxec.py

# Give the "root" group the same permissions as the "root" user on /etc/passwd
# to allow a user belonging to the root group to add new users; typically the
# docker user (see entrypoint).
RUN chmod g=u /etc/passwd

# Un-privileged user running the application
ARG DOCKER_UID
ARG DOCKER_GID
USER ${DOCKER_UID}:${DOCKER_GID}

# We wrap commands run in this container by the following entrypoint that
# creates a user on-the-fly with the container user ID (see USER) and root group
# ID.
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]


# ---- Production image ----
FROM core as production

WORKDIR /app/ecommerce

# The default command runs gunicorn WSGI server
CMD gunicorn -c /usr/local/etc/gunicorn/edxec.py wsgi:application
