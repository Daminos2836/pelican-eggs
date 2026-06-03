# ----------------------------------
# Pelican Panel Yolk Dockerfile
# Application : MediaMTX
# ----------------------------------
#
# Multi-stage architecture:
#   Stage 1 (mediamtx) : official image — extracts the /mediamtx binary and
#                        default config /mediamtx.yml
#   Stage 2 (final)    : Alpine as lightweight runtime OS, copies binary,
#                        installs tini, creates "container" user required by Wings
#
# The official bluenviron/mediamtx:1 image is based on scratch (no shell,
# no user, no package manager). Therefore a runtime OS is needed to satisfy
# Pelican constraints (user "container", /home/container, bash entrypoint).
# ----------------------------------

FROM        bluenviron/mediamtx:1 AS mediamtx

# Final stage: Alpine — minimal, secure, native multi-arch
FROM        --platform=$TARGETOS/$TARGETARCH alpine:3.20

LABEL       org.opencontainers.image.title="mediamtx-yolk" \
            org.opencontainers.image.source="https://github.com/bluenviron/mediamtx" \
            org.opencontainers.image.licenses=MIT \
            org.opencontainers.image.description="Yolk MediaMTX for Pelican Panel - RTMP/WebRTC/LL-HLS passthrough"

# Copy MediaMTX binary and default config from the official image
COPY        --from=mediamtx /mediamtx     /usr/local/bin/mediamtx
COPY        --from=mediamtx /mediamtx.yml /defaults/mediamtx.yml

# Installation of system packages:
# - tini           : minimal PID1 init, proper SIGINT/SIGTERM handling and zombie reaping
# - ca-certificates: SSL certificates (for HTTPS, external auth)
# - tzdata         : timezones
RUN         apk add --no-cache \
                tini \
            # Make binary executable
            && chmod +x /usr/local/bin/mediamtx \
            # Create "container" user — REQUIRED for Pelican/Wings
            # Home directory MUST be /home/container
            && addgroup -S container \
            && adduser -S -D -h /home/container -s /bin/sh -G container container \
            # Create working directory with correct permissions
            && mkdir -p /home/container \
            && chown -R container:container /home/container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

# SIGINT to stop mediamtx cleanly (equivalent to ^C)
STOPSIGNAL  SIGINT

# Copy entrypoint script (resolves STARTUP injected by Wings)
COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh

# tini as PID1:
#   -g : propagates signals to the entire process group (not only direct child)
#   -- : separator between tini arguments and executed command
ENTRYPOINT  ["/sbin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
