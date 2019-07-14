#!/usr/bin/env bash

# https://blog.tekspace.io/kubernetes-dashboard-remote-access/
cat > kube-dashboard-access.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
EOF
# kubectl delete -f kube-dashboard-access.yaml
# kubectl create -f kube-dashboard-access.yaml
kubectl apply -f kube-dashboard-access.yaml

# 创建登录用的账户
cat  > dashboard-adminuser.yaml <<eof
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
eof
# kubectl delete -f dashboard-adminuser.yaml
# kubectl create -f dashboard-adminuser.yaml
kubectl apply -f dashboard-adminuser.yaml

# 为账户赋予权限
cat > dashboard-adminuser-roleBind.yaml <<eof
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
eof

# kubectl delete -f dashboard-adminuser-roleBind.yaml
# kubectl create -f dashboard-adminuser-roleBind.yaml
kubectl apply -f dashboard-adminuser-roleBind.yaml

cat > dashboard-support-https.yaml <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: dashboard-ingress
  namespace: kube-system
  annotations:
    # redirect to https while access by http
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /
    # HTTPS transfer，(because ingress use HTTP  by default)
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  # configure the secret created above
  tls:
    - secretName: secret-ca-k8s-hiko-im
  rules:
  - host: dashboard.k8s.hiko.im
    http:
      paths:
      - path: /
        backend:
          serviceName: kubernetes-dashboard
          servicePort: 443
EOF
# kubectl delete -f dashboard-support-https.yaml
# kubectl create -f dashboard-support-https.yaml
kubectl apply -f dashboard-support-https.yaml

rm ./kube-dashboard-access*
rm ./dashboard-adminuser*
rm ./dashboard-support-https*

kubectl -n kube-system describe secret \
  $(kubectl -n kube-system get secret |\
  grep admin-user |\
  awk '{print $1}')
