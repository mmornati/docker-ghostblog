#
# Base Docker to run a SQLite Ghost Blog
#

#Build step for Ghost Image
FROM node:6 as ghost-builder
RUN npm install --loglevel=error -g knex-migrator ghost-cli

ENV GHOST_VERSION 1.16.2
RUN addgroup --system -gid 1276 ghost && \
    adduser --system --home /ghost --ingroup ghost --uid 1276 ghost && \
    mkdir /ghost/blog && \
    cd /ghost/blog && \
    ghost install $GHOST_VERSION --local && \
    echo $GHOST_VERSION > /ghost/version

COPY run-ghost.sh /ghost
COPY config.production.json /ghost/blog
COPY config.development.json /ghost/blog

#Create the Docker Ghost Blog
FROM node:6-alpine
LABEL maintainer="Marco Mornati <marco@mornati.net>"

# Install Ghost
RUN addgroup -S -g 1276 ghost && \
    adduser -S -h /ghost -G ghost -u 1276 ghost

COPY --from=ghost-builder /ghost /ghost
RUN chown -R ghost:ghost /ghost && \
    mkdir /ghost-override && \
    chown -R ghost:ghost /ghost-override

#RUN npm install --loglevel=error -g knex-migrator ghost-cli

USER ghost
ENV HOME /ghost

# Define working directory.
WORKDIR /ghost

# Set environment variables.
ENV NODE_ENV production

# Expose ports.
EXPOSE 2368

#HealthCheck
HEALTHCHECK --interval=5m --timeout=3s \
  CMD echo "GET / HTTP/1.1" | nc -v localhost 2368 || exit 1

# Define mountable directories.
VOLUME ["/ghost-override"]

# Define default command.
CMD ["/bin/sh", "/ghost/run-ghost.sh"]
