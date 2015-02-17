#
# Ghost blavorata
#

# Pull base image.
FROM dockerfile/nodejs

# Install Ghost
RUN \
  cd /tmp && \
  wget https://ghost.org/zip/ghost-latest.zip && \
  unzip ghost-latest.zip -d /ghost && \
  rm -f ghost-latest.zip

ADD run-ghost.sh /run-ghost.sh
RUN chmod 755 /*.sh

RUN useradd ghost --home /ghost
RUN chown -R ghost:ghost /ghost

USER ghost
ENV HOME /ghost
RUN cd /ghost && \
  npm install --production && \
  sed 's/127.0.0.1/0.0.0.0/' /ghost/config.example.js > /ghost/config.js
  

ADD config.js /ghost/config.js

# Define working directory.
WORKDIR /ghost

# Set environment variables.
ENV NODE_ENV production
ENV WEB_URL http://ser39.ovh.wikeo.webadeo.net
ENV DB_CLIENT sqlite3
ENV DB_SQLITE_PATH /content/data/ghost.db
ENV SERVER_HOST 0.0.0.0

# Expose ports.
EXPOSE 80

# Define mountable directories.
VOLUME ["/ghost/content", "/ghost-override"]

# Define default command.
CMD ["/run-ghost.sh"]
