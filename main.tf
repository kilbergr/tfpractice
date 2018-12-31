locals {
  app_name = "rebeccasapp"

  external_zone_name = "porchetta.io"

  s3_aws_logging_bucket = "${local.app_name}-${var.environment}-${var.vpc_region}-aws-logs"
}

#
# Logs
#
module "aws_logs" {
  source  = "../../../terraform-aws-logs/"
  version = "1.4.0"

  s3_bucket_name = "${local.s3_aws_logging_bucket}"
  region         = "${var.vpc_region}"
  expiration     = 90
  cloudtrail_logs_prefix = "rebecca-cloudtrail  "
}

#
# S3 Bucket
#
module "s3" {
  source  = "trussworks/s3-private-bucket/aws"
  version = "~> 1.5.0"

  bucket         = "${local.app_name}-${var.environment}-${var.vpc_region}"
  logging_bucket = "${local.s3_aws_logging_bucket}"


  tags {
    Environment = "${var.environment}"
  }
}

#
# ALB
#
module "alb_web_containers" {
  source  = "trussworks/alb-web-containers/aws"
  version = "2.5.0"

  name           = "${local.app_name}"
  environment    = "${var.environment}"
  logs_s3_bucket = "${local.s3_aws_logging_bucket}"

  alb_ssl_policy              = "ELBSecurityPolicy-TLS-1-2-2017-01"
  alb_default_certificate_arn = "${module.acm_my_external.acm_arn}"
  alb_vpc_id                  = "${module.vpc.vpc_id}"
  alb_subnet_ids              = "${module.vpc.public_subnets}"
}

#
# VPC
#
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 1.49.0"

  name = "rebeccas-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.vpc_region}a", "${var.vpc_region}b", "${var.vpc_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Environment = "${var.environment}"
  }
}

#
# ACM Cert
# 
module "acm_my_external" {
  source  = "trussworks/acm-cert/aws"
  version = "1.2.0"

  domain_name = "www.porchetta.io"
  environment = "${var.environment}"
  zone_name   = "${local.external_zone_name}"
}

