# ProjMan with docker.

This is an example taken from https://github.com/jyepesr1/projMan but the core os this example is just testing docker.

To execute this program is just necesary execute ops.sh script, that has the following content:

**_Caution:_** Yo should change "user" by your own user in the script.

  ```
  #!/bin/bash

  if [ "$1" == 'init' ]; then
    if [ "$(docker network ls)" != *"proj"* ]; then
      docker network create proj
    fi
    cd mariadb
    docker build -t user/mariadb .
    docker run --name db --net=proj -v /home/user/mysql:/var/lib/mysql -d user/mariadb

    cd ..
    docker build -t user/projman .
    docker run -id --name projMan1 --net=proj user/projman
    docker run -id --name projMan2 --net=proj user/projman

    cd haproxy
    docker build -t user/haproxy .
    docker run -d --name haproxy --net=proj user/haproxy

    docker exec projMan1 python db.py db init
    docker exec projMan1 python db.py db migrate
    docker exec projMan1 python db.py db upgrade
  
    docker exec projMan2 python db.py db init
    docker exec projMan2 python db.py db migrate
    docker exec projMan2 python db.py db upgrade

    docker network inspect proj
  elif [ "$1" == 'delete' ]; then
    docker network rm proj
    docker rm -f db projMan1 projMan2 haproxy
    docker rmi -f user/mariadb user/haproxy user/projman
  elif [ "$1" == 'start' ]; then
    docker start db projMan1 projMan2 haproxy
  elif [ "$1" == 'stop' ]; then
    docker stop db projMan1 projMan2 haproxy
  else
    echo "Not valid param"
  fi  
  ```
Now, I'm going to explain what does it do...

There are four options to execute this script:

1. Init
  This is the most interesting option, because it uses a lot of things:
  1.1 Creating network:
  ```
  if [ "$(docker network ls)" != *"proj"* ]; then
    docker network create proj
  fi
  ```
  First of all, we check if the network exists, if it doesn't exist we create it with the command above.

  1.2 Creating and running containers
  ```
  cd mariadb
  docker build -t user/mariadb .
  docker run --name db --net=proj -v /home/user/mysql:/var/lib/mysql -d user/mariadb

  cd ..
  docker build -t user/projman .
  docker run -id --name projMan1 --net=proj user/projman
  docker run -id --name projMan2 --net=proj user/projman

  cd haproxy
  docker build -t user/haproxy .
  docker run -d --name haproxy --net=proj user/haproxy
  ```
  Here we build and run three containers, first of all, we build it from its respectives Dockerfiles. After that, we run each container and add them to the network we created in the previous step. But, running the database is a little bit different because it is necesary to create something called "volume", it is like a mirroring between a local folder and a folder in the container. We did this to ensure persistence so we can reuse /home/user/mysql folder in other containers (but not simultaneity).

2. Delete
  This will delete the network that we created, the containers and the images

3. Start
  This option is to start all the containers that have been created with our program such as db, projMan1, projMan2 and haproxy.

4. Stop
  This option will stop the containers that we started in the "start" stage.

