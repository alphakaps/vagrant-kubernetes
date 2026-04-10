
kubectl create namespace metallb-system
kubectl create namespace traefik
kubectl create namespace keycloak

kubectl get configmap/kube-proxy -n kube-system -o yaml | sed 's/strictARP: false/strictARP: true/g' | kubectl apply -f - > /dev/null 2>&1
kubectl rollout restart daemonset.apps/kube-proxy -n kube-system

helm repo add metallb https://metallb.github.io/metallb
helm repo add traefik https://traefik.github.io/charts
helm repo add bitnami https://charts.bitnami.com/bitnami
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