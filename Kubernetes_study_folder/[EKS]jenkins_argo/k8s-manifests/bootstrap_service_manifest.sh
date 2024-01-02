

#!/bin/bash -xe

kubectl create namespace instagram-clone

#helm upgrade --install ingress-nginx ingress-nginx \
#  --repo https://kubernetes.github.io/ingress-nginx  \
#  --namespace instagram-ingress-controller --create-namespace
#sleep 60


##############################################
helm install ingress-nginx-service ingress-nginx/ingress-nginx \
-n ingress-nginx \
--set controller.ingressClassResource.name=nginx-service \
--set controller.ingressClass=nginx-service

sleep 30
#####################################



#kubectl get svc -n instagram-ingress-controller


echo "start manually first"