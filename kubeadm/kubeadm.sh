#!/usr/bin/env bash

curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
cat << EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
apt-fast update
apt-fast install -y kubeadm

swapoff -a && sysctl -w vm.swappiness=0

# kubeadm config images list
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

sed -i '/Environment="KUBELET_CONFIG_ARGS/aEnvironment="KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs"' \
  /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
systemctl restart kubelet

swapoff -a && sysctl -w vm.swappiness=0

# 不同機器有差異
sed -i '/swap.img/d' /etc/fstab

# kubeadm token generate
# kubeadm init --service-cidr 10.96.0.0/12 \
#   --kubernetes-version v1.15.0 \
#   --pod-network-cidr 10.244.0.0/16 \
#   --token b0f7b8.8d1767876297d85c \
#   --apiserver-advertise-address 172.16.35.12

kubeadm init \
  --kubernetes-version=v1.15.0 \
  --apiserver-advertise-address=192.168.64.4 \
  --pod-network-cidr=192.168.0.0/16
# curl https://127.0.0.1:6443 -k

# mkdir ~/.kube && \
#   cp /etc/kubernetes/admin.conf ~/.kube/config

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
# kubectl get node

kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
# watch kubectl get pods --all-namespaces

kubectl taint nodes --all node-role.kubernetes.io/master-
# kubectl get nodes -o wide

docker pull mirrorgooglecontainers/kubernetes-dashboard-amd64:v1.10.1
docker tag mirrorgooglecontainers/kubernetes-dashboard-amd64:v1.10.1 \
  k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
