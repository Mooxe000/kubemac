# Microk8s Installer

```bash
axel 'http://192.168.64.1:8080/core.tar.gz'
axel 'http://192.168.64.1:8080/microk8s.tar.gz'

tar xvf core.tar.gz
tar xvf microk8s.tar.gz

snap ack core/core_7270.assert; \
snap install core/core_7270.snap; \
snap ack microk8s/microk8s_671.assert; \
snap install microk8s/microk8s_671.snap --classic

snap alias microk8s.kubectl kubectl

# vi /var/snap/microk8s/current/args/containerd-env 
# HTTPS_PROXY=socks5://192.168.64.1:1080

docker pull mirrorgooglecontainers/pause:3.1
docker tag mirrorgooglecontainers/pause:3.1 k8s.gcr.io/pause:3.1
docker pull mirrorgooglecontainers/kubernetes-dashboard-amd64:v1.10.1
docker tag mirrorgooglecontainers/kubernetes-dashboard-amd64:v1.10.1 k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1

microk8s.enable dns dashboard registry

microk8s.stop
sleep 10
microk8s.start

# kubectl get pods --all-namespaces -o wide
# kubectl get pods --namespace kube-system
# kubectl describe pod   --namespace kube-system

# kubectl edit deployment/kubernetes-dashboard --namespace=kube-system
# spec:
#       containers:
#       - args:
#         - --auto-generate-certificates
#         - --enable-skip-login
#         image: k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1
# "/tmp/kubectl-edit-snu9z.yaml" 102L, 4077C

# kubectl proxy --address='192.168.64.4' --disable-filter=true
kubectl proxy --address='0.0.0.0' --accept-hosts='.*' 

```
