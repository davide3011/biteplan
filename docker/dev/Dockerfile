FROM ubuntu:22.04

ARG FLUTTER_VERSION=3.41.9

ENV DEBIAN_FRONTEND=noninteractive \
    FLUTTER_HOME=/opt/flutter \
    PATH="/opt/flutter/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
        https://github.com/flutter/flutter.git /opt/flutter && \
    flutter config --no-analytics --enable-web && \
    flutter precache --web

WORKDIR /workspace
