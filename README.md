## Ghost Dockerfile


### Base Docker Image

* [node:0.10.36](https://registry.hub.docker.com/_/node/)


### Installation

```bash
git clone https://github.com/mmornati/docker-ghostblog.git
cd docker-ghostblog
docker build -t mmornati/ghostblog .
```

### Usage

    docker run -d -p 80:2368 mmornati/ghostblog

#### Customizing Ghost

    docker run -d -p 80:2368 -e [ENVIRONMENT_VARIABLES] -v <override-dir>:/ghost-override mmornati/ghostblog

Environment variables are used to personalise your Ghost Blog configuration. Could be:

* WEB_URL: the url used to expose your blog (default: blog.mornati.net)
* DB_CLIENT: database used to store blog data (default: sqlite3)
* DB_SQLITE_PATH: sqlite data file path (default: /content/data/ghost.db)
* SERVER_HOST: hostname/ip used to expose the blog (default: 0.0.0.0)
* SERVER_PORT: port used by the server (default: 2638).

> NB: Knowing the ghostblog is run using a 'non root user' (ghost), you cannot start the nodejs process on a port less than 1024.

A complete running command line could be:

    docker run -d -p 80:2368 -e WEB_URL=http://test.blog -e SERVER_HOST=12.4.23.5 -e SERVER_PORT=4000 -v /opt/data:/ghost-override dockerfile/ghost

