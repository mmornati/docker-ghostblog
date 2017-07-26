[![Build Status](https://travis-ci.org/mmornati/docker-ghostblog.svg)](https://travis-ci.org/mmornati/docker-ghostblog)[![](https://images.microbadger.com/badges/image/mmornati/docker-ghostblog.svg)](https://microbadger.com/images/mmornati/docker-ghostblog "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/version/mmornati/docker-ghostblog.svg)](https://microbadger.com/images/mmornati/docker-ghostblog "Get your own version badge on microbadger.com")

## Ghost Dockerfile

### Base Docker Image

* [node:6.10](https://registry.hub.docker.com/_/node/)


### Installation

#### Building yourself

```bash
git clone https://github.com/mmornati/docker-ghostblog.git
cd docker-ghostblog
docker build -t mmornati/docker-ghostblog .
```

#### From DockerHub

```bash
docker pull mmornati/docker-ghostblog
```

### Usage

    docker run -d -p 80:2368 mmornati/docker-ghostblog

#### Customizing Ghost

    docker run -d -p 80:2368 -e [ENVIRONMENT_VARIABLES] -v <override-dir>:/ghost-override mmornati/docker-ghostblog

Environment variables are used to personalise your Ghost Blog configuration. Could be:

* WEB_URL: the url used to expose your blog (default: blog.mornati.net)
* DB_CLIENT: database used to store blog data (default: sqlite3)
* DB_SQLITE_PATH: sqlite data file path (default: /content/data/ghost.db)
* SERVER_HOST: hostname/ip used to expose the blog (default: 0.0.0.0)
* SERVER_PORT: port used by the server (default: 2638).

> NB: Knowing the ghostblog is run using a 'non root user' (ghost), you cannot start the nodejs process on a port less than 1024.

A complete running command line could be:

    docker run -d -p 80:2368 -e WEB_URL=http://test.blog -e SERVER_HOST=12.4.23.5 -e SERVER_PORT=4000 -v /opt/data:/ghost-override dockerfile/ghost

### Changelog
* Updated Node module to 6.10
* Updated Ghost to 1.0.0 version
* Aligned configuration to the new Ghost 1.0.0 system
* Changed installation procedure now using the Ghost-CLI command instead of ZIP file


### Old Changelogs

* Updated Node module to 4.5 LTS
* Included Cloudinary image as base storage

* Fixed problem starting with old middleware file. Just removed the file and using standard Ghostblog functionalities
* Updated Node module to 4.2 version which is now supported by Ghost
