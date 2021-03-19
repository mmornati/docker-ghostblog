# https://docs.ghost.org/supported-node-versions/
# https://github.com/nodejs/LTS
#
# Update Node version on lines: 12 and 61
# Update Ghost version on lines: 10 and 58

### ### ### ### ### ### ### ### ###
# Builder layer

ARG GHOST_VERSION="4.1.0"

FROM node:12-alpine3.12 as ghost-builder
ARG GHOST_VERSION
ENV GHOST_INSTALL="/var/lib/ghost"          \
    GHOST_CONTENT="/var/lib/ghost/content"  \
    GHOST_USER="node"

# Set default directory
WORKDIR $GHOST_INSTALL

#Install required packages
RUN set -eux                            && \
    apk update && apk add py-pip make   && \
    chown node:node "$GHOST_INSTALL"

USER $GHOST_USER

# Change base folder for the NPM installs (dtrace_provider is somehow failing because of this)
RUN mkdir /home/node/.npm-global
ENV PATH=/home/node/.npm-global/bin:$PATH
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

# We use SQLite as our DB. Force install "sqlite3" manually since it's an optional dependency of "ghost"
RUN npm install --loglevel=error -g ghost-cli   && \
    echo "--- INSTALLING GHOST ${GHOST_VERSION} INTO ${GHOST_INSTALL} FOLDER ---" && \
    ghost install "$GHOST_VERSION"                 \
        --db sqlite3 --no-prompt                   \
        --no-stack --no-setup                      \
        --dir "$GHOST_INSTALL"                  && \
    echo "---  CONFIGURING GHOST  ---"          && \
    ghost config --ip 0.0.0.0                      \
        --port 2368 --no-prompt --db sqlite3       \
        --url http://localhost:2368                \
        --dbpath "$GHOST_CONTENT/data/ghost.db" && \
    ghost config paths.contentPath "$GHOST_CONTENT"

# Copy entrypoint script
COPY --chown=node run-ghost.sh $GHOST_INSTALL

RUN set -eux                                    && \
    chmod +x "$GHOST_INSTALL/run-ghost.sh"      && \
    echo "--- CREATING CONTENT TEMPLATE  ---"   && \
    cp -r "$GHOST_CONTENT" "$GHOST_INSTALL/content.bck"


### ### ### ### ### ### ### ### ###
# Final image

FROM node:12-alpine3.12
LABEL maintainer="Marco Mornati <marco@mornati.net>"
ARG GHOST_VERSION
ENV GHOST_INSTALL="/var/lib/ghost"           \
    GHOST_CONTENT="/var/lib/ghost/content"   \
    GHOST_USER="node"                        \
    HOME="$GHOST_INSTALL"                    \
    TZ="Etc/UTC"                             \
    NODE_ENV="production"

RUN set -eux                                    && \
    apk update                                  && \
    apk add --no-cache tzdata ca-certificates   && \
    update-ca-certificates                      && \
    rm -rf /var/cache/apk/*

# Install Ghost
COPY --from=ghost-builder --chown=node:node $GHOST_INSTALL $GHOST_INSTALL

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
