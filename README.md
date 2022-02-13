# Ec2-creation-using-VPC-module
Creating EC2 using terraform on custom VPC. The creation of VPC is fully automated and i have setup the VPC provision as a module.

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)]()

## Description:
Amazon Virtual Private Cloud (Amazon VPC) enables you to launch Amazon Web Services resources into a virtual network you've defined. This virtual network resembles a traditional network that you'd operate in your own data center, with the benefits of using the scalable infrastructure of AWS.

A Terraform module is a collection of standard configuration files in a dedicated directory. Terraform modules encapsulate groups of resources dedicated to one task, reducing the amount of code you have to develop for similar infrastructure components.

## Pre-requisites:

1) IAM Role (Role needs to be attached on terraform running server)
2) Basic knowledge about AWS services especially VPC, EC2 and IP Subnetting.
3) Terraform and its installation.

> Click here to [download](https://www.terraform.io/downloads.html) and  [install](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started) terraform.

Installation steps I followed:
```sh
wget https://releases.hashicorp.com/terraform/0.15.3/terraform_0.15.3_linux_amd64.zip
unzip terraform_0.15.3_linux_amd64.zip 
ls 
terraform  terraform_0.15.3_linux_amd64.zip    
mv terraform /usr/bin/
which terraform 
/usr/bin/terraform
```
## Steps for creating the VPC module with code:
### Module path as you like eg: /var/terraform/modules/vpc/
#### Create a file datasource.tf under above path,
```sh
data "aws_availability_zones" "az" {
    
  state = "available"
    
}
```

#### Create a file main.tf
```sh
# -------------------------------------------------------------------
# Vpc Creation
# -------------------------------------------------------------------

resource "aws_vpc" "vpc" {
    
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true  
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc-${var.env}"
    project = var.project
    environment = var.env
  }
    
}


# -------------------------------------------------------------------
# InterNet GateWay Creation
# -------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
   tags = {
    Name = "${var.project}-igw-${var.env}"
    project = var.project
     environment = var.env
  }
    
}


# -------------------------------------------------------------------
# Public Subnet 1
# -------------------------------------------------------------------

resource "aws_subnet" "public1" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, "3", 0)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "${var.project}-public1-${var.env}"
    project = var.project
     environment = var.env
  }
}

# -------------------------------------------------------------------
# Public Subnet 2
# -------------------------------------------------------------------

resource "aws_subnet" "public2" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, "3", 1)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "${var.project}-public2-${var.env}"
    project = var.project
     environment = var.env
  }
}

# -------------------------------------------------------------------
# Public Subnet 3
# -------------------------------------------------------------------
resource "aws_subnet" "public3" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, "3", 2)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "${var.project}-public3-${var.env}"
    project = var.project
     environment = var.env
  }
}

# -------------------------------------------------------------------
# Private Subnet 1
# -------------------------------------------------------------------
resource "aws_subnet" "private1" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, "3", 3)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "${var.project}-private1-${var.env}"
    project = var.project
     environment = var.env
  }
}

# -------------------------------------------------------------------
# Private Subnet 2
# -------------------------------------------------------------------
resource "aws_subnet" "private2" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, "3", 4)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "${var.project}-private2-${var.env}"
    project = var.project
     environment = var.env
  }
}

# -------------------------------------------------------------------
# Private Subnet 3
# -------------------------------------------------------------------
resource "aws_subnet" "private3" {
    
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, "3", 5)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "${var.project}-private3-${var.env}"
    project = var.project
     environment = var.env
  }
}


# -------------------------------------------------------------------
# ElasticIp for NatGateway
# -------------------------------------------------------------------
resource "aws_eip" "nat" {
  vpc      = true
  tags = {
    Name = "${var.project}-nat-${var.env}"
    project = var.project
     environment = var.env
  }
}

# -------------------------------------------------------------------
#  NatGateway  Creation
# -------------------------------------------------------------------
resource "aws_nat_gateway" "nat" {
    
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "${var.project}-nat-${var.env}"
    project = var.project
     environment = var.env
  }
  depends_on = [aws_internet_gateway.igw]
}


# -------------------------------------------------------------------
#  Public RouteTable
# -------------------------------------------------------------------

resource "aws_route_table" "public" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "${var.project}-public-${var.env}"
    project = var.project
     environment = var.env
  }
}

# -------------------------------------------------------------------
#  Private RouteTable
# -------------------------------------------------------------------

resource "aws_route_table" "private" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  
  tags = {
    Name = "${var.project}-private-${var.env}"
    project = var.project
    environment = var.env
  }
}

# -------------------------------------------------------------------
#  Public RouteTable association
# -------------------------------------------------------------------
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}


# -------------------------------------------------------------------
#  Private RouteTable association
# -------------------------------------------------------------------
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
```
#### Create a file output.tf
```sh
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_public1_id" {
  value = aws_subnet.public1.id
}

output "subnet_public2_id" {
  value = aws_subnet.public2.id
}

output "subnet_public3_id" {
  value = aws_subnet.public3.id
}


output "subnet_private1_id" {
  value = aws_subnet.private1.id
}

output "subnet_private2_id" {
  value = aws_subnet.private2.id
}

output "subnet_private3_id" {
  value = aws_subnet.private3.id
}
```

#### Create a file variables.tf
```sh
variable "vpc_cidr" {
    
  default = "172.16.0.0/16"
    
}

variable "project" {
    
  default = "example"
    
}


variable "env" {
    
  default = "Production"
    
}
```
