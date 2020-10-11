#!/bin/bash

# Install istio with demo configuration
istioctl install --set profile=demo

# specify istio to automatically inject sidecar proxies
kubectl label namespace default istio-injection=enabled

# deploy BookInfo sample application
# set working directory to istio install location
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

# confirm bookinfo resources are running
kubectl get services
kubectl get pods

# test that bookinfo app is up and running
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -s productpage:9080/productpage | grep -o "<title>.*</title>"

# setup istio gateway to allow external traffic
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

# ensure no issues with setup
istioctl analyze

# determine support for external load balancers
kubectl get svc istio-ingressgateway -n istio-system
# for ip address
#export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# for host name version
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# get other required parameters
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

# setup istio gateway URL
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

# verify external access to BookInfo application, paste generated url in browser
echo "http://$GATEWAY_URL/productpage"




