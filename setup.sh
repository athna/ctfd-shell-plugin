#!/bin/bash

set -euo pipefail

sudo apt-get update

sudo apt-get install -y docker.io python-pip

cp server-scripts/add-user.sh docker/ssh-docker/
cp server-scripts/user-shell docker/ssh-docker/
cp server-scripts/change-user-pass.sh docker/ssh-docker

#pushd docker/user-docker
#    docker build -t user-image . -m 500M 
#popd

pushd docker/ssh-docker
	docker build -t shell-image .
	docker create -it --name shell-server -h tamuctf-shell -p 4200:4200 -p 2222:2222 -v /dev/fuse:/dev/fuse -v /var/run/docker.sock:/var/run/docker.sock shell-image
	docker start shell-server
	docker exec -d shell-server shellinaboxd -b -t -p 4200 &
	docker exec -d shell-server /usr/sbin/sshd -p 2222 &
	docker exec -d shell-server setfacl -m g:ctf-users:rw /var/run/docker.sock
popd

pushd server-scripts/
	python script_server.py &> xmlrpc_log.txt &
popd