#
# Ghost blog.mornati.net
#

#Build step for Ghost Plugins
FROM mhart/alpine-node:6.11.3 as plugin-builder
WORKDIR /builder
ADD https://github.com/mmornati/ghost-cloudinary-store/archive/update_ghost_1.0.0.zip .
RUN unzip update_ghost_1.0.0.zip && \
  mv ghost-cloudinary-store-update_ghost_1.0.0 ghost-cloudinary-store && \
  cd ghost-cloudinary-store && \ 
  npm install --production --loglevel=error

#Build step for Ghost Image
FROM node:6.11.3 as ghost-builder
RUN npm install --loglevel=error -g knex-migrator ghost-cli

WORKDIR /ghost

COPY run-ghost.sh /ghost
COPY migrate-database.sh /ghost

ENV GHOST_VERSION 1.8.5
RUN adduser -h /ghost -u 1276 -D ghost ghost && \
    mkdir /ghost/blog && \
    cd /ghost/blog && \
    ghost install $GHOST_VERSION --local

COPY config.production.json /ghost/blog
COPY config.development.json /ghost/blog

COPY MigratorConfig.js /ghost/blog
#Install Cloudinary Store into the internal modules
COPY --from=plugin-builder /builder/ghost-cloudinary-store /ghost/blog/versions/$GHOST_VERSION/core/server/adapters/storage/ghost-cloudinary-store

#Create the Docker Ghost Blog
FROM mhart/alpine-node:6.11.3
LABEL maintainer="Marco Mornati <marco@mornati.net>"

# Install Ghost
COPY --from=ghost-builder /ghost /ghost
RUN adduser -h /ghost -u 1276 -D ghost ghost && \
  chown -R ghost:ghost /ghost && \
  mkdir /ghost-override && \
  chown -R ghost:ghost /ghost-override

RUN npm install --loglevel=error -g knex-migrator ghost-cli

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
  CMD curl -f http://localhost:2368/ || exit 1

# Define mountable directories.
VOLUME ["/ghost-override"]

# Define default command.
CMD ["/bin/sh", "/ghost/run-ghost.sh"]
