#참고 한 링크등

#https://cj-hewett.medium.com/using-templates-in-terraform-to-generate-kubernetes-yaml-5f60cfa0109
#template에다가 변수 넣는 식으로 돌아가는듯

#https://cj-hewett.medium.com/using-templates-in-terraform-to-generate-kubernetes-yaml-5f60cfa0109
#https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
#https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
#https://stackoverflow.com/questions/63845957/terraform-saving-output-to-file
#https://github.com/hashicorp/terraform/issues/8090
#https://www.bitslovers.com/terraform-template-file/



data "template_file" "eniconfig" {
    template = "${file("${path.module}/k8s-manifests/eni-configs/eniconfig.yaml.tftpl")}"
    vars = {
            sg_a = "${aws_security_group.eks-pods-sg.id}",
            subnet_a = "${aws_subnet.private_subnet_eks_pods_a.id}",
            sg_c = "${aws_security_group.eks-pods-sg.id}",
            subnet_c = "${aws_subnet.private_subnet_eks_pods_c.id}"
        }
}

resource "local_file" "eniconfig" {
    content = "${data.template_file.eniconfig.rendered}"
    filename = "${path.module}/k8s-manifests/eni-configs/eniconfig.yaml"
}



