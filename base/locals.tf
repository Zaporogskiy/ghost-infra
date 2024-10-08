locals {
  vpc_name            = "${var.project_name}-vpc"
  account_id          = data.aws_caller_identity.current.account_id
  public_subnet_1     = "${var.environment}-${var.project_name}-${var.region}-public-001"
  public_subnet_2     = "${var.environment}-${var.project_name}-${var.region}-public-002"
  public_subnet_3     = "${var.environment}-${var.project_name}-${var.region}-public-003"
  private_subnet_1    = "${var.environment}-${var.project_name}-${var.region}-private-001"
  private_subnet_2    = "${var.environment}-${var.project_name}-${var.region}-private-002"
  private_subnet_3    = "${var.environment}-${var.project_name}-${var.region}-private-003"
  private_db_subnet_1 = "${var.environment}-${var.project_name}-${var.region}-db-private-001"
  private_db_subnet_2 = "${var.environment}-${var.project_name}-${var.region}-db-private-002"
  private_db_subnet_3 = "${var.environment}-${var.project_name}-${var.region}-db-private-003"

  tags = {
    Project = var.project_name
    Owner   = "${var.engineer_name}_${var.engineer_surname}"
  }
}