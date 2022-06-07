data "aws_region" "current" {}

data "aws_vpc" "this" {
  id = var.vpc_id
}

# Create random string
resource "random_string" "this" {
  count = var.random_suffix ? 1 : 0

  length  = var.random_string_length
  numeric = true
  special = false
  upper   = false
}

locals {
  ssm_sg_name = var.random_suffix ? "${var.ssm_sg_name}-${random_string.this[0].id}" : var.ssm_sg_name
}

resource "aws_security_group" "this" {
  name        = local.ssm_sg_name
  description = "Allow TLS inbound traffic for SSM/EC2 endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.ingress_cidrs

  }
  tags = {
    Name = local.ssm_sg_name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Create three VPC endpoints for AWS Systems Manager
#
# References: 
# - https://aws.amazon.com/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/
# - https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html#sysman-setting-up-vpc-create 
# ---------------------------------------------------------------------------------------------------------------------

# VPC endpoint for the Systems Manager service
resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vpc_subnet_ids
  security_group_ids  = [aws_security_group.this.id]
  private_dns_enabled = var.private_dns_enabled

  tags = {
    Name = "${try(data.aws_vpc.this.tags.Name, var.vpc_id)}-ssm"
  }
}

# VPC endpoint for SSM Agent to make calls to the Systems Manager service
resource "aws_vpc_endpoint" "ec2_messages_endpoint" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vpc_subnet_ids
  security_group_ids  = [aws_security_group.this.id]
  private_dns_enabled = var.private_dns_enabled

  tags = {
    Name = "${try(data.aws_vpc.this.tags.Name, var.vpc_id)}-ec2messages"
  }
}

# VPC endpoint for connecting to EC2 instances through a secure data channel using Session Manager
resource "aws_vpc_endpoint" "ssm_messages_endpoint" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vpc_subnet_ids
  security_group_ids  = [aws_security_group.this.id]
  private_dns_enabled = var.private_dns_enabled

  tags = {
    Name = "${try(data.aws_vpc.this.tags.Name, var.vpc_id)}-ssmmessages"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# Optional VPC endpoints for AWS Systems Manager
#
# References: 
# - https://aws.amazon.com/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/
# - https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html#sysman-setting-up-vpc-create 
# ---------------------------------------------------------------------------------------------------------------------

# VPC endpoint for Systems Manager to create VSS-enabled snapshots
resource "aws_vpc_endpoint" "ec2_endpoint" {
  count = var.create_ec2_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vpc_subnet_ids
  security_group_ids  = [aws_security_group.this.id]
  private_dns_enabled = var.private_dns_enabled

  tags = {
    Name = "${try(data.aws_vpc.this.tags.Name, var.vpc_id)}-ec2"
  }
}

# VPC endpoint for AWS Key Management Service (AWS KMS) encryption for Session Manager or Parameter Store parameters
resource "aws_vpc_endpoint" "kms_endpoint" {
  count = var.create_kms_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vpc_subnet_ids
  security_group_ids  = [aws_security_group.this.id]
  private_dns_enabled = var.private_dns_enabled

  tags = {
    Name = "${try(data.aws_vpc.this.tags.Name, var.vpc_id)}-kms"
  }
}

# VPC endpoint for Amazon CloudWatch Logs (CloudWatch Logs) for Session Manager, Run Command, or SSM Agent logs
resource "aws_vpc_endpoint" "logs_endpoint" {
  count = var.create_logs_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vpc_subnet_ids
  security_group_ids  = [aws_security_group.this.id]
  private_dns_enabled = var.private_dns_enabled

  tags = {
    Name = "${try(data.aws_vpc.this.tags.Name, var.vpc_id)}-logs"
  }
}