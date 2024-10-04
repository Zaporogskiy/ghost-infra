resource "aws_cloudwatch_dashboard" "ghost_ec2_cpu_utilization_dashboard" {
  dashboard_name = "GhostEC2CPUUtilization"

  dashboard_body = templatefile("${path.module}/ec2_asg_dashboard.json", {
    auto_scaling_group_name = aws_autoscaling_group.ghost_ec2_pool_asg.name,
    region_name             = var.region
  })
}

resource "aws_cloudwatch_dashboard" "ecs_monitoring_dashboard" {
  dashboard_name = "GhostECSCPUUtilizationAndTaskRunning"

  dashboard_body = templatefile("${path.module}/ecs_dashboard.json", {
    cluster_name = aws_ecs_cluster.ghost.name
    service_name = aws_ecs_service.ghost.name,
    aws_region   = var.region
  })
}

resource "aws_cloudwatch_dashboard" "rds_dashboard" {
  dashboard_name = "RDSPerformanceMetrics"

  dashboard_body = templatefile("${path.module}/rds_dashboard.json", {
    db_instance_identifier = aws_db_instance.ghost.identifier,
    aws_region             = var.region
  })
}

resource "aws_cloudwatch_dashboard" "efs_dashboard" {
  dashboard_name = "EFSPerformanceMetrics"

  dashboard_body = templatefile("${path.module}/efs_dashboard.json", {
    file_system_id = aws_efs_file_system.ghost_content.id,
    aws_region     = var.region
  })
}