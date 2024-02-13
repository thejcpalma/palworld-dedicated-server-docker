# shellcheck disable=SC2148

# Start supercronic and load crons
function setup_crons() {
    echo "" > cronlist   
    # Auto backup cron job 
    if [[ -n ${BACKUP_ENABLED} ]] && [[ ${BACKUP_ENABLED,,} == "true" ]]; then
        echo "${BACKUP_CRON_EXPRESSION} backupmanager create" >> cronlist
    fi
    # Auto update cron job
    if [[ -n ${AUTO_UPDATE_ENABLED} ]] && [[ ${AUTO_UPDATE_ENABLED,,} == "true" ]]; then
        echo "${AUTO_UPDATE_CRON_EXPRESSION} update" >> cronlist
    fi
    # Auto restart cron job
    if [[ -n ${AUTO_RESTART_ENABLED} ]] && [[ ${AUTO_RESTART_ENABLED,,} == "true" ]]; then
        echo "${AUTO_RESTART_CRON_EXPRESSION} restart ${AUTO_RESTART_WARN_MINUTES}" >> cronlist
    fi

    /usr/local/bin/supercronic -passthrough-logs cronlist &

    echo_success ">>> Supercronic started"
}
