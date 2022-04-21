variable "vpc_id" {
  type        = string
  description = "Existing VPC ID"
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "Existing Subnet IDs"
}

variable "random_suffix" {
  type        = bool
  default     = true
  description = "Add random suffix"
}

variable "random_string_length" {
  type        = number
  default     = 3
  description = "Random string length"
}

variable "ssm_sg_name" {
  type        = string
  default     = "ssm-instance-role"
  description = "SSM instance role name"
}

variable "ingress_cidr_blocks" {
  type        = list(any)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description = "List of CIDR blocks to be allowed for ingress"
}

# Boolean to create EC2 VPC endpoint for Systems Manager to create VSS-enabled snapshots
variable "create_ec2_endpoint" {
  description = "Set to true to create EC2 VPC endpoint for VSS-enabled snapshots"
  type        = bool
  default     = false
}

# Boolean to create KMS VPC endpoint for AWS Key Management Service (AWS KMS) encryption for Session Manager or Parameter Store parameters
variable "create_kms_endpoint" {
  description = "Set to true to create KMS VPC endpoint"
  type        = bool
  default     = false
}

# Boolean to create logs VPC endpoint for Amazon CloudWatch Logs (CloudWatch Logs) for Session Manager, Run Command, or SSM Agent logs
variable "create_logs_endpoint" {
  description = "Set to true to create logs VPC endpoint"
  type        = bool
  default     = false
}

# Boolean to enable 
variable "private_dns_enabled" {
  description = "Boolean to associate a private hosted zone with the specified VPC"
  type        = bool
  default     = true
}

# when using custom_ingress_cidrs, local.rfc1918 will be ignored
variable "custom_ingress_cidrs" {
  description = "List of IP addreses/network to be allowed in the ingress security group"
  type        = list(string)
  default     = null # sample ["1.2.3.4/32"] or ["1.2.3.4/32", "10.0.0.0/8"] 
}

locals {
  rfc1918       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  ingress_cidrs = var.custom_ingress_cidrs != null ? var.custom_ingress_cidrs : local.rfc1918
}