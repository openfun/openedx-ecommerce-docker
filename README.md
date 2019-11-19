# OpenEdx ECommerce Docker

## Prerequisite

- [Docker](https://docs.docker.com/install)
- `curl`
- `make`

## Getting started

The aim of the project is to build the OpenEdx E-Commerce service Docker image.
This could be achieved using the `build` make target:

```bash
$ make build
```

This will download an archive of the openedx project sources and build the
`edxec:latest` docker image using downloaded sources.

Note that you can remove downloaded sources using the `clean` make target:

```bash
$ make clean
```

## License

The code in this repository is licensed under the GNU AGPL-3.0 terms unless
otherwise noted.

Please see [`LICENSE`](./LICENSE) for details.
