[![Build Status](https://travis-ci.org/mmornati/docker-ghostblog.svg)](https://travis-ci.org/mmornati/docker-ghostblog)[![](https://images.microbadger.com/badges/image/mmornati/docker-ghostblog.svg)](https://microbadger.com/images/mmornati/docker-ghostblog "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/version/mmornati/docker-ghostblog.svg)](https://microbadger.com/images/mmornati/docker-ghostblog "Get your own version badge on microbadger.com")

## Introduction

This image is a **drop replacement** of the official Ghost image. 

At time of writing the image is **well tested** by [Marco Mornati](https://twitter.com/marcomornati) and [Pascal Andy](https://twitter.com/askpascalandy). Just compare the [version from this project](https://github.com/mmornati/docker-ghostblog/blob/master/Dockerfile#L6) and the [version pushed](https://github.com/TryGhost/Ghost/releases) by the Ghost foundation.

The main motivation is to leverage the multistage builds available since docker 17.09 CE and **cut the fat**. The image size (uncompressed) is now **184MB** versus **584MB**. This is more than 3 times lighter!

It’s good to know that the official ghost image is not using multistage builds because Docker Enterprise is not supporting this function yet.

### Base Docker Image

* [node:8.9.1-alpine](https://registry.hub.docker.com/_/node/)

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

#### Customize Ghost

    docker run -d -p 80:2368 -e [ENVIRONMENT_VARIABLES] -v <override-dir>:/var/lib/ghost/content mmornati/docker-ghostblog

Environment variables are used to personalize your Ghost Blog configuration. Could be:

* WEB_URL: the URL used to expose your blog (default: blog.mornati.net)

A complete running command line could be:

```bash
docker run -d -p 2368:2368 -e WEB_URL=http://test.blog -v /opt/data:/var/lib/ghost/content mmornati/docker-ghostblog
```

#### Customize providing a custom configuration

If you want to customize your Ghost using, for example, a mail server, adding plugins and configure them, ... you can provide a complete configuration file which is being used instead of the internal one.
To do this a new volume is available: **/var/lib/ghost/config.override.json**

This means you can override the configuration with a command like the following one:

```bash
docker run -d -p 2368:2368 -e WEB_URL=http://test.blog -v /opt/data:/var/lib/ghost/content -v /opt/myconfiguration.json:/var/lib/ghost/config.override.json mmornati/docker-ghostblog
```

#### Configure TimeZone
If you want to configure TimeZone for the logging you can use the TZ environment variable with the timezone you need. For example:

```bash
docker run -p 2368:2368 -e TZ=America/Los_Angeles -e WEB_URL=http://localhost:2368 mmornati/docker-ghostblog date
Wed Nov 15 12:57:23 PST 2017
```

### Upgrade from previous version (< 1.16.2)

#### Data mount volume

If you were using this container with previous version, since the 1.16.2 we aligned the folders used inside the Docker to the ones used by the [Ghost official image](https://hub.docker.com/_/ghost/), you maybe need to change your data mount point.

Before you had:

```bash
 ... -v /opt/data:/ghost-override
```

and you should have, in your /opt/data folder, a subfolder named **content**.

Starting from this version your mount point should change to:

```bash
 ... -v /opt/data/content:/var/lib/ghost/content
```

#### Mount Volume access rights

To be complete the official image aligned, even the user used to run the ghost service changed from **ghost** to **node**.
This means if you had a previous installation of this docker, you should change the ownership of files in your folder or docker volume:

```bash
chown -R 1000:1000 /opt/data/content
```

The ID 1000 is the one created into the node image for the user **node**. Normally the owner before this operation should be *1276* which is the one assigned to the **ghost** user.

NB: Change the */opt/data/content* with the path of your data folder.