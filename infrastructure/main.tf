provider "aws" {
  region = var.region
}

module "app" {
  source = "./resources/app"

  subnet_id = module.vpc.public_subnets[0]
  security_group_ids     = [aws_security_group.app_sg.id, aws_security_group.ssh_sg.id]
}

module "cache" {
  source = "./resources/nginx"

  key_pair_name      = var.key_pair_name
  subnet_ids         = module.vpc.public_subnets
  security_group_ids = [aws_security_group.nginx_sg.id, aws_security_group.ssh_sg.id, aws_security_group.efs_target.id]
  efs_id             = aws_efs_file_system.cache.id
  certificate_arn    = var.certificate_arn
  hosted_zone_id     = var.hosted_zone_id

  public_subnets = module.vpc.public_subnets
  vpc_id         = module.vpc.vpc_id

  lb_sg_ids = [aws_security_group.lb_sg.id]
  app_ip    = module.app.instance_ip
}
