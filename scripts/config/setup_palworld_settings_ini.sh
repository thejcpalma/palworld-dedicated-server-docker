#shellcheck disable=SC2148
#shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/config/utils.sh

function setup_palworld_settings_ini(){

    log_warning ">> Setting up PalWorldSettings.ini ..."

    # Create the config directory if it doesn't exist
    mkdir -p "${GAME_CONFIG_PATH}/"

    template_file=${SERVER_DIR}/scripts/config/templates/PalWorldSettings.ini.template

    # Remove the first line of the template file and remove the newlines and carriage returns
    awk 'NR==1{print;next}{printf "%s",$0}' "${template_file}" | tr -d '\r' > "${GAME_SETTINGS_FILE}"

    difficulty_options=("None" "Normal" "Difficult")
    check_and_export "list"   "Difficulty" "${DIFFICULTY}" "None" "${difficulty_options[@]}"
    check_and_export "float"  "DayTimeSpeedRate" "${DAY_TIME_SPEED_RATE}" "1.000000"
    check_and_export "float"  "NightTimeSpeedRate" "${NIGHT_TIME_SPEED_RATE}" "1.000000"
    check_and_export "float"  "ExpRate" "${EXP_RATE}" "1.000000"
    check_and_export "float"  "PalCaptureRate" "${PAL_CAPTURE_RATE}" "1.000000"
    check_and_export "float"  "PalSpawnNumRate" "${PAL_SPAWN_NUM_RATE}" "1.000000"
    check_and_export "float"  "PalDamageRateAttack" "${PAL_DAMAGE_RATE_ATTACK}" "1.000000"
    check_and_export "float"  "PalDamageRateDefense" "${PAL_DAMAGE_RATE_DEFENSE}" "1.000000"
    check_and_export "float"  "PlayerDamageRateAttack" "${PLAYER_DAMAGE_RATE_ATTACK}" "1.000000"
    check_and_export "float"  "PlayerDamageRateDefense" "${PLAYER_DAMAGE_RATE_DEFENSE}" "1.000000"
    check_and_export "float"  "PlayerStomachDecreaceRate" "${PLAYER_STOMACH_DECREASE_RATE}" "1.000000"
    check_and_export "float"  "PlayerStaminaDecreaceRate" "${PLAYER_STAMINA_DECREASE_RATE}" "1.000000"
    check_and_export "float"  "PlayerAutoHPRegeneRate" "${PLAYER_AUTO_HP_REGEN_RATE}" "1.000000"
    check_and_export "float"  "PlayerAutoHpRegeneRateInSleep" "${PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP}" "1.000000"
    check_and_export "float"  "PalStomachDecreaceRate" "${PAL_STOMACH_DECREASE_RATE}" "1.000000"
    check_and_export "float"  "PalStaminaDecreaceRate" "${PAL_STAMINA_DECREASE_RATE}" "1.000000"
    check_and_export "float"  "PalAutoHPRegeneRate" "${PAL_AUTO_HP_REGEN_RATE}" "1.000000"
    check_and_export "float"  "PalAutoHpRegeneRateInSleep" "${PAL_AUTO_HP_REGEN_RATE_IN_SLEEP}" "1.000000"
    check_and_export "float"  "BuildObjectDamageRate" "${BUILD_OBJECT_DAMAGE_RATE}" "1.000000"
    check_and_export "float"  "BuildObjectDeteriorationDamageRate" "${BUILD_OBJECT_DETERIORATION_DAMAGE_RATE}" "1.000000"
    check_and_export "float"  "CollectionDropRate" "${COLLECTION_DROP_RATE}" "1.000000"
    check_and_export "float"  "CollectionObjectHpRate" "${COLLECTION_OBJECT_HP_RATE}" "1.000000"
    check_and_export "float"  "CollectionObjectRespawnSpeedRate" "${COLLECTION_OBJECT_RESPAWN_SPEED_RATE}" "1.000000"
    check_and_export "float"  "EnemyDropItemRate" "${ENEMY_DROP_ITEM_RATE}" "1.000000"
    death_penalty_options=("None" "Item" "ItemAndEquipment" "All")
    check_and_export "list"   "DeathPenalty" "${DEATH_PENALTY}" "All" "${death_penalty_options[@]}"
    check_and_export "bool"   "bEnablePlayerToPlayerDamage" "${ENABLE_PLAYER_TO_PLAYER_DAMAGE}" "false"
    check_and_export "bool"   "bEnableFriendlyFire" "${ENABLE_FRIENDLY_FIRE}" "false"
    check_and_export "bool"   "bEnableInvaderEnemy" "${ENABLE_INVADER_ENEMY}" "true"
    check_and_export "bool"   "bActiveUNKO" "${ACTIVE_UNKO}" "false"
    check_and_export "bool"   "bEnableAimAssistPad" "${ENABLE_AIM_ASSIST_PAD}" "true"
    check_and_export "bool"   "bEnableAimAssistKeyboard" "${ENABLE_AIM_ASSIST_KEYBOARD}" "false"
    check_and_export "int"    "DropItemMaxNum" "${DROP_ITEM_MAX_NUM}" "3000"
    check_and_export "int"    "DropItemMaxNum_UNKO" "${DROP_ITEM_MAX_NUM_UNKO}" "100"
    check_and_export "int"    "BaseCampMaxNum" "${BASE_CAMP_MAX_NUM}" "128"
    check_and_export "int"    "BaseCampWorkerMaxNum" "${BASE_CAMP_WORKER_MAX_NUM}" "15"
    check_and_export "float"  "DropItemAliveMaxHours" "${DROP_ITEM_ALIVE_MAX_HOURS}" "1.000000"
    check_and_export "bool"   "bAutoResetGuildNoOnlinePlayers" "${AUTO_RESET_GUILD_NO_ONLINE_PLAYERS}" "false"
    check_and_export "float"  "AutoResetGuildTimeNoOnlinePlayers" "${AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS}" "72.000000"
    check_and_export "int"    "GuildPlayerMaxNum" "${GUILD_PLAYER_MAX_NUM}" "20"
    check_and_export "float"  "PalEggDefaultHatchingTime" "${PAL_EGG_DEFAULT_HATCHING_TIME}" "72.000000"
    check_and_export "float"  "WorkSpeedRate" "${WORK_SPEED_RATE}" "1.000000"
    check_and_export "bool"   "bIsMultiplay" "${IS_MULTIPLAY}" "false"
    check_and_export "bool"   "bIsPvP" "${IS_PVP}" "false"
    check_and_export "bool"   "bCanPickupOtherGuildDeathPenaltyDrop" "${CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP}" "false"
    check_and_export "bool"   "bEnableNonLoginPenalty" "${ENABLE_NON_LOGIN_PENALTY}" "true"
    check_and_export "bool"   "bEnableFastTravel" "${ENABLE_FAST_TRAVEL}" "true"
    check_and_export "bool"   "bIsStartLocationSelectByMap" "${IS_START_LOCATION_SELECT_BY_MAP}" "true"
    check_and_export "bool"   "bExistPlayerAfterLogout" "${EXIST_PLAYER_AFTER_LOGOUT}" "false"
    check_and_export "bool"   "bEnableDefenseOtherGuildPlayer" "${ENABLE_DEFENSE_OTHER_GUILD_PLAYER}" "false"
    check_and_export "int"    "CoopPlayerMaxNum" "${COOP_PLAYER_MAX_NUM}" "4"
    check_and_export "int"    "ServerPlayerMaxNum" "${SERVER_PLAYER_MAX_NUM}" "32"
    check_and_export "other"  "ServerName" "${SERVER_NAME}" "Default Palworld Server"
    check_and_export "other"  "ServerDescription" "${SERVER_DESCRIPTION}" "testtesttest"
    check_and_export "hidden" "AdminPassword" "${ADMIN_PASSWORD}" ""
    check_and_export "hidden" "ServerPassword" "${SERVER_PASSWORD}" ""
    check_and_export "int"    "PublicPort" "${PUBLIC_PORT}" "8211"
    check_and_export "hidden" "PublicIP" "${PUBLIC_IP}" ""
    check_and_export "bool"   "RCONEnabled" "${RCON_ENABLED}" "false"
    check_and_export "int"    "RCONPort" "${RCON_PORT}" "27015"
    check_and_export "other"  "Region" "${REGION}" ""
    check_and_export "bool"   "bUseAuth" "${USE_AUTH}" "true"
    check_and_export "other"  "BanListURL" "${BAN_LIST_URL}" ""
    check_and_export "bool"   "bShowPlayerList" "${SHOW_PLAYER_LIST}" "true"

    envsubst < "${GAME_SETTINGS_FILE}" > "${GAME_SETTINGS_FILE}.tmp" && mv "${GAME_SETTINGS_FILE}.tmp" "${GAME_SETTINGS_FILE}"

    log_success ">>> Finished setting up PalWorldSettings.ini"

}
