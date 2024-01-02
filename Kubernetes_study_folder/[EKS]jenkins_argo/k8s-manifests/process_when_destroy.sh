
#!/bin/bash -xe


helm uninstall ingress-nginx -n ingress-nginx

helm uninstall jenkins -n jenkins

kubectl delete pvc -n jenkins pvc-dynamic

