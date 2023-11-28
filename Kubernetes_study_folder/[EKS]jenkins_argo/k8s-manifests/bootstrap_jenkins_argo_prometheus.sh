
#!/bin/bash -xe

#얘는 iam id고 뭐고 아무것도 안들어가서 그냥 둬도 될듯, 기존에 있던 prom, grafana랑 이후에 설치할 jenkins, argo가 해당됨.



###istio 기반 Prometheus Grafana 설치 v1.16

kubectl create namespace istio-system

#https://istio.io/latest/docs/ops/integrations/prometheus/
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/prometheus.yaml

#echo """
##!/bin/bash
#while true; do kubectl port-forward --address 0.0.0.0 svc/prometheus -n istio-system 9090:9090; done
#""" | tee /home/ubuntu/port_forward_prometheus.sh

#.tf에서
#nohup bash /home/ubuntu/port_forward_prometheus.sh 0<&- &> /home/ubuntu/kubeflow3.log &

#https://istio.io/latest/docs/ops/integrations/grafana/
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/grafana.yaml

#echo """
##!/bin/bash
#while true; do kubectl port-forward --address 0.0.0.0 svc/grafana -n istio-system 3000:3000; done
#""" | tee /home/ubuntu/port_forward_grafana.sh

#.tf에서
#nohup bash /home/ubuntu/port_forward_grafana.sh 0<&- &> /home/ubuntu/kubeflow4.log &




##########   Prometheus with knative (it was not for istio T.T  ############

kubectl create namespace knative-eventing
kubectl create namespace knative-serving

echo """
kube-state-metrics:
  metricLabelsAllowlist:
    - pods=[*]
    - deployments=[app.kubernetes.io/name,app.kubernetes.io/component,app.kubernetes.io/instance]
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
""" | tee /home/ubuntu/values.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

sleep 5

helm repo update
sleep 5

helm install prometheus prometheus-community/kube-prometheus-stack -n default -f /home/ubuntu/values.yaml
#sleep 5

kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/monitoring/main/servicemonitor.yaml
#sleep 5

kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/monitoring/main/grafana/dashboards.yaml
#sleep 5


echo """
#!/bin/bash
while true; do kubectl port-forward --address 0.0.0.0 svc/prometheus-operated -n default 9090:9090; done
""" | tee /home/ubuntu/port_forward_prometheus.sh

echo """
#!/bin/bash
while true; do kubectl port-forward --address 0.0.0.0 svc/prometheus-grafana -n default 3000:80; done
""" | tee /home/ubuntu/port_forward_grafana.sh




##Grafana id, password를 알고 싶으면 아래처럼 하거나 secret을 edit해서 열면 됨
#기본값은 admin/prom-operator임.
#kubectl get secret --namespace default prometheus-grafana -o jsonpath="{.data.admin-user}" | base64 --decode ; echo    admin

#knative를 모니터링하기 위한 OpenTelemetry의 collector (이거도 CNCF 소프트웨어라고 함)
#knative에서 collecting을 해두면 prometheus에서 scraping을 함.
kubectl create namespace metrics

kubectl apply -f https://raw.githubusercontent.com/knative/docs/main/docs/serving/observability/metrics/collector.yaml
#sleep 5

kubectl patch --namespace knative-serving configmap/config-observability \
  --type merge \
  --patch '{"data":{"metrics.backend-destination":"opencensus","metrics.request-metrics-backend-destination":"opencensus","metrics.opencensus-address":"otel-collector.metrics:55678"}}'
kubectl patch --namespace knative-eventing configmap/config-observability \
  --type merge \
  --patch '{"data":{"metrics.backend-destination":"opencensus","metrics.opencensus-address":"otel-collector.metrics:55678"}}'

#echo """
##!/bin/bash
#while true; do kubectl port-forward --address 0.0.0.0 deployment/otel-collector -n default 8889:8889; done
#""" | tee /home/ubuntu/port_forward_otelCollector.sh




######################



echo "software installation finished"
sleep 60