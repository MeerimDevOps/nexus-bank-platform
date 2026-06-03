output "ecs_instance_role_name" {
  value = aws_iam_role.ecs_instance_role.name
}

output "ecs_instance_profile_name" {
  value = aws_iam_instance_profile.ecs_instance_profile.name
}

output "launch_template_id" {
  value = aws_launch_template.ecs.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.ecs.name
}
