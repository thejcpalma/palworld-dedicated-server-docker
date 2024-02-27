# shellcheck disable=SC2148

# shellcheck source=/dev/null
source "${SERVER_DIR}"/scripts/utils/logs.sh

# Start supercronic and load crons
function setup_crons() {
    echo "" > cronlist
    # Auto backup cron job
    if [[ -n ${BACKUP_ENABLED} ]] && [[ ${BACKUP_ENABLED,,} == "true" ]]; then
        echo "${BACKUP_CRON_EXPRESSION} ${SERVER_DIR}/scripts/backup_manager.sh create" >> cronlist
    fi
    # Auto update cron job
    if [[ -n ${AUTO_UPDATE_ENABLED} ]] && [[ ${AUTO_UPDATE_ENABLED,,} == "true" ]]; then
        echo "${AUTO_UPDATE_CRON_EXPRESSION} ${SERVER_DIR}/scripts/server_manager.sh update ${AUTO_UPDATE_WARN_MINUTES}" >> cronlist
    fi
    # Auto restart cron job
    if [[ -n ${AUTO_RESTART_ENABLED} ]] && [[ ${AUTO_RESTART_ENABLED,,} == "true" ]]; then
        echo "${AUTO_RESTART_CRON_EXPRESSION} ${SERVER_DIR}/scripts/server_manager.sh restart ${AUTO_RESTART_WARN_MINUTES}" >> cronlist
    fi

    (sleep 5 && /usr/local/bin/supercronic -passthrough-logs cronlist) &

    (sleep 5 && log_success ">>> Supercronic started") &
}
