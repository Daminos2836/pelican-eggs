# ----------------------------------------------------------
# Mealie – Pelican Panel Yolk
# Base: official Mealie image (no fork needed)
#
# Updates: change MEALIE_VERSION below and rebuild.
# ----------------------------------------------------------

ARG MEALIE_VERSION=latest
FROM ghcr.io/mealie-recipes/mealie:${MEALIE_VERSION}

LABEL org.opencontainers.image.title="mealie-yolk" \
    org.opencontainers.image.description="Mealie adapted for Pelican Panel" \
    org.opencontainers.image.licenses=MIT

# ----------------------------------------------------------
# Switch to root to make system-level changes
# ----------------------------------------------------------
USER root

# ----------------------------------------------------------
# PELICAN REQUIREMENT: user must be named "container"
#                      with home at /home/container
# ----------------------------------------------------------

RUN usermod -l container abc \
    && usermod -d /home/container -m container \
    && groupmod -n container abc

# Install tini (required by Pelican as PID 1)
RUN apt-get update \
    && apt-get install --no-install-recommends -y tini \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------
# PELICAN REQUIREMENT: entrypoint.sh at /entrypoint.sh
#                      run by tini as PID 1
# ----------------------------------------------------------
COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ----------------------------------------------------------
# PELICAN REQUIREMENT: WORKDIR = /home/container
# ----------------------------------------------------------
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Mealie expects DATA_DIR here; Wings volume mounts here too
ENV DATA_DIR=/home/container/data

# Remove the original healthcheck — Wings handles process monitoring
HEALTHCHECK NONE

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]