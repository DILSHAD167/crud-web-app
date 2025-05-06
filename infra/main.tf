provider "aws" {
  region = var.region
}

module "vpc" {
  source                 = "./modules/vpc"
  region                 = var.region
  vpc_name               = var.vpc_name
  igw_name               = var.igw_name     
  vpc_cidr               = var.vpc_cidr
  public_subnet_az1_cidr = var.public_subnet_az1_cidr
  public_subnet_az2_cidr = var.public_subnet_az2_cidr
}

module "security_group" {
  source      = "./modules/security_groups"
  vpc_id      = module.vpc.vpc_id
  alb_sg_name = var.alb_sg_name
  ecs_sg_name = var.ecs_sg_name

}

module "iam" {
  source       = "./modules/iam"
  ecs_task_execution_name = var.ecs_task_execution_name
}


module "alb" {
  source                = "./modules/alb"
  alb_name              = var.alb_name 
  tg_name               = var.tg_name
  alb_security_group_id = module.security_group.alb_security_group_id
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc.public_subnet_az2_id
  vpc_id                = module.vpc.vpc_id
  certificate_arn       = var.certificate_arn
}

module "ecr" {
  source   = "./modules/ecr"
  ecr_name = var.ecr_name
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  log_group_name = var.log_group_name
  retention_in_days = var.retention_in_days
}

module "ecs" {
  source                       = "./modules/ecs"
  ecs_cluster_name             = var.ecs_cluster_name
  ecs_task_family              = var.ecs_task_family
  ecs_container_name           = var.ecs_container_name
  ecs_service_name             = var.ecs_service_name
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  repository_url               = module.ecr.repository_url
  public_subnet_az1_id         = module.vpc.public_subnet_az1_id
  public_subnet_az2_id         = module.vpc.public_subnet_az2_id
  ecs_security_group_id        = module.security_group.ecs_security_group_id 
  alb_target_group_arn         = module.alb.alb_target_group_arn
  log_group_name               = module.cloudwatch.log_group_name
  log_group_arn                = module.cloudwatch.log_group_arn
  region                       = module.vpc.region

}