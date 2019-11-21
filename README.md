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

## License

The code in this repository is licensed under the GNU AGPL-3.0 terms unless
otherwise noted.

Please see [`LICENSE`](./LICENSE) for details.
