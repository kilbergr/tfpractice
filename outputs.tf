output "environment" {
  description = "Name of the environment to create (e.g., staging, prod, etc.)."
  value       = "${var.environment}"
}

output "vpc_id" {
  description = "The VPC ID."
  value       = "${module.vpc.vpc_id}"
}

output "vpc_region" {
  description = "Region to create the VPC in."
  value       = "${var.vpc_region}"
}

output "vpc_public_subnet_ids" {
  description = "List of public subnets IDs."
  value       = "${module.vpc.public_subnets}"
}

output "vpc_private_subnet_ids" {
  description = "List of private subnets IDs."
  value       = "${module.vpc.private_subnets}"
}

output "vpc_database_subnet_ids" {
  description = "List of database subnets IDs."
  value       = "${module.vpc.database_subnets}"
}
