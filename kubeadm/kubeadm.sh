#!/usr/bin/env bash

curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
cat << EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
apt-fast update
apt-fast install -y kubeadm

swapoff -a && sysctl -w vm.swappiness=0

images=(
  kube-apiserver:v1.15.0
  kube-controller-manager:v1.15.0
  kube-scheduler:v1.15.0
  kube-proxy:v1.15.0
  pause:3.1
  etcd:3.3.10
  coredns:1.3.1
)

for imageName in ${images[@]} ; do
  docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
  docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
done

# kubeadm init --service-cidr 10.96.0.0/12 \
#   --kubernetes-version v1.15.0 \
#   --pod-network-cidr 10.244.0.0/16 \
#   --token b0f7b8.8d1767876297d85c \
#   --apiserver-advertise-address 172.16.35.12
