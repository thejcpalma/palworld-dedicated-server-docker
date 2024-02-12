# Development Guide

## Introduction

This guide is intended for developers who want to contribute to the project. It provides information on how to set up your development environment, how to build and test the project, and how to contribute your changes back to the project.

## Prerequisites

Before you start, you need to have the following tools installed on your system:

- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

## Testing the changes

Use the following `docker-compose-test.yml` file to test the changes:

```yaml
version: '3.9'
services:
  palworld-dedicated-server:
    build: .
    container_name: palworld-dedicated-server
    image: thejcpalma/palworld-dedicated-server:latest
    restart: unless-stopped
    stop_grace_period: 30s  # Set to however long you are willing to wait for the container to gracefully stop
    ports:
      - target: 8211 # Gamerserver port inside of the container
        published: 8211 # Gamerserver port on your host
        protocol: udp
        mode: host
      - target: 25575 # RCON port inside of the container
        published: 25575 # RCON port on your host
        protocol: tcp
        mode: host
    env_file:
      - ./test.env
    volumes:
      - ./game:/palworld
```

To test the changes, you can run the following commands in the root directory of the project:

```bash
cp default.env test.env
# Edit the test.env file to match your desired configuration

# Create the file docker-compose-test.yml with the content above

# Build and run the container in the background and then follow the logs
docker-compose -f docker-compose-test.yml up --build -d && \
docker-compose -f docker-compose-test.yml logs -f
```
