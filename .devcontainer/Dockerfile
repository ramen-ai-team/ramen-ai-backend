# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.4
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

USER root

RUN apt-get update && apt-get install -y \
  libmariadb-dev \
  build-essential \
  libssl-dev \
  && rm -rf /var/lib/apt/lists/*
