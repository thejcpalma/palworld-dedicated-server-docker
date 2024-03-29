# Environment Variables

[Back to main](../README.md#environment-variables)

In this section you will find a lot of environment variables to control your container, server behavior and game settings.
Due to the extensive control options, the settings are split into categories:

- [Container Settings](#container-settings)
  - [TZ identifiers](#tz-identifiers)
- [Dedicated Server Settings](#dedicated-server-settings)
  - [Special Features](#special-features)
    - [Cron expression](#cron-expression)
  - [Server Settings](#server-settings)
  - [Engine Configuration Mode](#engine-configuration-mode)
  - [Engine Settings](#engine-settings)
  - [Palworld Game Settings](#palworld-game-settings)
- [Webhook Settings](#webhook-settings)
  - [Webhook Configuration](#webhook-configuration)
  - [Webhook Messages](#webhook-messages)
    - [**- Start server message**](#--start-server-message)
    - [**- Stop server message**](#--stop-server-message)
    - [**- Restart server message**](#--restart-server-message)
    - [**- Install server message**](#--install-server-message)
    - [**- Update server message**](#--update-server-message)
    - [**- Update and validation server message**](#--update-and-validation-server-message)
    - [**- Player join message**](#--player-join-message)
    - [**- Player leave message**](#--player-leave-message)

## Container Settings

These settings control the behavior of the Docker container:

> **Important:** If you want to change the server settings via environment variables use the default value (`auto`) for the environment variable `SERVER_SETTINGS_MODE`, otherwise change it to `manual` and edit the config file directly.

| Variable | Description                                           | Default value | Allowed values                        |
| -------- | ----------------------------------------------------- | ------------- | ------------------------------------- |
| `PUID`   | `PUID` stands for Process User ID, also known as UID  | 1000          | Integer                               |
| `PGID`   | `PGID` stands for Process Group ID, also known as GID | 1000          | Integer                               |
| `TZ`     | Timezone used for time stamping server backups        | `UTC`         | See [TZ identifiers](#tz-identifiers) |

### TZ identifiers

The `TZ` setting affects logging output and the backup function. [TZ identifiers](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#Time_Zone_abbreviations) are a format for defining a timezone near you.


## Dedicated Server Settings

These are the overall settings for the dedicated server.

### Special Features

> [!IMPORTANT]
>
> **RCON** should be enabled for all for them to work as expected.

These settings control the special features of the server:

 - Auto updates:
 - Auto restarts
 - Auto backups

| Variable                           | Description                                                                                             | Default value | Allowed value                           |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------- | ------------- | --------------------------------------- |
| `AUTO_UPDATE_ENABLED`              | Enables automatic updates for the server when a new version is available                                | `false`       | `false`/`true`                          |
| `AUTO_UPDATE_CRON_EXPRESSION`      | The cron expression for checking new version                                                            | `0 3 * * *`   | See [Cron expression](#cron-expression) |
| `AUTO_UPDATE_WARN_MINUTES`         | The time in minutes to warn players before the server is updated                                        | `10`          | Integer                                 |
| `AUTO_RESTART_ENABLED`             | Enables automatic restarts for the server                                                               | `false`       | `false`/`true`                          |
| `AUTO_RESTART_WARN_MINUTES`        | The time in minutes to warn players before the server is restarted                                      | `10`          | Integer                                 |
| `AUTO_RESTART_CRON_EXPRESSION`     | The cron expression for the automatic restart function                                                  | `0 5 * * *`   | See [Cron expression](#cron-expression) |
| `BACKUP_ENABLED`                   | Enables automatic backups for the server                                                                | `true`        | `false`/`true`                          |
| `BACKUP_CRON_EXPRESSION`           | The cron expression for the automatic backup function                                                   | `0 * * * *`   | See [Cron expression](#cron-expression) |
| `BACKUP_AUTO_CLEAN`                | Enables automatic cleanup of old backups                                                                | `true`        | `false`/`true`                          |
| `BACKUP_AUTO_CLEAN_AMOUNT_TO_KEEP` | The amount of backups to keep                                                                           | `72`          | Integer                                 |
| `PLAYER_MONITOR_ENABLED`           | Enables player monitoring for the server                                                                | `false`       | `false`/`true`                          |
| `PLAYER_MONITOR_INTERVAL`          | The interval in seconds for the player monitoring  (lower values means more impact on system resources) | `60`          | Integer                                 |

#### Cron expression

In a Cron-Expression, you define an interval for when to run jobs.
Use the following format: `* * * * *` (Minute, Hour, Day of the month, Month, Day of the week).
If you are not familiar with cron expressions, you can use a cron expression generator like [crontab-generator.org](https://crontab-generator.org).

Default values for the cron expressions:
 - Auto restarts: `0 5 * * *` (Every day at 5am)
 - Auto updates: `0 3 * * *` (Every day at 3am)
 - Auto backups: `0 * * * *` (Every hour)

### Server Settings

| Variable              | Description                                                         | Default value | Allowed value  |
| --------------------- | ------------------------------------------------------------------- | ------------- | -------------- |
| `MULTITHREAD_ENABLED` | Sets options for "Improved multi-threaded CPU"                      | `true`        | `false`/`true` |
| `COMMUNITY_SERVER`    | Set to enabled, the server will appear in the Community Server list | `true`        | `false`/`true` |

> [!IMPORTANT]
>
> Take special attention to `SERVER_SETTINGS_MODE`, if you want to change the server settings via environment variables use the default value (`auto`), otherwise change it to `manual` and edit the config file directly.

This setting controls how the server settings files (`PalWorldSettings.ini` and `Engine.ini`) are configured:
 - `auto`: will use environment variables to configure the files
 - `manual`: will skip the configuration of the files and files will have to be edited manually

| Variable               | Description                                                                       | Default value | Allowed value   |
| ---------------------- | --------------------------------------------------------------------------------- | ------------- | --------------- |
| `SERVER_SETTINGS_MODE` | Whether settings are configured via environment variables or manually on the file | `auto`        | `auto`/`manual` |

> [!NOTE]
>
> For `PalWorldSettings.ini`, all settings with empty values (e.g. `EXP_RATE=""`) will be overwritten the default value.
> For `Engine.ini` refer to the [Engine Settings](#engine-settings) section for more information.
>
> The rules below apply to both `PalWorldSettings.ini` and `Engine.ini`:
>  - All settings which are in a wrong format (putting a string in a float variable like `EXP_RATE="very_fast"`) will be ignored and the default value will be used instead.
>  - Integers on float variables will be converted to floats (e.g. `EXP_RATE=2` will be converted to `2.000000`).
>  - Floats with more than 6 decimal places will be rounded to 6 decimal places (e.g. `EXP_RATE=2.123456789` will be converted to `2.123457`).
>  - Variables where we have multiple options (like `DIFFICULTY`) will always be converted to lowercase (e.g. `DIFFICULTY="Normal"` will be converted to `difficulty="normal"`) to maintain consistency.

### Engine Configuration Mode

When `SERVER_SETTINGS_MODE` is set to `auto`, we will use environment variables to configure the engine settings.

The `ENGINE_CONFIG_MODE` environment variable controls how the engine settings are configured:
 - `full`: will add all the settings in the Engine.ini.template file with the environment variables values or the default values for those settings
 - `modular`: will only set the settings in the engine file when the corresponding environment variable is set and not empty
 - `skip`: will always skip the configuration of the settings in the engine file (even if `SERVER_SETTINGS_MODE` to `auto`)

| Variable             | Description                         | Default value | Allowed value           |
| -------------------- | ----------------------------------- | ------------- | ----------------------- |
| `ENGINE_CONFIG_MODE` | How `Engine.ini` file is configured | `modular`     | `full`/`modular`/`skip` |

### Engine Settings

This section contains all the settings currently adjustable via environment variables, based on the **order** and **contents of the [`Engine.ini.template`](../scripts/config/templates/Engine.ini.template)**.

| Variable                                    | Game setting                         | Description                                                                                                     | Default value | Allowed value       |
| ------------------------------------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------- | ------------- | ------------------- |
| `LAN_SERVER_MAX_TICK_RATE`                  | LanServerMaxTickRate                 | Changes the TickRate of the server, be very careful with this!                                                  | `120`         | Integer             |
| `NET_SERVER_MAX_TICK_RATE`                  | NetServerMaxTickRate                 | Changes the TickRate of the server, be very careful with this!                                                  | `120`         | Integer             |
| `CONFIGURED_INTERNET_SPEED`                 | ConfiguredInternetSpeed              | Sets the assumed player internet speed in bytes per second. High value reduces chances of bandwidth throttling. | `104857600`   | Integer  (in bytes) |
| `CONFIGURED_LAN_SPEED`                      | ConfiguredLanSpeed                   | Sets the LAN speed, ensuring LAN players can utilize maximum network capacity.                                  | `104857600`   | Integer  (in bytes) |
| `MAX_CLIENT_RATE`                           | MaxClientRate                        | Maximum data transfer rate per client for all connections, set to a high value to prevent data capping.         | `104857600`   | Integer  (in bytes) |
| `MAX_INTERNET_CLIENT_RATE`                  | MaxInternetClientRate                | Specifically targets internet clients, allowing for high-volume data transfer without restrictions.             | `104857600`   | Integer  (in bytes) |
| `SMOOTH_FRAME_RATE`                         | bSmoothFrameRate                     | Enables the game engine to smooth out frame rate fluctuations for a more consistent visual experience.          | `true`        | `false`/`true`      |
| `SMOOTH_FRAME_RATE_UPPER_BOUND`             | SmoothFrameRateRange                 | Sets a max target frame rate range for smoothing.                                                               | `120.000000`  | Float               |
| `SMOOTH_FRAME_RATE_LOWER_BOUND`             | SmoothFrameRateRange                 | Sets a min target frame rate range for smoothing.                                                               | `30.000000`   | Float               |
| `MIN_DESIRED_FRAME_RATE`                    | MinDesiredFrameRate                  | Specifies a minimum acceptable frame rate, ensuring the game runs smoothly at least at this frame rate.         | `60.000000`   | Float               |
| `USE_FIXED_FRAME_RATE`                      | bUseFixedFrameRate                   | Enables the use of a fixed frame rate                                                                           | `false`       | `false`/`true`      |
| `FIXED_FRAME_RATE`                          | FixedFrameRate                       | Fixed frame rate                                                                                                | `120.000000`  | Float               |
| `NET_CLIENT_TICKS_PER_SECOND`               | NetClientTicksPerSecond              | Increases the update frequency for clients, enhancing responsiveness and reducing lag.                          | `120`         | Integer             |
| `TIME_BETWEEN_PURGING_PENDING_KILL_OBJECTS` | TimeBetweenPurgingPendingKillObjects | time in seconds between purging pending kill objects, freeing up memory and reducing memory leaks.              | `30`          | Integer             |
| `THREADED_RENDERING`                        | r.ThreadedRendering                  | Enables the use of multiple thread for rendering, improving performance.                                        | `true`        | `false`/`true`      |
| `THREADED_PHYSICS`                          | r.ThreadedPhysics                    | Enables the use multiple thread for physics, improving performance.                                             | `true`        | `false`/`true`      |


> [!TIP]
>
> While setting the server tickrate above to 120 fps will make some gameplay aspect smoother, it won't fix rubber-banding and will tax your hardware significantly more.

### Palworld Game Settings

This section lists all the settings currently adjustable via environment variables, based on the **order** and **contents of the [`PalWorldSettings.ini.template`](../scripts/config/templates/PalWorldSettings.ini.template)** (which is the same as `DefaultPalWorldSettings.ini`).

Information sources and credits to the following websites:
- [Palworld Official Tech Guide](https://tech.palworldgame.com/settings-and-operation/configuration) for the game server documentation
- [Palworld Setting Generator](https://dysoncheng.github.io/PalWorldSettingGenerator/setting.html) for variable descriptions
- [Palworld Unofficial Wiki](https://palworld.wiki.gg/wiki/PalWorldSettings.ini) for variable descriptions
- [Palworld Shockbyte Documentation](https://shockbyte.com/billing/knowledgebase/1189/How-to-Configure-your-Palworld-server.html) for variable descriptions

> [!IMPORTANT]
>
> Please note that all of this is subject to change. **The game is still in early access.**
> 
> Check out the [official webpage for the supported parameters.](https://tech.palworldgame.com/optimize-game-balance)
>
> To change a setting, you can set the environment variable to the value you want. If the environment variable is not set or is blank, the default value will be used.


| Variable                                    | Game setting                         | Description                                                                                                                                                       | Default value                                               | Allowed value  |
| ------------------------------------------- | ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- | -------------- |
| `DIFFICULTY`                                | Difficulty                           | Choose one of the following:<br>`None`<br>`Normal`<br>`Difficult`                                                                                                 | `None`                                                      | Enum           |
| `DAY_TIME_SPEED_RATE`                        | DayTimeSpeedRate                     | Day time speed - Smaller number means longer days                                                                                                                 | `1.000000`                                                  | Float          |
| `NIGHT_TIME_SPEED_RATE`                     | NightTimeSpeedRate                   | Night time speed - Bigger number means shorter nights                                                                                                             | `1.000000`                                                  | Float          |
| `EXP_RATE`                                  | ExpRate                              | EXP rate                                                                                                                                                          | `1.000000`                                                  | Float          |
| `PAL_CAPTURE_RATE`                          | PalCaptureRate                       | Pal capture rate                                                                                                                                                  | `1.000000`                                                  | Float          |
| `PAL_SPAWN_NUM_RATE`                        | PalSpawnNumRate                      | Pal appearance rate                                                                                                                                               | `1.000000`                                                  | Float          |
| `PAL_DAMAGE_RATE_ATTACK`                    | PalDamageRateAttack                  | Damage from pals multiplier                                                                                                                                       | `1.000000`                                                  | Float          |
| `PAL_DAMAGE_RATE_DEFENSE`                   | PalDamageRateDefense                 | Damage to pals multiplier                                                                                                                                         | `1.000000`                                                  | Float          |
| `PLAYER_DAMAGE_RATE_ATTACK`                 | PlayerDamageRateAttack               | Damage from player multiplier                                                                                                                                     | `1.000000`                                                  | Float          |
| `PLAYER_DAMAGE_RATE_DEFENSE`                | PlayerDamageRateDefense              | Damage to  player multiplier                                                                                                                                      | `1.000000`                                                  | Float          |
| `PLAYER_STOMACH_DECREACE_RATE`              | PlayerStomachDecreaceRate            | Player hunger depletion rate                                                                                                                                      | `1.000000`                                                  | Float          |
| `PLAYER_STAMINA_DECREACE_RATE`              | PlayerStaminaDecreaceRate            | Player stamina reduction rate                                                                                                                                     | `1.000000`                                                  | Float          |
| `PLAYER_AUTO_HP_REGENE_RATE`                | PlayerAutoHPRegeneRate               | Player auto HP regeneration rate                                                                                                                                  | `1.000000`                                                  | Float          |
| `PLAYER_AUTO_HP_REGENE_RATE_IN_SLEEP`       | PlayerAutoHpRegeneRateInSleep        | Player sleep HP regeneration rate                                                                                                                                 | `1.000000`                                                  | Float          |
| `PAL_STOMACH_DECREACE_RATE`                 | PalStomachDecreaceRate               | Pal hunger depletion rate                                                                                                                                         | `1.000000`                                                  | Float          |
| `PAL_STAMINA_DECREACE_RATE`                 | PalStaminaDecreaceRate               | Pal stamina reduction rate                                                                                                                                        | `1.000000`                                                  | Float          |
| `PAL_AUTO_HP_REGENE_RATE`                   | PalAutoHPRegeneRate                  | Pal auto HP regeneration rate                                                                                                                                     | `1.000000`                                                  | Float          |
| `PAL_AUTO_HP_REGENE_RATE_IN_SLEEP`          | PalAutoHpRegeneRateInSleep           | Pal sleep health regeneration rate (in Palbox)                                                                                                                    | `1.000000`                                                  | Float          |
| `BUILD_OBJECT_DAMAGE_RATE`                  | BuildObjectDamageRate                | Damage to structure multiplier                                                                                                                                    | `1.000000`                                                  | Float          |
| `BUILD_OBJECT_DETERIORATION_DAMAGE_RATE`    | BuildObjectDeteriorationDamageRate   | Structure deterioration rate                                                                                                                                      | `1.000000`                                                  | Float          |
| `COLLECTION_DROP_RATE`                      | CollectionDropRate                   | Gatherable items multiplier                                                                                                                                       | `1.000000`                                                  | Float          |
| `COLLECTION_OBJECT_HP_RATE`                 | CollectionObjectHpRate               | Gatherable objects HP multiplier                                                                                                                                  | `1.000000`                                                  | Float          |
| `COLLECTION_OBJECT_RESPAWN_SPEED_RATE`      | CollectionObjectRespawnSpeedRate     | Gatherable objects respawn. Smaller means faster interval                                                                                                         | `1.000000`                                                  | Float          |
| `ENEMY_DROP_ITEM_RATE`                      | EnemyDropItemRate                    | Dropped Items Multiplier                                                                                                                                          | `1.000000`                                                  | Float          |
| `DEATH_PENALTY`                             | DeathPenalty                         | `None` : No lost<br> `Item` : Lost item without equipment<br>`ItemAndEquipment` : Lost item and equipment<br>`All`: Lost All item,   equipment, pal(in inventory) | `All`                                                       | Enum           |
| `ENABLE_PLAYER_TO_PLAYER_DAMAGE`            | bEnablePlayerToPlayerDamage          | Allows players to cause damage to players                                                                                                                         | `false`                                                     | `false`/`true` |
| `ENABLE_FRIENDLY_FIRE`                      | bEnableFriendlyFire                  | Allow friendly fire                                                                                                                                               | `false`                                                     | `false`/`true` |
| `ENABLE_INVADER_ENEMY`                      | bEnableInvaderEnemy                  | Enable invaders                                                                                                                                                   | `true`                                                      | `false`/`true` |
| `ACTIVE_UNKO`                               | bActiveUNKO                          | Enable UNKO                                                                                                                                                       | `false`                                                     | `false`/`true` |
| `ENABLE_AIM_ASSIST_PAD`                     | bEnableAimAssistPad                  | Enable controller aim assist                                                                                                                                      | `true`                                                      | `false`/`true` |
| `ENABLE_AIM_ASSIST_KEYBOARD`                | bEnableAimAssistKeyboard             | Enable Keyboard aim assist                                                                                                                                        | `false`                                                     | `false`/`true` |
| `DROP_ITEM_MAX_NUM`                         | DropItemMaxNum                       | Maximum number of drops in the world                                                                                                                              | `3000`                                                      | Integer        |
| `DROP_ITEM_MAX_NUM_UNKO`                    | DropItemMaxNum                       | Maximum number of UNKO drops in the world                                                                                                                         | `100`                                                       | Integer        |
| `BASE_CAMP_MAX_NUM`                         | BaseCampMaxNum                       | Maximum number of base camps                                                                                                                                      | `128`                                                       | Integer        |
| `BASE_CAMP_WORKER_MAXNUM`                   | BaseCampWorkerMaxNum                 | Maximum number of workers                                                                                                                                         | `15`                                                        | Integer        |
| `DROP_ITEM_ALIVE_MAX_HOURS`                 | DropItemAliveMaxHours                | Time it takes for items to despawn in hours                                                                                                                       | `1.000000`                                                  | Float          |
| `AUTO_RESET_GUILD_NO_ONLINE_PLAYERS`        | bAutoResetGuildNoOnlinePlayers       | Automatically reset guild when no players are online                                                                                                              | `false`                                                     | `false`/`true` |
| `AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS`   | AutoResetGuildTimeNoOnlinePlayers    | Time to automatically reset guild when no players are online                                                                                                      | `72.000000`                                                 | Float          |
| `GUILD_PLAYER_MAX_NUM`                      | GuildPlayerMaxNum                    | Max player of Guild                                                                                                                                               | `20`                                                        | Integer        |
| `PAL_EGG_DEFAULT_HATCHING_TIME`             | PalEggDefaultHatchingTime            | Time(h) to incubate massive egg                                                                                                                                   | `72.000000`                                                 | Float          |
| `WORK_SPEED_RATE`                           | WorkSpeedRate                        | Work speed multiplier                                                                                                                                             | `1.000000`                                                  | Float          |
| `IS_MULTIPLAY`                              | bIsMultiplay                         | Enable multiplayer                                                                                                                                                | `false`                                                     | `false`/`true` |
| `IS_PVP`                                    | bIsPvP                               | Enable PVP                                                                                                                                                        | `false`                                                     | `false`/`true` |
| `CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP` | bCanPickupOtherGuildDeathPenaltyDrop | Allow players from other guilds to pick up death penalty items                                                                                                    | `false`                                                     | `false`/`true` |
| `ENABLE_NON_LOGIN_PENALTY`                  | bEnableNonLoginPenalty               | Enable non-login penalty                                                                                                                                          | `true`                                                      | `false`/`true` |
| `ENABLE_FAST_TRAVEL`                        | bEnableFastTravel                    | Enable fast travel                                                                                                                                                | `true`                                                      | `false`/`true` |
| `IS_START_LOCATION_SELECT_BY_MAP`           | bIsStartLocationSelectByMap          | Enable selecting of start location                                                                                                                                | `true`                                                      | `false`/`true` |
| `EXIST_PLAYER_AFTER_LOGOUT`                 | bExistPlayerAfterLogout              | Toggle for deleting players when they log off                                                                                                                     | `false`                                                     | `false`/`true` |
| `ENABLE_DEFENSE_OTHER_GUILD_PLAYER`         | bEnableDefenseOtherGuildPlayer       | Allows defense against other guild players                                                                                                                        | `false`                                                     | `false`/`true` |
| `COOP_PLAYER_MAX_NUM`                       | CoopPlayerMaxNum                     | Maximum number of players in a guild                                                                                                                              | `4`                                                         | Integer        |
| `MAX_PLAYERS`                               | ServerPlayerMaxNum                   | Maximum number of people who can join the server                                                                                                                  | `32`                                                        | Integer        |
| `SERVER_NAME`                               | ServerName                           | Server name                                                                                                                                                       | `thejcpalma-docker-generated-###RANDOM###`                  | Integer        |
| `SERVER_DESCRIPTION`                        | ServerDescription                    | Server description                                                                                                                                                | `Palworld Dedicated Server running in Docker by thejcpalma` | String         |
| `ADMIN_PASSWORD`                            | AdminPassword                        | Set the server admin password.                                                                                                                                    | `adminPasswordHere`                                         | String         |
| `SERVER_PASSWORD`                           | ServerPassword                       | Set the server password.                                                                                                                                          | `serverPasswordHere`                                        | String         |
| `PUBLIC_PORT`                               | PublicPort                           | Public port number                                                                                                                                                | `8211`                                                      | Integer        |
| `PUBLIC_IP`                                 | PublicIP                             | Public IP or FQDN                                                                                                                                                 |                                                             | String         |
| `RCON_ENABLED`                              | RCONEnabled                          | Enable RCON - Use ADMIN_PASSWORD to login                                                                                                                         | `false`                                                     | `false`/`true` |
| `RCON_PORT`                                 | RCONPort                             | Port number for RCON                                                                                                                                              | `25575`                                                     | Integer        |
| `REGION`                                    | Region                               | Area                                                                                                                                                              |                                                             | String         |
| `USEAUTH`                                   | bUseAuth                             | Use authentication                                                                                                                                                | `true`                                                      | `false`/`true` |
| `BAN_LIST_URL`                              | BanListURL                           | Which ban list to use                                                                                                                                             | `https://api.palworldgame.com/api/banlist.txt`              | String         |
| `SHOW_PLAYER_LIST`                          | bShowPlayerList                      | Make the player list public on a community server                                                                                                                 | `false`                                                     | `false`/`true` |


## Webhook Settings

This section lists all the settings for the webhooks.

### Webhook Configuration

The following environment variables are used to configure the webhook:

| Variable          | Description                          | Default Value              | Allowed Values    |
| ----------------- | ------------------------------------ | -------------------------- | ----------------- |
| `WEBHOOK_ENABLED` | Determines if the webhook is enabled | `false`                    | `false`/`true`    |
| `WEBHOOK_URL`     | The URL for the webhook              | `YOUR-WEBHOOK-URL-IN-HERE` | Valid webhook URL |


### Webhook Messages

> [!WARNING]
>
> Please note that Hex-Colors (Example #eeeeee) are not supported. Instead, use the Decimal representation of the color.
> To convert a Hex-Color to its Decimal representation, you can use online tools such as [SpyColor](https://www.spycolor.com/).
> Search for the Hex-Color and use the Decimal representation of that color. Using Hex-Colors will cause errors!

Each webhook message is customizable through environment variables.
Each message consists of a title, description, and color:
 - The title is the main heading of the message
 - The description provides additional information
 - The color is a visual indicator.

Colors are represented in their decimal form.

Emojis in Discord Webhooks:
 - Discord webhooks support both default emojis and custom emojis.
 - Default emojis are available on all servers. You can use them directly in your messages.
 - Custom emojis are specific to the server they were added on. To use a custom emoji in a webhook message, it must exist on the server that the webhook is linked to.
 - Remember to use the correct syntax for each type of emoji.
 - Use [this guide](https://docs.formie.pro/how-to-find-emoji-ids) to find the correct ID for the emoji you want to use.

Mentions in Discord Webhooks:
 - Discord webhooks support Mentions in the format `<@user_id>`.
 - Add it to any message (title or description) to mention a user in the message.
 - Use [this guide](https://support.discord.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID) to find the correct ID for the user.

Below are the environment variables for each type of webhook message:

#### **- Start server message**

| Variable                    | Description                           | Default Value                        |
| --------------------------- | ------------------------------------- | ------------------------------------ |
| `WEBHOOK_START_TITLE`       | The title for the start message       | `:white_check_mark: Starting server` |
| `WEBHOOK_START_DESCRIPTION` | The description for the start message | `Server is starting`                 |
| `WEBHOOK_START_COLOR`       | The color for the start message       | `65280`                              |


#### **- Stop server message**

| Variable                   | Description                          | Default Value                     |
| -------------------------- | ------------------------------------ | --------------------------------- |
| `WEBHOOK_STOP_TITLE`       | The title for the stop message       | `:octagonal_sign: Stopped server` |
| `WEBHOOK_STOP_DESCRIPTION` | The description for the stop message | `Server has been stopped`         |
| `WEBHOOK_STOP_COLOR`       | The color for the stop message       | `16711680`                        |


#### **- Restart server message**

> [!NOTE]
>
> `X_MINUTES` will be replaced with the minutes passed to the restart function (`AUTO_RESTART_WARN_MINUTES` for the auto restart feature)

| Variable                          | Description                                 | Default Value                                               |
| --------------------------------- | ------------------------------------------- | ----------------------------------------------------------- |
| `WEBHOOK_RESTART_TITLE`           | The title for the restart message           | `:arrows_counterclockwise: Restarting server`               |
| `WEBHOOK_RESTART_DESCRIPTION`     | The description for the restart message     | `Server is restarting in X_MINUTES minute(s) :alarm_clock:` |
| `WEBHOOK_RESTART_NOW_DESCRIPTION` | The description for the restart now message | `Server is restarting in now! :alarm_clock:`                |
| `WEBHOOK_RESTART_COLOR`           | The color for the restart message           | `16750848`                                                  |

#### **- Install server message**

| Variable                      | Description                             | Default Value               |
| ----------------------------- | --------------------------------------- | --------------------------- |
| `WEBHOOK_INSTALL_TITLE`       | The title for the install message       | `:tools: Installing server` |
| `WEBHOOK_INSTALL_DESCRIPTION` | The description for the install message | `Server is being installed` |
| `WEBHOOK_INSTALL_COLOR`       | The color for the install message       | `1644912`                   |

#### **- Update server message**

| Variable                     | Description                            | Default Value             |
| ---------------------------- | -------------------------------------- | ------------------------- |
| `WEBHOOK_UPDATE_TITLE`       | The title for the update message       | `:new: Updating server`   |
| `WEBHOOK_UPDATE_DESCRIPTION` | The description for the update message | `Server is being updated` |
| `WEBHOOK_UPDATE_COLOR`       | The color for the update message       | `16776960`                |

#### **- Update and validation server message**

| Variable                              | Description                                           | Default Value                                            |
| ------------------------------------- | ----------------------------------------------------- | -------------------------------------------------------- |
| `WEBHOOK_UPDATE_VALIDATE_TITLE`       | The title for the update and validation message       | `:ballot_box_with_check: Updating and validating server` |
| `WEBHOOK_UPDATE_VALIDATE_DESCRIPTION` | The description for the update and validation message | `Server is being updated and validated`                  |
| `WEBHOOK_UPDATE_VALIDATE_COLOR`       | The color for the update and validation message       | `16776960`                                               |

#### **- Player join message**

> [!NOTE]
> `PLAYER_NAME` is a variable that will be replaced with the name of the player that left the server.
> 
> `PLAYER_UID` is a variable that will be replaced with the UID of the player that joined the server.
> 
> `PLAYER_STEAM_UID` is a variable that will be replaced with the Steam UID of the player that joined the server.
> 
> Use it on the title and/or description to show the player's name.

> [!WARNING]
>
> When **Steam ID is invalid** and **you have `PLAYER_STEAM_UID` in your title or description message**, the webhook message will always contain the possible Steam profiles associated with the player and change `PLAYER_STEAM_UID` to `###INVALID_STEAM_UID###`.

| Variable                          | Description                          | Default Value          |
| --------------------------------- | ------------------------------------ | ---------------------- |
| `WEBHOOK_PLAYER_JOIN_TITLE`       | The title for the join message       | `:mage: Player joined` |
| `WEBHOOK_PLAYER_JOIN_DESCRIPTION` | The description for the join message | `### PLAYER_NAME`      |
| `WEBHOOK_PLAYER_JOIN_COLOR`       | The color for the join message       | `1728512`              |

> [!TIP]
>
> You can use the `PLAYER_STEAM_UID` variable to link the Steam profile of the player that joined the server on the **description** (doesn't work on the title).
> E.g.:
> - `### PLAYER_NAME (Steam: [PLAYER_STEAM_UID](https://steamcommunity.com/profiles/PLAYER_STEAM_UID))` will show the player's name and link to their Steam profile.
> - `### [PLAYER_NAME](https://steamcommunity.com/profiles/PLAYER_STEAM_UID)` will show the player's name and their UID.

#### **- Player leave message**

> [!NOTE]
> `PLAYER_NAME` is a variable that will be replaced with the name of the player that left the server.
> 
> `PLAYER_UID` is a variable that will be replaced with the UID of the player that joined the server.
> 
> `PLAYER_STEAM_UID` is a variable that will be replaced with the Steam UID of the player that joined the server.
> 
> Use it on the title and/or description to show the player's name.

> [!WARNING]
>
> When **Steam ID is invalid** and **you have `PLAYER_STEAM_UID` in your title or description message**, the webhook message will always contain the possible Steam profiles associated with the player and change `PLAYER_STEAM_UID` to `###INVALID_STEAM_UID###`.

| Variable                           | Description                           | Default Value        |
| ---------------------------------- | ------------------------------------- | -------------------- |
| `WEBHOOK_PLAYER_LEAVE_TITLE`       | The title for the leave message       | `:dash: Player left` |
| `WEBHOOK_PLAYER_LEAVE_DESCRIPTION` | The description for the leave message | `### PLAYER_NAME`    |
| `WEBHOOK_PLAYER_LEAVE_COLOR`       | The color for the leave message       | `6291482`            |

> [!TIP]
>
> You can use the `PLAYER_STEAM_UID` variable to link the Steam profile of the player that joined the server on the **description** (doesn't work on the title).
> 
> E.g.:
> - `### PLAYER_NAME (Steam: [PLAYER_STEAM_UID](https://steamcommunity.com/profiles/PLAYER_STEAM_UID))` will show the player's name and link to their Steam profile.
> - `### [PLAYER_NAME](https://steamcommunity.com/profiles/PLAYER_STEAM_UID)` will show the player's name and their UID.

[Back to main](../README.md#environment-variables)
