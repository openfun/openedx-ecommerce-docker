# OpenEdx E-Commerce Docker

## Prerequisite

- [Docker](https://docs.docker.com/install)
- `curl`
- `make`

## Getting started

The aim of the project is to build the OpenEdx E-Commerce service Docker image
and start playing with it locally.

First, you need to choose a release/flavor of OpenEdx E-Commerce versions we
support. You can list them and get instructions about how to select/activate a
target release using the `bin/activate` script. An example output follows:

```bash
$ bin/activate
Select an available flavored release to activate:
[1] dogwood/3/fun (default)
[2] master/bare
Your choice: 1

# Copy/paste dogwood/3/fun environment:
export EDX_EC_RELEASE=dogwood.3
export FLAVOR=fun
export EDX_EC_ARCHIVE_URL=https://github.com/openfun/ecommerce/archive/dogwood.3.tar.gz
export EDX_EC_RELEASE_REF=dogwood.3-fun
export EDX_EC_DOCKER_TAG=dogwood.3-fun

# Or run the following command:
. bin/../releases/dogwood/3/fun/activate

# Check your environment with:
make info
```

Once your environment is set, start the full project by running:

```bash
$ make bootstrap
```

This will download an archive of the OpenEdx E-Commerce project sources
(current `master` branch state by default), build the docker image using
downloaded sources, compile assets and run database migrations.

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

## License

The code in this repository is licensed under the GNU AGPL-3.0 terms unless
otherwise noted.

Please see [`LICENSE`](./LICENSE) for details.
