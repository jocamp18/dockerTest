#!/bin/bash

if [ "$1" == 'init' ]; then
  if [ "$(docker network ls)" != *"proj"* ]; then
    docker network create proj
  fi
  cd mariadb
  docker build -t jocamp18/mariadb .
  docker run --name db --net=proj -v /home/jocamp18/mysql:/var/lib/mysql -d jocamp18/mariadb

  cd ..
  docker build -t jocamp18/projman .
  docker run -id --name projMan1 --net=proj jocamp18/projman
  docker run -id --name projMan2 --net=proj jocamp18/projman

  cd haproxy
  docker build -t jocamp18/haproxy .
  docker run -d --name haproxy --net=proj jocamp18/haproxy

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
  docker rmi -f jocamp18/mariadb jocamp18/haproxy jocamp18/projman
elif [ "$1" == 'start' ]; then
  docker start db projMan1 projMan2 haproxy
elif [ "$1" == 'stop' ]; then
  docker stop db projMan1 projMan2 haproxy
else
  echo "Not valid param"
fi
