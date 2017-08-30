#
# Ghost blog.mornati.net
#

# Pull base image (based on Debian)
FROM node:6.10
MAINTAINER Marco Mornati <marco@mornati.net>

#Install Base package needed to install Ghost
RUN apt-get -y update
RUN apt-get -y install unzip
RUN apt-get -y install cron
RUN apt-get -y install git

# Install Ghost
RUN npm install -g knex-migrator
RUN npm install -g ghost-cli

RUN mkdir /ghost

RUN useradd ghost --home /ghost -u 1276
RUN chown -R ghost:ghost /ghost
RUN mkdir /ghost-override
RUN chown -R ghost:ghost /ghost-override

COPY run-ghost.sh /ghost
RUN chmod +x /ghost/run-ghost.sh
COPY migrate-database.sh /ghost
RUN chmod +x /ghost/migrate-database.sh

USER ghost
ENV HOME /ghost
ENV GHOST_VERSION 1.8.0
RUN mkdir /ghost/blog
RUN cd /ghost/blog && \
   ghost install $GHOST_VERSION --local

COPY config.production.json /ghost/blog
COPY config.development.json /ghost/blog

COPY MigratorConfig.js /ghost/blog


#Install Cloudinary Store into the internal modules
#RUN mkdir /ghost/blog/versions/1.0.0/core/server/adapters/storage
RUN cd /ghost/blog/versions/$GHOST_VERSION/core/server/adapters/storage && \
  git clone https://github.com/mmornati/ghost-cloudinary-store.git && \
  cd ghost-cloudinary-store && \
  git checkout update_ghost_1.0.0 && \
  npm install

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
CMD ["/ghost/run-ghost.sh"]
