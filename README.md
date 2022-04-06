# AWS Terraform Module - SSM VPC Endpoints

Terraform module to create Security Group and VPC Endpoints for SSM

## Usage with minimal customisation

```hcl
module "ssm_vpc_endpoint" {
  source  = "bayupw/ssm-vpc-endpoint/aws"
  version = "1.0.0"

  vpc_id = "vpc-0a1b2c3d4e"
  subnet_id = ["subnet-0a1b2c3d4e"]
}
```

## Complete example with SSM instance profile creation and an EC2 instance on an existing VPC

```hcl
module "ssm_instance_profile" {
  source  = "bayupw/ssm-instance-profile/aws"
  version = "1.0.0"
}

module "ssm_vpc_endpoint" {
  source  = "bayupw/ssm-vpc-endpoint/aws"
  version = "1.0.0"

  vpc_id = "vpc-0a1b2c3d4e"
  subnet_id = ["subnet-0a1b2c3d4e"]
}

module "amazon_linux_2" {
  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  vpc_id = "vpc-0a1b2c3d4e"
  subnet_id = "subnet-0a1b2c3d4e"
  
  iam_instance_profile = module.ssm_instance_profile.aws_iam_instance_profile
}
```

## Complete example with a new VPC, SSM instance profile creation and an EC2 instance

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  azs             = ["ap-southeast-2a", "ap-southeast-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "my-vpc"
  }
}

module "ssm_instance_profile" {
  source  = "bayupw/ssm-instance-profile/aws"
  version = "1.0.0"
}

module "ssm_vpc_endpoint" {
  source  = "bayupw/ssm-vpc-endpoint/aws"
  version = "1.0.0"

  vpc_id = module.vpc.vpc_id
  subnet_id = [for private_subnet in module.vpc.private_subnets]
}

module "amazon_linux_2" {
  for_each = module.vpc.private_subnets

  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  vpc_id = module.vpc.vpc_id
  subnet_id = each.key
  
  iam_instance_profile = module.ssm_instance_profile.aws_iam_instance_profile
}
```

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/bayupw/terraform-aws-ssm-vpc-endpoint/issues/new) section.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/bayupw/terraform-aws-ssm-vpc-endpoint/tree/master/LICENSE) for full details.