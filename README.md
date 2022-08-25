# Painless PHP (Using docker)

This guide will demonstrate a way of containerisation of php application along with rapid development cycle.

## What we will do

1. Inspect source structure.
2. Explaining `Dockerfile`.
3. Explaining `docker-compose.yml`.
4. Demonstrating development cycle.

### 1. Inspect source structure:

```sh
.
├── src
│   └── index.php
├── Dockerfile
└── docker-compose.yml
```

Here the `src` directory is containing a simple `index.php` for demonstration purpose. Alongside the `src` directory i am having a `Dockerfile` & `docker-compose.yml` file responsible for containerisation of our project.

### 2. Explaining Dockerfile:

`Dockerfile` is responsible for describing our image for docker container. Contents of the docker file is following

```Dockerfile
FROM php:apache-buster

COPY ./src/* /var/www/html

CMD ["apache2-foreground"]
```

As a base image i choose [`php:apache-buster`](https://hub.docker.com/layers/php/library/php/apache-buster/images/sha256-3116abca1a9a1314af1818fd96d3ad2e777408a1c10798fa11aa66ac88759243?context=explore). This image pre-install `php` and `apache` server within it. `apache` server inside of this image serves file from `/var/www/html` folder

Then i copied the content of `src` folder into the `/var/www/html` folder so that all of my developed source code is avaiable inside the image.

Then started the apache server in foreground mode. Actually i copied it from the command of the base image.

So while starting container with image, a container will fireup where `apache` & `php` already installed and my source codes are inside the folder where apache serving files from.

### 3. Explaining docker-compose.yml

`docker-compose.yml` is responsible for orchastrate the with necessary configuration. Following are the contents of this file

```yml
version: '3.2'
services:
  awesome-app:
    build:
      context: .
      dockerfile: Dockerfile
    image: awesome-app:latest
    ports:
    - 80:80
    volumes:
    - type: bind
      source: ./src
      target: /var/www/html
```

At the very begining of this file I mentioned the compose file version. 

Then I declared the `services`.
I named our service `awesome-app`.
Inside the `build` portion i am specifying the `context` path `Dockerfile` to build image from.
Then I specify the image name alongside of it's tag.
After that I exposed the port 80 into the host, so that I can access the apache from the host.

The last portion is the tricky part. I am binding a volume from hosts `./src` directory to `/var/www/html` inside of the container. The purpose of this volume binding is so that while changing the file inside of my hosts `./src` folder all these changes can be seen by the `apache` running inside the container. As `apache` can see my changeset inside the `src` folder so i can change code and see the changed result without restarting or rebulding the image. 

### 4. Demonstrating development cycle.

To demonstrate a development cycle i will do followings

1. Start `awesome-app`.
2. Check existing output.
3. Change code.
4. Inspect changed output.


#### 1. Start `awesome-app`

To start my `awesome-app` we will use `docker-compose`

```sh
docker-compose up -d
```

This will create a `awesome-app` container in the background

#### 2. Check existing output

To inspect the output of existing codebase i will use `curl`

```sh
$ curl -i http://localhost
HTTP/1.1 200 OK
Date: Thu, 25 Aug 2022 19:27:35 GMT
Server: Apache/2.4.38 (Debian)
X-Powered-By: PHP/8.1.9
Content-Length: 12
Content-Type: text/html; charset=UTF-8

Hello world
```

#### 3. Change code:

Now i will modify code inside `index.php`

```php
<?php echo "My Awesome app says hello world\n"; ?>
```

#### 4. Inspect changed output.

```sh
$ curl -i http://localhost
HTTP/1.1 200 OK
Date: Thu, 25 Aug 2022 19:37:24 GMT
Server: Apache/2.4.38 (Debian)
X-Powered-By: PHP/8.1.9
Content-Length: 32
Content-Type: text/html; charset=UTF-8

My Awesome app says hello world
```

Changes done in the source code is reflected immediately.
