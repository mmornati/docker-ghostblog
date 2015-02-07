#
# Ghost blavorata
#

# Pull base image.
FROM tutum/node:latest

# Update Packages
RUN apt-get update

# Install Ghost
RUN \
  cd /tmp && \
  wget https://ghost.org/zip/ghost-latest.zip && \
  unzip ghost-latest.zip -d /ghost && \
  rm -f ghost-latest.zip && \
  cd /ghost && \
  npm install --production && \
  sed 's/127.0.0.1/0.0.0.0/' /ghost/config.example.js > /ghost/config.js && \
  useradd ghost --home /ghost

# Add files.
# ADD start.bash /ghost-start
ADD run-ghost.sh /run-ghost.sh
RUN chmod 755 /*.sh

# Define working directory.
WORKDIR /ghost

# Set environment variables.
ENV NODE_ENV production
ENV WEB_URL 'http://my-ghost-blog.com'
ENV DB_CLIENT 'sqlite3'
ENV SQLITE_PATH '/content/data/ghost.db'
ENV SERVER_HOST '0.0.0.0'

# Expose ports.
EXPOSE 80

# Define mountable directories.
VOLUME ["/ghost/content", "/ghost-override"]

# Define default command.
CMD ["/run-ghost.sh"]
