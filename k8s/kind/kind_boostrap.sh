#!/bin/bash
export HOSTNAME="k8s-kind.local"
export ARGOHOSTNAME="argocd.k8s-kind.local"
IP=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')
PORT="6443"
CLUSTER_NAME="argocd-kind"

cat <<'EOF'
Current setup 
HOSTNAME="k8s-kind.local" 
ARGOHOSTNAME="argocd.k8s-kind.local" 
IP=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}') 
PORT="6443" 
CLUSTER_NAME="argocd-kind" 

"Configure $HOSTNAME, $ARGOHOSTNAME on your Windows system32/etc/hosts and on Linux OS"

"If the creation kind process gets stucked delete cluster, reboot and start again"
EOF
echo ""
echo "=== Sleep 30s, last chance to abort"
sleep 30
echo "=== Check for existing $CLUSTER_NAME"
kind get clusters | grep -v grep | grep $CLUSTER_NAME > /dev/null 2>&1
if [ "$?" -eq "0" ]
then
  kind delete clusters $CLUSTER_NAME
fi



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
name: $CLUSTER_NAME
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
kubectl apply -f https://raw.githubusercontent.com/maspi83/proxmox/refs/heads/master/k8s/kind/files/nginx_ingress.yaml
echo ""

echo "=== Install argocd"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/maspi83/proxmox/refs/heads/master/k8s/kind/files/argocd_install.yaml
echo ""



echo "=== Helm install"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ 
echo ""

echo "=== Install Kubernetes-dashboard"
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard > /dev/null 2>&1
echo ""


echo "=== Create Kubernetes-dashboard SA"
kubectl apply -f https://raw.githubusercontent.com/maspi83/proxmox/refs/heads/master/k8s/kind/files/dashboard_sa.yaml
echo ""

echo "=== Wait 120s, until all start before proceeding to ingress setup, and getting tokens take a break"
sleep 120
echo ""

echo "=== Get SA token"
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
echo ""


echo "=== Argo init pwd"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath={".data.password"} | base64 -d
echo ""


echo "=== Create argocd ingress"
curl -sL https://raw.githubusercontent.com/maspi83/proxmox/refs/heads/master/k8s/kind/files/ingress_argocd.yaml | sed "s/ARGOHOSTNAME/$ARGOHOSTNAME/g" | kubectl apply -f -
echo ""


echo "=== Create k8s dashboard ingress"
curl -sL https://raw.githubusercontent.com/maspi83/proxmox/refs/heads/master/k8s/kind/files/ingress_dashboard.yaml | sed "s/HOSTNAME/$HOSTNAME/g" | kubectl apply -f -
echo ""
