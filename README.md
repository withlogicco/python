
# Python with LOGIC

An opinionated base Docker image used when doing [Python with LOGIC](https://withlogic.co/ref/python). Optimized for development, CI and production.

![uv](https://img.shields.io/badge/uv-0.8.14-lime) ![python](https://img.shields.io/badge/Python-3.13%20(default)%2C3.12%2C3.11%2C3.10-blue) ![variants](https://img.shields.io/badge/Variant-trixie%20(default)%2C%20bookworm-purple?label=Variants)

> [!TIP]
> 
> Need help with a Python project in your organizations? You are at the right place. We have been working with production Python deployments for years and we would love to help. Let's get in touch at [https://withlogic.co](https://withlogic.co/ref/python).

## Why

We built and published this opinionated Docker image, based on our workflow when doing Python with LOGIC. We prioritise DRY, considerate defaults and optimizing for speed and convenience across all steps in our workflow, from development to CI and deployments; preview or production. In particular this means:

- Python and virtual environments optimized for Docker deployments
- Optimized dependency management with uv
- Preconfigured volumes for development with Docker

## Usage

The simplest way to get started with this image is to use the `latest` tag and copy your source code in the current working directory:

```dockerfile
FROM ghcr.io/withlogicco/python

COPY ./ ./
```

For advanced usage scenarios, including using uv with efficient Docker image caching take a look 

## Tags

The `latest` tag ships with the most recent uv and Python versions on Debian Trixie:

```
ghcr.io/withlogicco/python
```

There are tags available to choose a specific supported Python versions and image variants:

- Python version: `ghcr.io/withlogicco/python:{python_version}`
- Image variant: `ghcr.io/withlogicco/python:{image_variant}`
- Python version and image variant: `ghcr.io/withlogicco/python:{python_version}-{image_variant}`

### Examples

- Python 3.13 on Trixie: `ghcr.io/withlogicco/python`
- Poetry 3.13 on Bookworm: `ghcr.io/withlogicco/python:bookworm`
- Poetry 3.12 on Trixie: `ghcr.io/withlogicco/python:3.12`
- Poetry 3.12 on Bookworm: `ghcr.io/withlogicco/python:3.12-bookworm`

## Advanced usage

### Start a new project with uv

To start a new Python project with uv, mount your current working directory in `/usr/src/app` and just run `uv init`:

```console
docker run -ti -v $PWD:/usr/src/app ghcr.io/withlogicco/python uv init
```

### Dependencies with uv

To manage your dependencies with uv, it's suggested to just copy your `pyproject.toml` and `uv.lock` files in your Docker image first for optimized Docker build layer caching (`uv sync` will run only when your dependencies change):

```dockerfile
FROM ghcr.io/withlogicco/python

COPY pyproject.toml uv.lock ./
RUN uv sync --no-install-project

COPY . .
```

> [!TIP]
> 
> Prefer to use `--no-install-project` with `uv sync`, to only install dependencies and not the current project, since the code is not available yet in that particular build step.

### Optimize builds with cache mounts

You can further optimize your Docker builds by taking advantage of Docker builder cache mounts. This means Docker can cache the `/root/.cache/uv` directory across builds, so that even when dependencies change and `uv sync` needs to run again, only the new dependencies will need to be downloaded from PyPI:

```dockerfile
FROM ghcr.io/withlogicco/python

COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --no-install-project
```

> [!IMPORTANT]
> 
> Docker build cache mounts will **NOT** work on GitHub Actions, as they are not part of Docker image cache, but the builder daemon's. To get this feature working you will need to run your Docker builds on a host managed by you, with GitHub Actions self-hosted runners.

### Reduce layers with build bind mounts

You can reduce layers of built Docker images, by mounting `pyproject.toml` and `uv.lock` in the Docker image just in time for `uv sync`, instead of copying them in an additional layer above:

```dockerfile
FROM ghcr.io/withlogicco/python

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    uv sync --no-install-project
```

### Persist new dependencies without rebuilding

When working on an actively developed project, new dependencies can be added as the project moves forward. To avoid requiring rebuilding the Docker image at that case, you can mount a volume in `/opt/uv/venv`.

The directory `/opt/uv/venv` has been configured as a volume in the image, which means that Docker volumes mounted there will be initialized with the data of the image. 

With Docker Compose the volume can be as simple as:

```yml
services:
  web:
    build: .
    volumes:
      - .:/usr/src/app
      - uv:/opt/uv/venv
```

> [!TIP]
> 
> This is especially useful when working in small teams that do not update dependencies at the same time often. Rebuilding the image with new dependencies, will not udpate the contents of an existing Docker volume.

## Supported software versions

### uv

Only the latest version of uv is included in each build.

### Python

A build will be provided for each Python version still under maintenance and support. The latest Python version acts as the default in each build.

You can check the currently supported Python versions at https://devguide.python.org/versions/.

### Variants (Linux distributions)

- Debian Trixie (default): `trixie`
- Debian Bookworm: `bookworm`

## License

This project is [MIT licensed](LICENSE).

---

<p align="center">
	<i>🦄 Built with <a href="https://withlogic.co/">LOGIC</a>. 🦄</i>
</p>
