kubectl apply -f config/ingress.yaml
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml
kubectl apply -f config/issuer.yaml
