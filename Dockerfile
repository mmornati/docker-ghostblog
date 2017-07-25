#
# Ghost blog.mornati.net
#

# Pull base image (based on Debian)
FROM node:6.10

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

USER ghost
ENV HOME /ghost
RUN mkdir /ghost/blog
RUN cd /ghost/blog && \
   ghost install local

#Install Cloudinary Store
#TODO: This one is not needed anymore 'cause it is into the shared volume
RUN cd /ghost && \
  git clone https://github.com/mmornati/ghost-cloudinary-store.git && \
  cd ghost-cloudinary-store && \
  git checkout update_ghost_1.0.0 && \
  npm install && \
  mkdir -p /ghost/blog/content/adapters/storage && \
  cp -r /ghost/ghost-cloudinary-store /ghost/blog/content/adapters/storage/ghost-cloudinary-store && \
  rm -rf /ghost/ghost-cloudinary-store

COPY config.production.json /ghost/blog
COPY run-ghost.sh /ghost

# Define working directory.
WORKDIR /ghost

# Set environment variables.
ENV NODE_ENV production

# Expose ports.
EXPOSE 2368

# Define mountable directories.
VOLUME ["/ghost-override"]

# Define default command.
CMD ["sh /ghost/run-ghost.sh"]
