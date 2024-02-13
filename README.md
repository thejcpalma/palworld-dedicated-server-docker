# Palworld Dedicated Server on Docker

[![Release](https://github.com/thejcpalma/palworld-dedicated-server-docker/actions/workflows/release.yml/badge.svg)](https://github.com/thejcpalma/palworld-dedicated-server-docker/actions/workflows/release.yml)
[![Development](https://github.com/thejcpalma/palworld-dedicated-server-docker/actions/workflows/development.yml/badge.svg)](https://github.com/thejcpalma/palworld-dedicated-server-docker/actions/workflows/development.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/thejcpalma/palworld-dedicated-server)
![Docker Stars](https://img.shields.io/docker/stars/thejcpalma/palworld-dedicated-server)
![Image Size](https://img.shields.io/docker/image-size/thejcpalma/palworld-dedicated-server/latest)
[![Static Badge](https://img.shields.io/badge/readme-0.1.2-blue?link=https%3A%2F%2Fgithub.com%2Fthejcpalma%2Fpalworld-dedicated-server-docker%2Fblob%2Fmain%2FREADME.md)](https://github.com/thejcpalma/palworld-dedicated-server-docker?tab=readme-ov-file#palworld-dedicated-server-docker)
![Discord](https://img.shields.io/discord/1206023011011141702?logo=discord&label=Discord&link=https%3A%2F%2Fdiscord.gg%2FycanfK9R5B)


[![Docker Hub](https://img.shields.io/badge/Docker_Hub-palworld-blue?logo=docker)](https://hub.docker.com/r/thejcpalma/palworld-dedicated-server)
[![ghrc](https://img.shields.io/badge/ghrc.io-palworld-blue?logo=github)](https://github.com/thejcpalma/palworld-dedicated-server-docker/pkgs/container/palworld-dedicated-server-docker)

> [!TIP]
> Do you want to chat with the community? 🧑‍💻
>
> **[Join us on Discord 🚀](https://discord.gg/ycanfK9R5B)**

This Docker image includes your own [Palworld](https://store.steampowered.com/app/1623730/Palworld/) Dedicated Server.

The container as been tested and will work on the following OS:

* Linux (Ubuntu/Debian, Arch and Fedora)
* Windows 10,11

> [!IMPORTANT]
> At the moment, Xbox GamePass/Xbox Console players will not be able to join a dedicated server.
>
> They will need to join players using the invite code and are limited to sessions of 4 players max.

___

## Table of Contents

- [Table of Contents](#table-of-contents)
- [What You Need to Get Started](#what-you-need-to-get-started)
- [Server requirements](#server-requirements)
- [Need Support? Here's How!](#need-support-heres-how)
- [Let's Get Started!](#lets-get-started)
- [Environment variables](#environment-variables)
- [Docker-Compose](#docker-compose)
- [Auto Restart and Auto Update](#auto-restart-and-auto-update)
- [Backup Manager](#backup-manager)
- [Run RCON commands](#run-rcon-commands)
- [Webhook integration](#webhook-integration)
  - [Supported events](#supported-events)
- [FAQ](#faq)
  - [How can I use the interactive console in Portainer with this image?](#how-can-i-use-the-interactive-console-in-portainer-with-this-image)
  - [How can I look into the config of my Palworld container?](#how-can-i-look-into-the-config-of-my-palworld-container)
  - [I'm seeing S\_API errors in my logs when I start the container?](#im-seeing-s_api-errors-in-my-logs-when-i-start-the-container)
  - [I'm using Apple silicon type of hardware, can I run this?](#im-using-apple-silicon-type-of-hardware-can-i-run-this)
  - [I changed the `BaseCampWorkerMaxNum` setting, why didn't this update the server?](#i-changed-the-basecampworkermaxnum-setting-why-didnt-this-update-the-server)
- [Software used](#software-used)
- [Major Shoutout](#major-shoutout)
- [License](#license)

## What You Need to Get Started

To use this Docker image, you need:

* A computer running [Linux (Ubuntu, for example)](https://ubuntu.com/download/desktop), [Windows 10](https://www.microsoft.com/software-download/windows10), or [Windows 11](https://www.microsoft.com/software-download/windows11).
* [Docker](https://docs.docker.com/get-docker/) installed on your computer.
* [Docker-Compose](https://docs.docker.com/compose/install/) also installed on your computer.
* Some basic Port-Forwarding/NAT setup.

Don't worry if you're not familiar with these concepts. The links provided will guide you through the installation and setup process.
If you're still having trouble, feel free to ask for help in Discord 😉

## Server requirements

| Resource | 1-8 players                   | 8-12+ players                  |
| -------- | ----------------------------- | ------------------------------ |
| CPU      | 4 CPU-Cores @ High GHz        | 6-8 CPU Cores @ High GHz       |
| RAM      | 8GB RAM Base + 2GB per player | 12GB RAM Base + 2GB per player |
| Storage  | 30GB (SSD)                    | 30GB+ (SSD)                    |

Always follow the official [Palworld Dedicated Server Requirements](https://tech.palworldgame.com/getting-started/requirements) for the most accurate information.

## Need Support? Here's How!

Using this Docker image and have something to share? Here's how:

- **Need Help or Found a Bug?** Open a [new issue](https://github.com/thejcpalma/palworld-dedicated-server-docker/issues/new). 

- **Got a Suggestion?** We're all ears! Share your ideas in a [new feature request](https://github.com/thejcpalma/palworld-dedicated-server-docker/issues/new).


**Community Guidelines:**

- Avoid reviving old issues or off-topic comments.
- Issues inactive for a week will be closed, but feel free to open a new one.

Enjoying the project? Give this repo and the [Docker-Hub repository](https://hub.docker.com/repository/docker/thejcpalma/palworld-dedicated-server) a star ⭐!

💫 Thanks for being part of our journey! 🚀

## Let's Get Started!

1. Make a new folder named `game` in your game-server-directory (For example: `/srv/palworld`, `/home/user/palworld`).
   - This is where the game server files, like configs and savegames, will be stored.
   - If you use the default `docker-compose.yml` file, it will create a folder named `palworld` in the same directory as the `docker-compose.yml` file.
2. Set up Port-Forwarding or NAT for the ports mentioned in the Docker-Compose file.
   - The default port for the game is `8211` and for RCON is `25575`.
3. Get the latest version of the image by typing `docker pull thejcpalma/palworld-dedicated-server:latest` in your terminal.
4. Download/Copy the [docker-compose.yml](docker-compose.yml) and [default.env](default.env) files.
5. Adjust the `docker-compose.yml` and `default.env` files as you like.
   - Check out the [Environment-Variables](#environment-variables) section for more details.
   - If you want auto-update and auto-restart features, but not exposing RCON port, just delete the port on the `docker-compose.yml` file.
6. Start the container by typing `docker-compose up -d && docker-compose logs -f` in your terminal.
   - Keep an eye on the log. If you don't see any errors, you can close the logs with `ctrl+c`.
7. That's it! Now you can enjoy your game! 🎮😉

> [!TIP]
>
> For an in-depth guide, check out our detailed [installation guide](/docs/INSTALL.md).


## Environment variables

Check out the [ENV_VARS.md](/docs/ENV_VARS.md) file for a detailed list of environment variables.
This file contains a list of all the environment variables that can be used to customize your Palworld Dedicated Server.

## Docker-Compose

Download/Copy the [docker-compose.yml](docker-compose.yml) and [default.env](default.env) files.

## Auto Restart and Auto Update

> [!WARNING]
>
> **This features require RCON to be enabled**
> If after restart/update, no players are online near the bases they might not render correctly, causing pals to bug out (be stacked on the palbox, stop gathering, etc...)

You can use the auto restart and auto update feature by setting the `AUTO_RESTART_ENABLED` and `AUTO_RESTART_ENABLED` environment variables to `true`.
Check out the [ENV_VARS.md](/docs/ENV_VARS.md#special-features) for a detailed list of the variables.

> [!IMPORTANT]
>
> Manually restarting or updating the server won't show on the docker logs.
>
> Will use default warn time if not specified (update will always use `AUTO_UPDATE_WARN_MINUTES` )

You can also manually restart or update the server.
Usage: `docker exec palworld-dedicated-server restart [warn_time]` or `docker exec palworld-dedicated-server update`

```shell
docker exec palworld-dedicated-server restart 1
>> players online: 0
> No players are online. Restarting the server now...
> RCON: Broadcasted: Server-is-restarting-now!
> RCON: Broadcasted: 00:06:15-Saving-in-5-seconds
> RCON: Broadcasted: Saving-world...
> RCON: Complete Save
> RCON: Broadcasted: Saving-done
> RCON: Broadcasted: Creating-backup
> RCON: Broadcasted: Backup-done
>>> Backup 'saved-20240213_000615.tar.gz' created successfully.
> RCON: Broadcasted: Server-is-shutting-down-now!
> RCON: The server will shut down in 1 seconds. Please prepare to exit the game.
```

```shell
docker exec palworld-dedicated-server update   
> The server is up-to-date!
```

> **Restart and update features will always perform a backup before shutting down the server.**


## Backup Manager

> [!WARNING]
> If RCON is disabled, the backup manager won't do saves via RCON before creating a backup.
> This means that the backup will be created from the last auto-save of the server.
> This can lead to data-loss and/or savegame corruption.
>
> **Recommendation:** Please make sure that RCON is enabled before using the backup manager.

Usage: `docker exec palworld-dedicated-server backup [command] [arguments]`

| Command | Argument           | Required/Optional | Default Value                      | Values           | Description                                                                                                                                                                           |
| ------- | ------------------ | ----------------- | ---------------------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| create  | N/A                | N/A               | N/A                                | N/A              | Creates a backup.                                                                                                                                                                     |
| list    | `<number_to_list>` | Optional          | N/A                                | Positive integer | Lists all backups.<br>If `<number_to_list>` is specified, only the most<br>recent `<number_to_list>` backups are listed.                                                              |
| clean   | `<number_to_keep>` | Optional          | `BACKUP_AUTO_CLEAN_AMOUNT_TO_KEEP` | Positive integer | Cleans up backups.<br>If `<number_to_keep>` is specified, cleans and keeps<br>the most recent`<number_to_keep>` backups.<br>If not, default to `BACKUP_AUTO_CLEAN_AMOUNT_TO_KEEP` var |

Examples:

```shell
$ docker exec palworld-dedicated-server backup
> Backup 'saved-20240203_032855.tar.gz' created successfully.
```

```shell
$ docker exec palworld-dedicated-server backup list
> Listing 2 backup file(s)!
2024-02-03 03:28:55 | saved-20240203_032855.tar.gz
2024-02-03 03:28:00 | saved-20240203_032800.tar.gz
```

```shell
$ docker exec palworld-dedicated-server backup_clean 3
> 1 backup(s) cleaned, keeping 2 backups(s).
```

```shell
$ docker exec palworld-dedicated-server backup_list   
> Listing 1 out of backup 2 file(s).
2024-02-03 03:30:00 | saved-20240203_033000.tar.gz
```

## Run RCON commands

> [!NOTE]
> Please research the RCON commands on the official source: https://tech.palworldgame.com/server-commands

Usage: `docker exec palworld-dedicated-server rconcli [command]`
Examples:

```shell
$ docker exec palworld-dedicated-server rconcli ShowPlayers
> RCON: name,playeruid,steamid
thejcpalma,1234,5789
```

## Webhook integration

To enable webhook integrations, you need to set the following environment variables in the `default.env`:

```shell
WEBHOOK_ENABLED=true
WEBHOOK_URL="https://your.webhook.url"
```

After enabling the server should send messages in a Discord-Compatible way to your webhook url.

> You can find more details about these variables [here](/docs/ENV_VARS.md#webhook-settings).

### Supported events

- Server starting
- Server stopped
- Server restart
- Server fresh install
- Server updating
- Server updating and validating

## FAQ

### How can I use the interactive console in Portainer with this image?

> You can run this `docker exec -ti palworld-dedicated-server bash' or you could navigate to the **"Stacks"** tab in Portainer, select your stack, and click on the container name. Then click on the **"Exec console"** button.

### How can I look into the config of my Palworld container?

> You can run this `docker exec -ti palworld-dedicated-server cat /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini` and it will show you the config inside the container.

### I'm seeing S_API errors in my logs when I start the container?

> Errors like `[S_API FAIL] Tried to access Steam interface SteamUser021 before SteamAPI_Init succeeded.` are safe to ignore.

### I'm using Apple silicon type of hardware, can I run this?

> You can try to insert in your docker-compose file this parameter `platform: linux/amd64` at the palworld service. This isn't a special fix for Apple silicon, but to run on other than x86 hosts. The support for arm exists only by enforcing x86 emulation, if that isn't to host already. Rosetta is doing the translation/emulation.

### I changed the `BaseCampWorkerMaxNum` setting, why didn't this update the server?

> This is a confirmed bug. Changing `BaseCampWorkerMaxNum` in the `PalWorldSettings.ini` has no effect on the server. There are tools out there to help with this, like this one: <https://github.com/legoduded/palworld-worldoptions>

> [!WARNING]
> Adding `WorldOption.sav` will break `PalWorldSetting.ini`. So any new changes to the settings (either on the file or via ENV VARS), you will have to create a new `WorldOption.sav` and update it every time for those changes to have an effect.



## Software used

- CM2Network SteamCMD - Debian-based (Officially recommended by Valve - https://developer.valvesoftware.com/wiki/SteamCMD#Docker)
- Supercronic - https://github.com/aptible/supercronic
- rcon-cli - https://github.com/gorcon/rcon-cli
- Palworld Dedicated Server (APP-ID: 2394010 - https://steamdb.info/app/2394010/config/)


## Major Shoutout

This project was inspired by the following repositories:

1. [Docker - Palworld Dedicated Server](https://github.com/jammsen/docker-palworld-dedicated-server) by [@jammsen](https://github.com/jammsen) ❤️
2. [Palworld Dedicated Server Docker](https://github.com/thijsvanloef/palworld-server-docker) by [@thijsvanloef](https://github.com/thijsvanloef)

A big thank you to the authors for their contributions to the open source community!

_**A much bigger thank you to [@jammsen](https://github.com/jammsen) for being an amazing, experienced person and for all the knowledge shared. Your contributions and guidance have been invaluable to this project.**_

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.