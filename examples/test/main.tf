provider "aws" {
  region = "us-east-1"
}

module "base-network" {
  source                                      = "cn-terraform/networking/aws"
  version                                     = "2.0.7"
  name_preffix                                = "test-networking"
  vpc_cidr_block                              = "192.168.0.0/16"
  availability_zones                          = [ "us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d" ]
  public_subnets_cidrs_per_availability_zone  = [ "192.168.0.0/19", "192.168.32.0/19", "192.168.64.0/19", "192.168.96.0/19" ]
  private_subnets_cidrs_per_availability_zone = [ "192.168.128.0/19", "192.168.160.0/19", "192.168.192.0/19", "192.168.224.0/19" ]
}

module "cluster" {
  source  = "cn-terraform/ecs-cluster/aws"
  version = "1.0.5"
  name    = "test-cluster"
}

module "td" {
  source          = "cn-terraform/ecs-fargate-task-definition/aws"
  version         = "1.0.11"
  name_preffix    = "test-td"
  container_image = "ubuntu"
  container_name  = "test"
}

module "task" {
  source                                      = "../../"
  name_preffix                                = "test-task"
  event_rule_name                             = "test-rule"
  ecs_cluster_arn                             = module.cluster.aws_ecs_cluster_cluster_arn
  event_target_ecs_target_subnets             = module.base-network.public_subnets_ids
  event_target_ecs_target_task_definition_arn = module.td.aws_ecs_task_definition_td_arn
  ecs_execution_task_role_arn                 = "Put your role ARN here"
}
