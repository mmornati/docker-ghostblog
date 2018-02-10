### ### ### ### ### ### ### ### ###
# Builder layer
# Update Ghost + Node version at lines: 5-7 and 45-48

FROM node:8.9.4-alpine as ghost-builder

ENV GHOST_VERSION="1.21.1"                                  \
    GHOST_INSTALL="/var/lib/ghost"                          \
    GHOST_CONTENT="/var/lib/ghost/content"                  \
    GHOST_USER="node"

# Set default directory
WORKDIR $GHOST_INSTALL

# We use SQLite as our DB. Force install "sqlite3" manually since it's an optional dependency of "ghost"
RUN set -eux                                                && \
    apk update && apk upgrade                               && \
    echo "---             S P A C E R             ---"      && \
    npm install --loglevel=error -g ghost-cli               && \
    echo "---             S P A C E R             ---"      && \
    ghost install "$GHOST_VERSION"  \
        --db sqlite3 --no-prompt    \
        --no-stack --no-setup       \
        --dir "$GHOST_INSTALL"                              && \
    echo "---             S P A C E R             ---"      && \
    ghost config --ip 0.0.0.0                   \
        --port 2368 --no-prompt --db sqlite3    \
        --url http://localhost:2368             \
        --dbpath "$GHOST_CONTENT/data/ghost.db"             && \
    echo "---             S P A C E R             ---"      && \
    ghost config paths.contentPath "$GHOST_CONTENT"         ;

# Copy entrypoint script
COPY run-ghost.sh $GHOST_INSTALL

RUN set -eux                                                && \
    chmod +x "$GHOST_INSTALL/run-ghost.sh"                  && \
    echo "---             S P A C E R             ---"      && \
    cp -r "$GHOST_CONTENT" "$GHOST_INSTALL/content.bck"     ;


### ### ### ### ### ### ### ### ###
# Final image

FROM node:8.9.4-alpine
LABEL maintainer="Marco Mornati <marco@mornati.net>"

ENV GHOST_VERSION="1.20.3"                                  \
    GHOST_INSTALL="/var/lib/ghost"                          \
    GHOST_CONTENT="/var/lib/ghost/content"                  \
    GHOST_USER="node"                                       \
    HOME="$GHOST_INSTALL"                                   \
    TZ="Etc/UTC"                                            \
    NODE_ENV="production"

RUN set -eux                                                && \
    apk update && apk upgrade                               && \
    apk add --no-cache tzdata                               && \
    rm -rf /var/cache/apk/*                                 ;

# Install Ghost
COPY --from=ghost-builder --chown=node $GHOST_INSTALL $GHOST_INSTALL

USER $GHOST_USER

ENV PATH="${GHOST_INSTALL}/current/node_modules/knex-migrator/bin:${PATH}"

# Define working directory
WORKDIR $GHOST_INSTALL

# Expose ports
EXPOSE 2368

# HealthCheck
HEALTHCHECK CMD wget -q -s http://localhost:2368 || exit 1

# Define mountable directories
VOLUME [ "${GHOST_CONTENT}", "${GHOST_INSTALL}/config.override.json", "/etc/timezone" ]

# Define Entry Point to manage the Init and the upgrade
ENTRYPOINT [ "./run-ghost.sh" ]

# Define default command
CMD [ "node", "current/index.js" ]
