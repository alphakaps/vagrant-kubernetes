
kubectl create namespace metallb-system
kubectl create namespace traefik
kubectl create namespace keycloak
kubectl create namespace authentik
kubectl create namespace app
kubectl create namespace monitoring

kubectl get configmap/kube-proxy -n kube-system -o yaml | sed 's/strictARP: false/strictARP: true/g' | kubectl apply -f - > /dev/null 2>&1
kubectl rollout restart daemonset.apps/kube-proxy -n kube-system

helm repo add metallb https://metallb.github.io/metallb
helm repo add traefik https://traefik.github.io/charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add authentik https://charts.goauthentik.io
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install metallb metallb/metallb --namespace metallb-system
kubectl delete validatingwebhookconfiguration metallb-webhook-configuration
kubectl apply -f metallb-config.yml -n metallb-system

openssl req -new -newkey rsa:2048 -nodes -keyout tls.key -out csr.csr -config csr.conf
openssl x509 -req -days 365 -in csr.csr -signkey tls.key -out tls.crt
kubectl create secret tls local-selfsigned-tls  --cert=tls.crt --key=tls.key --namespace traefik

helm install traefik traefik/traefik -n traefik -f traefik-values.yml
kubectl rollout restart deployment.apps/traefik -n traefik

helm install keycloak bitnami/keycloak --version 24.4.9 -n keycloak -f values.yml
kubectl rollout restart statefulset.apps/keycloak-postgresql -n keycloak
sleep 20
kubectl rollout restart statefulset.apps/keycloak -n keycloak
sleep 30

# StorageClass + PV for Authentik PostgreSQL
kubectl apply -f - <<'EOF'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: Immediate
EOF
kubectl apply -f pv.yml

# Authentik blueprint ConfigMap (must exist before helm install so the worker picks it up on first boot)
kubectl apply -f authentik-blueprint.yml

# Authentik installation
helm install authentik authentik/authentik -n authentik -f authentik-values.yml
kubectl apply -f httproute-authentik.yml

# app deployment
kubectl apply -f app-serviceaccount.yml
kubectl apply -f app-deployment.yml
kubectl apply -f app-service.yml
kubectl apply -f app-middleware.yml
kubectl apply -f app-httproute.yml
kubectl apply -f app-servicemonitor.yml

# Prometheus stack
kubectl apply -f pv-prometheus.yml
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f prometheus-values.yml
kubectl apply -f prometheus-middleware.yml
kubectl apply -f prometheus-httproutes.yml