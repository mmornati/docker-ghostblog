#
# Base Docker to run a SQLite Ghost Blog
#

#Build step for Ghost Image
FROM node:6 as ghost-builder
RUN npm install --loglevel=error -g knex-migrator ghost-cli

ENV GHOST_VERSION 1.16.2
ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content
ENV GHOST_USER ghost

RUN addgroup --system -gid 1276 $GHOST_USER && \
    adduser --system --home $GHOST_INSTALL --ingroup $GHOST_USER --uid 1276 $GHOST_USER && \
    cd $GHOST_INSTALL && \
    ghost install $GHOST_VERSION --local && \
    echo $GHOST_VERSION > $GHOST_INSTALL/version

COPY run-ghost.sh $GHOST_INSTALL
COPY config.production.json $GHOST_INSTALL
COPY config.development.json $GHOST_INSTALL

#Create the Docker Ghost Blog
FROM node:6-alpine
LABEL maintainer="Marco Mornati <marco@mornati.net>"

ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content
ENV GHOST_USER ghost

# Install Ghost
RUN addgroup -S -g 1276 $GHOST_USER && \
    adduser -S -h $GHOST_INSTALL -G $GHOST_USER -u 1276 $GHOST_USER

COPY --from=ghost-builder $GHOST_INSTALL $GHOST_INSTALL
RUN chown -R $GHOST_USER:$GHOST_USER $GHOST_INSTALL

USER $GHOST_USER
ENV HOME $GHOST_INSTALL

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
