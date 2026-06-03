#!/bin/sh
# ----------------------------------
# Pelican Panel — MediaMTX Entrypoint
# Yolk : mediamtx (Alpine + official binary)
# ----------------------------------
# Wings injects the startup command into the STARTUP environment variable.
# Placeholders {{VARIABLE}} are substituted with values from other environment
# variables passed to the container.
# ----------------------------------

cd /home/container

# ── Banner ───────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         MediaMTX  —  Pelican Panel Edition                   ║"
echo "║   RTMP ingest OBS  |  WebRTC / LL-HLS  |  Pure Passthrough   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ── Binary verification ──────────────────────────────────────────────────────
if [ ! -f /usr/local/bin/mediamtx ]; then
    echo "[ERROR] MediaMTX binary not found in /usr/local/bin/"
    echo "        The image may be corrupted. Please reinstall the server."
    exit 1
fi

MTX_VER=$(/usr/local/bin/mediamtx --version 2>/dev/null | head -1 || echo "unknown")
echo "[INFO] MediaMTX ${MTX_VER}"

# ── Configuration initialization if absent ──────────────────────────────────
# On first startup, /home/container/mediamtx.yml does not exist yet.
# We copy the default config from /defaults/ (embedded in the image).
if [ ! -f /home/container/mediamtx.yml ]; then
    echo "[INFO] mediamtx.yml missing — copying default configuration..."
    cp /defaults/mediamtx.yml /home/container/mediamtx.yml
    echo "[INFO] mediamtx.yml created in /home/container/ (editable via panel)"
else
    echo "[INFO] Configuration: /home/container/mediamtx.yml"
fi

# ── Port summary ─────────────────────────────────────────────────────────────
echo ""
echo "[INFO] Configured ports:"
echo "       RTMP  (OBS/Streamlabs ingest)  → ${MTX_RTMPADDRESS:-:1935}"
echo "       HLS   (web interface)          → ${MTX_HLSADDRESS:-:8888}"
echo "       WebRTC HTTP (signaling)        → ${MTX_WEBRTCADDRESS:-:8889}"
echo "       WebRTC ICE UDP                 → :${WEBRTC_UDP_PORT:-8189}"
echo ""
echo "[INFO] WebRTC public IP (ICE) → ${MTX_WEBRTCADDITIONALHOSTS:-(not defined — WebRTC may fail)}"
echo ""

# ── Resolution of Pelican STARTUP command ────────────────────────────────────
# Wings passes the command in the form:
#   /usr/local/bin/mediamtx /home/container/mediamtx.yml
# with placeholders {{PORT}}, etc. replaced by environment variables.
MODIFIED_STARTUP=$(eval echo "$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')")
echo "[INFO] Startup: ${MODIFIED_STARTUP}"
echo ""
echo "────────────────────────────────────────────────────────────────"
echo ""

# ── Startup ──────────────────────────────────────────────────────────────────
# exec replaces the shell with mediamtx (direct PID under tini)
# SIGINT/SIGTERM signals from Wings are thus transmitted directly.
exec ${MODIFIED_STARTUP}
