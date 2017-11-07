#
# Base Docker to run a SQLite Ghost Blog
#

#Build step for Ghost Image
FROM node:6-alpine as ghost-builder
RUN npm install --loglevel=error -g ghost-cli

ENV GHOST_VERSION 1.17.0
ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content
ENV GHOST_USER node

WORKDIR $GHOST_INSTALL
RUN ghost install "$GHOST_VERSION" --db sqlite3 --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"; \
	  ghost config --ip 0.0.0.0 --port 2368 --no-prompt --db sqlite3 --url http://localhost:2368 --dbpath "$GHOST_CONTENT/data/ghost.db"; \
	  ghost config paths.contentPath "$GHOST_CONTENT"; 

COPY run-ghost.sh $GHOST_INSTALL

#Create the Docker Ghost Blog
FROM node:6-alpine
LABEL maintainer="Marco Mornati <marco@mornati.net>"

ENV GHOST_VERSION 1.17.0
ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content
ENV GHOST_USER node

RUN npm install --loglevel=error -g ghost-cli

# Install Ghost
COPY --from=ghost-builder --chown=node $GHOST_INSTALL $GHOST_INSTALL

USER $GHOST_USER
ENV HOME $GHOST_INSTALL
ENV PATH="${GHOST_INSTALL}/current/node_modules/knex-migrator/bin:${PATH}"

#Keeping Original GhostContent to be copied into the mounted volume (if empty)
RUN cp -r "$GHOST_CONTENT" "$GHOST_INSTALL/content.bck";

# Define working directory.
WORKDIR $GHOST_INSTALL

# Set environment variables.
ENV NODE_ENV production

# Expose ports.
EXPOSE 2368

#HealthCheck
HEALTHCHECK --interval=5m --timeout=3s \
  CMD echo "GET / HTTP/1.1" | nc -v localhost 2368 || exit 1

# Define mountable directories.
VOLUME [$GHOST_CONTENT]

# Define default command.
CMD ["/bin/sh", "-c", "/bin/sh ${GHOST_INSTALL}/run-ghost.sh"]
