#!/bin/bash
# ----------------------------------------------------------
# Mealie – Pelican Panel Entrypoint
#
# Wings injects:
#   STARTUP      → the command to run (with {{VAR}} placeholders)
#   SERVER_PORT  → the allocated port
# ----------------------------------------------------------
cd /home/container

# ----------------------------------------------------------
# Forward Pelican's SERVER_PORT to Mealie's APP_PORT
# ----------------------------------------------------------
export APP_PORT="${SERVER_PORT}"

# ----------------------------------------------------------
# Ensure data directories exist
# Wings mounts the persistent volume on /home/container/data
# Mealie will find its SQLite DB and assets there.
# ----------------------------------------------------------
mkdir -p /home/container/data

# ----------------------------------------------------------
# Resolve {{PLACEHOLDER}} variables injected by Wings
# into a real shell command, then execute it.
# ----------------------------------------------------------
MODIFIED_STARTUP=$(eval echo "$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')")
echo "[mealie-yolk] Starting: ${MODIFIED_STARTUP}"

exec ${MODIFIED_STARTUP}