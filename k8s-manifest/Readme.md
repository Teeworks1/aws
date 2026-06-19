helm install istio-base istio/base \
  -n istio-system \
  --create-namespace \
  --version 1.30.1

helm install istiod istio/istiod \
  -n istio-system \
  --version 1.30.1 \
  -f istiod-values.yaml

helm install istio-ingress istio/gateway \
  -n istio-ingress \
  --create-namespace \
  --version 1.30.1 \
  -f gateway-values.yaml