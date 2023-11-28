resource "aws_iam_instance_profile" "bastion-ec2-instance-profile" {
  name = "bastion-ec2-instance-profile"
  path = "/"
  role = "iam-role-ec2-instance-bastion"
}
