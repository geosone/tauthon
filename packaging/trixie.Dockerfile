FROM debian:trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends build-essential debhelper autoconf pkg-config libssl-dev zlib1g-dev libbz2-dev libreadline-dev libncurses-dev libsqlite3-dev libffi-dev libgdbm-dev libgdbm-compat-dev libexpat1-dev ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /build
