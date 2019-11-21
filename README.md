# OpenEdx ECommerce Docker

## Prerequisite

- [Docker](https://docs.docker.com/install)
- `curl`
- `make`

## Getting started

The aim of the project is to build the OpenEdx E-Commerce service Docker image
and start playing with it locally. So let's play:

```bash
$ make bootstrap
```

This will download an archive of the openedx project sources (current `master`
branch state by default), build the docker image using downloaded sources,
compile assets and run database migrations.

After few minutes, the E-Commerce service should be built and configured. Now
it's time to run it:

```bash
$ make dev
```

The E-Commerce application should be up and running at:
[http://localhost:8000](http://localhost:8000), yeah!

To stop running services, use:

```bash
$ make stop
```

For more information about available commands, see:

```bash
$ make help
```

## Building a target release

To build a particular release, you have to set two environment variables:

- `EDX_EC_ARCHIVE_URL`: an URL pointing to a gzip tarball archive of the release sources
- `EDX_EC_DOCKER_TAG`: the tag of the Docker image to build

You may proceed as follows:

```bash
$ export EDX_EC_ARCHIVE_URL="https://github.com/edx/ecommerce/archive/open-release/ironwood.2.tar.gz"
$ export EDX_EC_DOCKER_TAG="open-release-ironwood.2"
```

Once defined in your shell, make sure that it is taken into account using the
Makefile's `info` target:

```bash
$ make info

.:: OPENEDX-ECOMMERCE-DOCKER ::.

== Active configuration ==

* EDX_EC_ARCHIVE_URL: https://github.com/edx/ecommerce/archive/open-release/ironwood.2.tar.gz
* EDX_EC_RELEASE_REF: open-release/ironwood.2
* EDX_EC_DOCKER_TAG : open-release-ironwood.2
```

As it may be tedious to define such environment variables, we've cooked a
helper for that. Take a look at the `bin/activate` script:

```
Usage: bin/activate [RELEASE_REF|ARCHIVE_URL]
```

This script accepts one single required argument that may be an edx/ecommerce
Git reference (tag or branch name from the official repository) or an URL
pointing to a gzip tarball archive of the ecommerce application sources.

This argument may be:

- `RELEASE_REF`: the release reference to build (always targeting the official repository), or,
- `ARCHIVE_URL`: the release sources archive URL (may target any repository)

Here some examples usage:

```
$ bin/activate master
$ bin/activate open-release/ironwood.2
$ bin/activate https://github.com/openfun/ecommerce/archive/fun/ecommerce-ol.tar.gz
```

The script output should look like the following, _i.e._ a list of environment
variables definition:

```
export EDX_EC_ARCHIVE_URL=https://github.com/edx/ecommerce/archive/open-release/ironwood.2.tar.gz
export EDX_EC_RELEASE_REF=open-release/ironwood.2
export EDX_EC_DOCKER_TAG=open-release-ironwood.2
```

You may want to copy/paste the activate script output to set your shell
environment or use the following one-liner using [Bash process
substitution](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html#Process-Substitution):

```
$ source <(bin/activate open-release/ironwood.2)
```

Now that your environment is properly set, you need to bootstrap the project
once again (see "Getting started" section). Note that by bootstrapping the
project, the content of local volumes (`data/`, `src/`i, ...) and databases
will be dropped using the `clean` Makefile target.

## License

The code in this repository is licensed under the GNU AGPL-3.0 terms unless
otherwise noted.

Please see [`LICENSE`](./LICENSE) for details.
