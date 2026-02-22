output "alb_security_group_id" {
  value = module.vpc.alb_sg_id
}

output "app_security_group_id" {
  value = module.vpc.app_sg_id
}

output "db_security_group_id" {
  value = module.vpc.db_sg_id
}