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

## Guidelines and Best Practices

### Nomenclature

- Use `snake_case` for file names and directories.
- Use `snake_case` for function and variable names.

### Code Style

- Use 4 spaces for indentation.
- Use `snake_case` for function and variable names.
- Use ShellCheck to lint your shell scripts.
- On variables always wrap them in curly braces and double quotes `"${var}"`.
- Keep the functions small and focused.
- Only use shebang fot the files that are meant to be executed and not sourced.
- Use `pushd` and `popd` instead of `cd` to change directories.
- Use `local` to declare variables inside functions.
- Keep the double commas when checking for env vars to avoid issues with user inputting values with capital letters (eg. `"${ENV_VAR,,}"`).
- Use parameter expansion to replace placeholders in strings (eg. `"${var/X_MINUTES/$}"`).

### Bash Extension

If you are using the Bash extension check the following links for more information:

- https://stackoverflow.com/a/13864829
- https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02

