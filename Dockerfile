# Description: Dockerfile for Palworld Dedicated Server

# Build the rcon binary
FROM golang:1.22.0-bookworm as rcon-build

WORKDIR /build

ENV CGO_ENABLED=0 \
    GORCON_RCONCLI_URL=https://github.com/gorcon/rcon-cli/archive/refs/tags/v0.10.3.tar.gz \
    GORCON_RCONCLI_DIR=rcon-cli-0.10.3 \
    GORCON_RCONCLI_TGZ=v0.10.3.tar.gz \
    GORCON_RCONCLI_TGZ_SHA1SUM=33ee8077e66bea6ee097db4d9c923b5ed390d583

RUN curl -fsSLO "$GORCON_RCONCLI_URL" \
 && echo "${GORCON_RCONCLI_TGZ_SHA1SUM}  ${GORCON_RCONCLI_TGZ}" | sha1sum -c - \
 && tar -xzf "$GORCON_RCONCLI_TGZ" \
 && mv "$GORCON_RCONCLI_DIR"/* ./ \
 && rm "$GORCON_RCONCLI_TGZ" \
 && rm -Rf "$GORCON_RCONCLI_DIR" \
 && go build -v ./cmd/gorcon

# Build the supercronic binary
FROM debian:bookworm-slim as supercronic-build

# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b

RUN apt-get update \
 && apt-get install -y --no-install-recommends --no-install-suggests ca-certificates curl \
 && apt-get autoremove -y --purge \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Build the final image
FROM --platform=linux/amd64 cm2network/steamcmd:root

LABEL maintainer="João Palma"
LABEL name="thejcpalma/palworld-dedicated-server-docker"
LABEL github="https://github.com/thejcpalma/palworld-dedicated-server-docker"
LABEL dockerhub="https://hub.docker.com/r/thejcpalma/palworld-dedicated-server"
LABEL org.opencontainers.image.authors="João Palma"
LABEL org.opencontainers.image.source="https://github.com/thejcpalma/palworld-dedicated-server-docker"


# Install minimum required packages for dedicated server
RUN apt-get update \
 && apt-get install -y --no-install-recommends --no-install-suggests procps xdg-user-dirs \
 && apt-get autoremove -y --purge \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the rcon and supercronic binaries
COPY --from=rcon-build        --chmod=755  /build/gorcon               /usr/local/bin/rcon
COPY --from=supercronic-build --chmod=755  /usr/local/bin/supercronic  /usr/local/bin/supercronic

ENV APP_ID=2394010
ENV SERVER_DIR=/home/steam/server

COPY --chown=steam:steam --chmod=755 scripts/       ${SERVER_DIR}/scripts
COPY --chown=steam:steam --chmod=755 entrypoint.sh  ${SERVER_DIR}/
# Copy custom rcon broadcast to fix spaces in the message
COPY --chmod=755 bin/rcon_broadcast /usr/local/bin/rcon_broadcast

RUN ln -s ${SERVER_DIR}/scripts/backup_manager.sh               /usr/local/bin/backup_manager \
 && ln -s ${SERVER_DIR}/scripts/rcon/rconcli.sh                 /usr/local/bin/rconcli \
 && ln -s ${SERVER_DIR}/scripts/wrappers/backup_manager_cli.sh  /usr/local/bin/backup \
 && ln -s ${SERVER_DIR}/scripts/wrappers/update.sh              /usr/local/bin/update \
 && ln -s ${SERVER_DIR}/scripts/wrappers/restart.sh             /usr/local/bin/restart 


# Set the default shell to Bash with the 'pipefail' option enabled.
# This changes the pipeline's return status to be the value of the last command
# to exit with a non-zero status, or zero if all commands exit successfully.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    # Container setttings
    PUID=1000 \
    PGID=1000 \
    TZ="Europe/Berlin" \
    # Path vars
    GAME_ROOT="/palworld" \
    GAME_PATH="/palworld/Pal" \
    GAME_SAVE_PATH="/palworld/Pal/Saved" \
    GAME_CONFIG_PATH="/palworld/Pal/Saved/Config/LinuxServer" \
    GAME_SETTINGS_FILE="/palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini" \
    GAME_ENGINE_FILE="/palworld/Pal/Saved/Config/LinuxServer/Engine.ini" \
    BACKUP_PATH="/palworld/backups" \
    STEAMCMD_PATH="/home/steam/steamcmd" \
    RCON_CONFIG_FILE="/home/steam/server/configs/rcon.yaml" \
    # SteamCMD settings
    ALWAYS_UPDATE_ON_START=true \
    STEAMCMD_VALIDATE_FILES=true \
    # Auto update settings
    AUTO_UPDATE_ENABLED=false \
    AUTO_UPDATE_CRON_EXPRESSION="0 3 * * *" \
    AUTO_UPDATE_WARN_MINUTES=30 \
    # Auto restart settings
    AUTO_RESTART_ENABLED=false \
    AUTO_RESTART_WARN_MINUTES=30 \
    AUTO_RESTART_CRON_EXPRESSION="0 5 * * *" \
    # Backup settings
    BACKUP_ENABLED=true \
    BACKUP_CRON_EXPRESSION="0 * * * *" \
    BACKUP_AUTO_CLEAN=true \
    BACKUP_AUTO_CLEAN_AMOUNT_TO_KEEP=72 \
    # Player monitoring settings
    PLAYER_MONITOR_ENABLED=true \
    PLAYER_MONITOR_INTERVAL=60 \
    # Webhook settings
    WEBHOOK_ENABLED=false \
    WEBHOOK_URL= \
    WEBHOOK_START_TITLE="Server is starting" \
    WEBHOOK_START_DESCRIPTION="The gameserver is starting" \
    WEBHOOK_START_COLOR="65280" \
    WEBHOOK_STOP_TITLE="Server has been stopped" \
    WEBHOOK_STOP_DESCRIPTION="The gameserver has been stopped" \
    WEBHOOK_STOP_COLOR="16711680" \
    WEBHOOK_RESTART_TITLE="Server is restarting" \
    WEBHOOK_RESTART_DESCRIPTION="The gameserver is restarting in " \
    WEBHOOK_RESTART_COLOR="16750848" \
    WEBHOOK_INSTALL_TITLE="Server is being installed" \
    WEBHOOK_INSTALL_DESCRIPTION="Server is being installed" \
    WEBHOOK_INSTALL_COLOR="1644912" \
    WEBHOOK_UPDATE_TITLE="Updating server" \
    WEBHOOK_UPDATE_DESCRIPTION="Server is being updated" \
    WEBHOOK_UPDATE_COLOR="16776960" \
    WEBHOOK_UPDATE_VALIDATE_TITLE="Updating and validating server" \
    WEBHOOK_UPDATE_VALIDATE_DESCRIPTION="Server is being updated and validated" \
    WEBHOOK_UPDATE_VALIDATE_COLOR="16776960" \
    # Gameserver start settings
    MULTITHREAD_ENABLED=true \
    COMMUNITY_SERVER=true \
    # Config setting - Warning: using 'auto' will overwrite the settings in the config file with the environment variables
    SERVER_SETTINGS_MODE=auto \
    # Engine.ini
    NETSERVERMAXTICKRATE=120 \
    # PalWorldSettings.ini
    DIFFICULTY=None \
    DAYTIME_SPEEDRATE=1.000000 \
    NIGHTTIME_SPEEDRATE=1.000000 \
    EXP_RATE=1.000000 \
    PAL_CAPTURE_RATE=1.000000 \
    PAL_SPAWN_NUM_RATE=1.000000 \
    PAL_DAMAGE_RATE_ATTACK=1.000000 \
    PAL_DAMAGE_RATE_DEFENSE=1.000000 \
    PLAYER_DAMAGE_RATE_ATTACK=1.000000 \
    PLAYER_DAMAGE_RATE_DEFENSE=1.000000 \
    PLAYER_STOMACH_DECREASE_RATE=1.000000 \
    PLAYER_STAMINA_DECREACE_RATE=1.000000 \
    PLAYER_AUTO_HP_REGENE_RATE=1.000000 \
    PLAYER_AUTO_HP_REGENE_RATE_IN_SLEEP=1.000000 \
    PAL_STOMACH_DECREACE_RATE=1.000000 \
    PAL_STAMINA_DECREACE_RATE=1.000000 \
    PAL_AUTO_HP_REGENE_RATE=1.000000 \
    PAL_AUTO_HP_REGENE_RATE_IN_SLEEP=1.000000 \
    BUILD_OBJECT_DAMAGE_RATE=1.000000 \
    BUILD_OBJECT_DETERIORATION_DAMAGE_RATE=1.000000 \
    COLLECTION_DROP_RATE=1.000000 \
    COLLECTION_OBJECT_HP_RATE=1.000000 \
    COLLECTION_OBJECT_RESPAWN_SPEED_RATE=1.000000 \
    ENEMY_DROP_ITEM_RATE=1.000000 \
    DEATH_PENALTY=All \
    ENABLE_PLAYER_TO_PLAYER_DAMAGE=false \
    ENABLE_FRIENDLY_FIRE=false \
    ENABLE_INVADER_ENEMY=true \
    ACTIVE_UNKO=false \
    ENABLE_AIM_ASSIST_PAD=true \
    ENABLE_AIM_ASSIST_KEYBOARD=false \
    DROP_ITEM_MAX_NUM=3000 \
    DROP_ITEM_MAX_NUM_UNKO=100 \
    BASE_CAMP_MAX_NUM=128 \
    BASE_CAMP_WORKER_MAXNUM=15 \
    DROP_ITEM_ALIVE_MAX_HOURS=1.000000 \
    AUTO_RESET_GUILD_NO_ONLINE_PLAYERS=false \
    AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS=72.000000 \
    GUILD_PLAYER_MAX_NUM=20 \
    PAL_EGG_DEFAULT_HATCHING_TIME=72.000000 \
    WORK_SPEED_RATE=1.000000 \
    IS_MULTIPLAY=false \
    IS_PVP=false \
    CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP=false \
    ENABLE_NON_LOGIN_PENALTY=true \
    ENABLE_FAST_TRAVEL=true \
    IS_START_LOCATION_SELECT_BY_MAP=true \
    EXIST_PLAYER_AFTER_LOGOUT=false \
    ENABLE_DEFENSE_OTHER_GUILD_PLAYER=false \
    COOP_PLAYER_MAX_NUM=4 \
    MAX_PLAYERS=32 \
    SERVER_NAME="thejcpalma-docker-generated-###RANDOM###" \
    SERVER_DESCRIPTION="Palworld Dedicated Server running in Docker by thejcpalma" \
    ADMIN_PASSWORD=adminPasswordHere \
    SERVER_PASSWORD=serverPasswordHere \
    PUBLIC_PORT=8211 \
    PUBLIC_IP= \
    RCON_ENABLED=false \
    RCON_PORT=25575 \
    REGION= \
    USEAUTH=true \
    BAN_LIST_URL=https://api.palworldgame.com/api/banlist.txt


EXPOSE 8211/udp
EXPOSE 25575/tcp

VOLUME ["${GAME_ROOT}"]

WORKDIR ${SERVER_DIR}

HEALTHCHECK --start-period=5m \
    CMD pgrep "PalServer-Linux" > /dev/null || exit 1

ENTRYPOINT  ["/home/steam/server/entrypoint.sh"]
