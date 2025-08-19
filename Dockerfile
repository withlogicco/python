ARG PYTHON_VERSION=3.13
ARG VARIANT=bookworm
ARG UV_VERSION=0.8.12

FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

FROM python:${PYTHON_VERSION}-${VARIANT} AS base

COPY --from=uv /uv /uvx /usr/local/bin/

ARG UV_PROJECT_ENVIRONMENT=/opt/uv/venv

ENV PATH=${UV_PROJECT_ENVIRONMENT}/bin:$PATH

ENV PYTHONUNBUFFERED=1

ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_NO_EDITABLE=1
ENV UV_NO_INSTALL_PROJECT=1
ENV UV_PROJECT_ENVIRONMENT=${UV_PROJECT_ENVIRONMENT}
ENV UV_PYTHON_DOWNLOADS=never

ENV VIRTUAL_ENV=${UV_PROJECT_ENVIRONMENT}
ENV VIRTUAL_ENV_PROMPT=''

RUN mkdir -p ${UV_PROJECT_ENVIRONMENT}
VOLUME [ ${UV_PROJECT_ENVIRONMENT} ]

WORKDIR /usr/src/app

FROM base AS onbuild

ONBUILD RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    uv sync
ONBUILD COPY ./ ./

FROM base
