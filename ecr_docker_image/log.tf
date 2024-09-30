resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/artem_task_logs"
}