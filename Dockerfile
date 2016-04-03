#
# Ghost blog.mornati.net
#

# Pull base image (based on Debian)
FROM node:4.2

#Install Base package needed to install Ghost
RUN apt-get -y update
RUN apt-get -y install unzip
RUN apt-get -y install cron


# Install Ghost
RUN \
  cd /tmp && \
  wget https://ghost.org/zip/ghost-latest.zip && \
  unzip ghost-latest.zip -d /ghost && \
  rm -f ghost-latest.zip

COPY run-ghost.sh /run-ghost.sh
RUN chmod 755 /run-ghost.sh
COPY config.js /ghost/config.js

#Install Ghost SimeMap
RUN npm install -g ghost-sitemap

RUN useradd ghost --home /ghost -u 1000
RUN chown -R ghost:ghost /ghost
RUN mkdir /ghost-override
RUN chown -R ghost:ghost /ghost-override

USER ghost
ENV HOME /ghost
RUN cd /ghost && \
  npm install --production 

# Update Ghost to serve sitemap files
#COPY original.middleware.index.js /tmp/original.middleware.index.js
#RUN newfile=$(md5sum /ghost/core/server/middleware/index.js)
#RUN dockerfile=$(md5sum /tmp/original.middleware.index.js)
#RUN [[ $newfile != $dockerfile ]] && echo "WARNING: Docker need to be updated!"
COPY middleware.index.js /ghost/core/server/middleware/index.js

# Define working directory.
WORKDIR /ghost

RUN cd /ghost && \
  ghostSitemap init
RUN sed -i s/development/production/g /ghost/sitemapfile.json
RUN sed -i 's/sitemap/..\/ghost-override\/content\/sitemap/g' /ghost/sitemapfile.json
RUN (crontab -l ; echo "0 0 * * * ghostSitemap generate && ghostSitemap ping all") | crontab -

# Set environment variables.
ENV NODE_ENV production

# Expose ports.
EXPOSE 2368

# Define mountable directories.
VOLUME ["/ghost-override"]

# Define default command.
CMD ["/run-ghost.sh"]
