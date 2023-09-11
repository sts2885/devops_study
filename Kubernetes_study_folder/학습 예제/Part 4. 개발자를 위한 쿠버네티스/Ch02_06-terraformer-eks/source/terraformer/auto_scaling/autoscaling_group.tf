resource "aws_autoscaling_group" "tfer--eks-002D-test-002D-eks-002D-nodegroup-002D-24c4526b-002D-e000-002D-7b7d-002D-4598-002D-eca39a0e23d4" {
  availability_zones        = ["us-east-1c", "us-east-1a"]
  capacity_rebalance        = "true"
  default_cooldown          = "300"
  default_instance_warmup   = "0"
  desired_capacity          = "2"
  force_delete              = "false"
  health_check_grace_period = "15"
  health_check_type         = "EC2"
  max_instance_lifetime     = "0"
  max_size                  = "3"
  metrics_granularity       = "1Minute"
  min_size                  = "1"

  mixed_instances_policy {
    instances_distribution {
      on_demand_allocation_strategy            = "prioritized"
      on_demand_base_capacity                  = "0"
      on_demand_percentage_above_base_capacity = "0"
      spot_allocation_strategy                 = "capacity-optimized"
      spot_instance_pools                      = "0"
    }

    launch_template {
      launch_template_specification {
        launch_template_id   = "lt-02aa09e14998038dc"
        launch_template_name = "eks-24c4526b-e000-7b7d-4598-eca39a0e23d4"
        version              = "1"
      }

      override {
        instance_type = "t3a.medium"
      }
    }
  }

  name                    = "eks-test-eks-nodegroup-24c4526b-e000-7b7d-4598-eca39a0e23d4"
  protect_from_scale_in   = "false"
  service_linked_role_arn = "arn:aws:iam::222170749288:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"

  tag {
    key                 = "kubernetes.io/cluster/test-eks-cluster"
    propagate_at_launch = "true"
    value               = "owned"
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/test-eks-cluster"
    propagate_at_launch = "true"
    value               = "owned"
  }

  tag {
    key                 = "eks:cluster-name"
    propagate_at_launch = "true"
    value               = "test-eks-cluster"
  }

  tag {
    key                 = "eks:nodegroup-name"
    propagate_at_launch = "true"
    value               = "test-eks-nodegroup"
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    propagate_at_launch = "true"
    value               = "true"
  }

  termination_policies      = ["AllocationStrategy", "OldestLaunchTemplate", "OldestInstance"]
  vpc_zone_identifier       = ["subnet-0ec3438c59d9e5ffb", "subnet-0b5dde0d0a29e34b3"]
  wait_for_capacity_timeout = "10m"
}
