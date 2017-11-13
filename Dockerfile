### ### ### ### ### ### ### ### ###
# Builder layer

FROM node:6-alpine as ghost-builder

RUN \
    apk update && apk upgrade                           && \
    echo                                                && \
    echo "--- Install ghost-cli --- "; echo             && \
    npm install --loglevel=error -g ghost-cli           ;

ENV GHOST_VERSION="1.17.1"                              \
    GHOST_INSTALL="/var/lib/ghost"                      \
    GHOST_CONTENT="/var/lib/ghost/content"              \
    GHOST_USER="node"

# Set default directory
WORKDIR $GHOST_INSTALL

# Run SQLite as database
RUN \
    ghost install "$GHOST_VERSION" \
        --db sqlite3 --no-prompt \
        --no-stack --no-setup \
        --dir "$GHOST_INSTALL"                          && \
    ghost config --ip 0.0.0.0 \
        --port 2368 --no-prompt --db sqlite3 \
        --url http://localhost:2368 \
        --dbpath "$GHOST_CONTENT/data/ghost.db"         && \
    ghost config paths.contentPath "$GHOST_CONTENT"     ;

COPY run-ghost.sh $GHOST_INSTALL

# Here we could add custom themes within the Docker image

# Keeping Original GhostContent to be copied into the mounted volume (if empty)
RUN cp -r "$GHOST_CONTENT" "$GHOST_INSTALL/content.bck" ;


### ### ### ### ### ### ### ### ###
# Final image
# No tzdata as it's not working on alpine3.4 (from node6)

FROM node:6-alpine
LABEL maintainer="Marco Mornati <marco@mornati.net>"

RUN apk update && apk upgrade                           && \
    apk add --no-cache tini                             && \
    rm -rf /var/cache/apk/*                             ;

ENV GHOST_VERSION="1.17.1"                              \
    GHOST_INSTALL="/var/lib/ghost"                      \
    GHOST_CONTENT="/var/lib/ghost/content"              \
    GHOST_USER="node"

# Install Ghost
COPY --from=ghost-builder --chown=node $GHOST_INSTALL $GHOST_INSTALL

USER $GHOST_USER
ENV HOME $GHOST_INSTALL
ENV PATH="${GHOST_INSTALL}/current/node_modules/knex-migrator/bin:${PATH}"

# Define working directory
WORKDIR $GHOST_INSTALL

# Set environment variables
ENV NODE_ENV production

# Expose ports
EXPOSE 2368

# HealthCheck
HEALTHCHECK CMD wget -q -s http://localhost:2368 || exit 1

# Define mountable directories
VOLUME [ "${GHOST_CONTENT}", "${GHOST_INSTALL}/config.override.json" ]

# Define default command
CMD [ "/sbin/tini", "--", "/bin/sh", "-c", "/bin/sh ${GHOST_INSTALL}/run-ghost.sh" ]
