module "network" {
  source = "../../modules/network"

  project_name = "apex"
  environment  = "dev"

  vpc_cidr = "10.0.0.0/16"

  azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_app_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  isolated_db_subnet_cidrs = [
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]
}
module "security" {
  source = "../../modules/security"

  project_name = "apex"
  environment  = "dev"
  vpc_id       = module.network.vpc_id
}
module "ecs" {
  source = "../../modules/ecs"

  project_name          = "apex"
  environment           = "dev"
  target_group_arn      = module.alb.target_group_arn
  private_subnet_ids    = module.network.private_app_subnet_ids
  ecs_security_group_id = module.security.ecs_sg_id
}
module "compute" {
  source = "../../modules/compute"

  project_name          = "apex"
  environment           = "dev"
  ecs_cluster_name      = module.ecs.ecs_cluster_name
  ecs_security_group_id = module.security.ecs_sg_id
  private_subnet_ids    = module.network.private_app_subnet_ids
}
module "alb" {
  source = "../../modules/alb"

  project_name = "apex"
  environment  = "dev"

  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security.alb_sg_id
}
module "rds" {
  source = "../../modules/rds"

  project_name = "apex"
  environment  = "dev"

  db_subnet_ids        = module.network.isolated_db_subnet_ids
  db_security_group_id = module.security.rds_sg_id
  db_password          = "NexusBank123!"
}
output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "db_identifier" {
  value = module.rds.db_identifier
}
module "secrets" {
  source = "../../modules/secrets"

  project_name = "apex"
  environment  = "dev"

  db_username = "admin"
  db_password = "ChangeMe123!"
}
module "monitoring" {
  source = "../../modules/monitoring"

  project_name = "apex"
  environment  = "dev"
}
module "alarms" {
  source = "../../modules/alarms"

  project_name = "apex"
  environment  = "dev"

  cluster_name = "apex-dev-ecs-cluster"
  service_name = "apex-dev-nginx-service"
}
module "autoscaling" {
  source = "../../modules/autoscaling"

  project_name = "apex"
  environment  = "dev"

  cluster_name = "apex-dev-ecs-cluster"
  service_name = "apex-dev-nginx-service"
}
module "waf" {
  source = "../../modules/waf"

  project_name = "apex"
  environment  = "dev"

  alb_arn = module.alb.alb_arn
}
