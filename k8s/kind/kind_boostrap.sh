#!/bin/bash
export HOSTNAME="k8s-kind.local"
IP=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')
PORT="6443"

f_continue()
{
    read -p "Press enter to continue..."
}

echo "Configure $HOSTNAME on your Windows system32/etc/hosts"
f_continue

# GET KIND

echo "=== Install kubectl, kind"
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv ./kubectl /usr/local/bin/
echo ""

echo "Create kind cluster"
kind create cluster --config=- << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: argocd-kind
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
networking:
  apiServerAddress: "$IP"
  apiServerPort: $PORT
EOF

echo "=== Install nginx-ingress"
kubectl apply -f MY_URL


echo ""

echo "=== Install argo"
kubectl create namespace argocd
kubectl apply -n argocd -f XXX
echo ""

echo "=== Create ingress"
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    spec.ingressClassName: nginx
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    alb.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
spec:
  rules:
  - host: $HOSTNAME
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: argocd-server
            port:
              number: 80
EOF
echo ""

echo "=== Helm install"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
echo ""

echo "=== Install Kubernetes-dashboard" 
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
echo ""


echo "=== Create Kubernetes-dashboard SA" 
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
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
  namespace: kubernetes-dashboard
---
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"
type: kubernetes.io/service-account-token
EOF
echo ""


echo "=== Get SA token"
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
echo ""

f_continue
echo "Proxy for dashboard"
echo "kubectl -n kubernetes-dashboard port-forward svc/dashboard-kong-proxy 8443:443"
echo ""
f_continue 


