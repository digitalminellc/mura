# Mura Digital Experience Platform

[![Crowdin](https://d322cqt584bo4o.cloudfront.net/muracms/localized.svg)](https://translate.getmura.com/project/muracms)
[![Docs](https://img.shields.io/badge/view%20docs-readthedocs-blue.svg?style=flat-square)](http://docs.getmura.com/)

[Mura](https://www.murasoftware.com) is a digital experience platform, created by [blueriver](https://www.blueriver.com). Mura was designed to build ambitious web, multi-channel, business-to-business and business-to-employee applications, and create Flow in the digital experience for Content Managers, Content Contributors, Marketers and Developers.

## For those with Docker installed

### Mura Resources

* <https://www.murasoftware.com>
* <https://groups.google.com/forum/#!forum/mura-cms-developers>
* <https://cfml.slack.com/messages/C0FBLG0BF>
* <https://github.com/muralabs/muracms>

### Official Docker Image

For production there is an official docker image available at <https://hub.docker.com/r/murasoftware/muracms>

### Using Docker with Source Code

#### Start up a demo instance pre-populated with content

```shell
git clone https://github.com/muralabs/muracms.git
cd MuraCMS
git checkout master
docker-compose -f core/docker/local-demo/docker-compose.yml up
```

#### Start up an instance with no content

```shell
git clone https://github.com/muralabs/muracms.git
cd muracms
git checkout master
docker-compose -f core/docker/local-mysql/docker-compose.yml up
```

Then access the application via:

<http://localhost:8080>

To login type esc-l or go to <http://localhost:8080/admin>

```shell
Username: admin
Password: admin
```

#### MYSQL Connection Info

```shell
Host: localhost
Port: 55555
Username: root
Passsword: NOT_SECURE_CHANGE
```

Simply hold down control-c to stop the service.

## For those with Commandbox installed

```shell
box install muracms
box start
```

However, you will need to have a running database instance to create your db and register the dsn with the CFML service.

* <https://www.ortussolutions.com/products/commandbox>
* <https://www.forgebox.io/view/muracms>
