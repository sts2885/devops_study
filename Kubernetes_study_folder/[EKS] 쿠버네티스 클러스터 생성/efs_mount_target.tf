resource "aws_efs_mount_target" "efs-mount-target1" {

  file_system_id  = aws_efs_file_system.efs-file-system.id
  security_groups = [aws_security_group.efs-sg.id]
  subnet_id       = aws_subnet.public_subnet_a.id
}

resource "aws_efs_mount_target" "efs-mount-target3" {

  file_system_id  = aws_efs_file_system.efs-file-system.id
  security_groups = [aws_security_group.efs-sg.id]
  subnet_id       = aws_subnet.public_subnet_c.id
}