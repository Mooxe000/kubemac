#!/usr/bin/env bash

multipass delete microk8s-vm
sleep 10
multipass purge
sleep 10
multipass launch --name microk8s-vm --mem 4G --disk 40G -c 2
sleep 10

multipass exec microk8s-vm -- sudo sed -i \
  -e "s/archive.ubuntu.com/mirrors.aliyun.com/g" \
  -e "s/security.ubuntu.com/mirrors.aliyun.com/g" \
  /etc/apt/sources.list

multipass exec microk8s-vm -- sudo bash -lc \
  "curl -o- -SL https://raw.githubusercontent.com/Mooxe000/mooxe-docker-node/master/server/all.sh | bash"

# multipass exec microk8s-vm -- sudo bash -lc \
#   "curl -o- -SL https://raw.githubusercontent.com/Mooxe000/mooxe-docker-base/master/server/init.sh | bash"
# multipass exec microk8s-vm -- sudo bash -lc \
#   "curl -o- -SL https://raw.githubusercontent.com/Mooxe000/mooxe-docker-base/master/server/docker.sh | bash"
# multipass exec microk8s-vm -- sudo bash -lc \
#   "curl -o- -SL https://raw.githubusercontent.com/Mooxe000/mooxe-docker-node/master/server/node.sh | bash"

# multipass exec microk8s-vm -- sudo bash -lc \
#   "curl -SL http://192.168.64.1:8080/node.sh | bash"

multipass exec microk8s-vm -- sudo bash
