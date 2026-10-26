module "vpc" {
  source = "../../modules/vpc"
}

module "alb" {
  source = "../../modules/alb"

  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  acm_certificate_arn = module.acm.acm_certificate_arn
}

module "ecs" {
  source = "../../modules/ecs"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_tg_arn         = module.alb.alb_tg_arn
  alb_sg_id          = module.alb.alb_sg_id
  cpu                = var.cpu
  memory             = var.memory
  desired_count      = var.desired_count
  depends_on = [
    module.alb
  ]
}

module "acm" {
  source = "../../modules/acm"

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
  sub_domain   = var.sub_domain
}

module "auto-scaling" {
  source = "../../modules/auto-scaling"

  ecs_cluster = module.ecs.ecs_cluster
  ecs_service = module.ecs.ecs_service
}