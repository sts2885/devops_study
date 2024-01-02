

## Install AWS Controllers
## Install Kubeflow

resource "null_resource" "bootstrap_ctrl_and_kf222" {

    depends_on = [
        aws_eks_node_group.eks-nodegroup_1,
        aws_eks_node_group.eks-nodegroup_2,
        aws_instance.bastion
    ]

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("DevOps_Study.pem")}"
        host = aws_instance.bastion.public_ip
    }

    provisioner "remote-exec" {
        inline = [
            "chmod 777 /home/ubuntu/k8s-manifests/bootstrap_ctrl_and_kf.sh",
            "bash /home/ubuntu/k8s-manifests/bootstrap_ctrl_and_kf.sh",
            "bash /home/ubuntu/k8s-manifests/bootstrap_jenkins_argo_prometheus.sh",
            "bash /home/ubuntu/k8s-manifests/bootstrap_service_manifest.sh",


            #지금은 일단 port forward하는데 조만간 ingress로 바꾸자.
            "nohup bash /home/ubuntu/port_forward_prometheus.sh 0<&- &> /home/ubuntu/kubeflow3.log &",
            "sleep 1",
            "nohup bash /home/ubuntu/port_forward_grafana.sh 0<&- &> /home/ubuntu/kubeflow4.log &",
            "sleep 1",
            "nohup bash /home/ubuntu/port_forward_otelCollector.sh 0<&- &> /home/ubuntu/kubeflow5.log &",
            "sleep 1",

            "sudo NEEDRESTART_MODE=a apt install -y net-tools",


            "kubectl get svc -n ingress-nginx",
            "echo 'jenkins pass'",
            "kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo",
            "echo 'argo pass'",
            "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
        ]
   }
}


