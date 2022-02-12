# --------------------------------------------------------------------
# Calling Module
# --------------------------------------------------------------------

module "vpc" {
    
  source   = "/var/terraform/modules/vpc/"
  vpc_cidr = var.project_vpc_cidr
  project  = var.project_name
  env      = var.project_env
  
}
# =========================================================================
# Creating Ssh KeyPair
# =========================================================================


resource "aws_key_pair"  "terraform" {
    
  key_name = "terraform"
  public_key = file("devops.pub")
  tags = {
    Name = "terraform"
  }
}

# --------------------------------------------------------------------
# Creating SecurityGroup bastion
# --------------------------------------------------------------------

resource "aws_security_group" "bastion" {
    
  name        = "${var.project_name}-bastion-${var.project_env}"
  description = "allow 22 traffic"
  vpc_id      = module.vpc.vpc_id


  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-bastion-${var.project_env}"
    project = var.project_name
     environment = var.project_env
  }
}






# --------------------------------------------------------------------
# Creating SecurityGroup webserver
# --------------------------------------------------------------------

resource "aws_security_group" "webserver" {
    
  name        = "${var.project_name}-webserver-${var.project_env}"
  description = "allow 80,443 traffic"
  vpc_id      = module.vpc.vpc_id


  ingress {
    description      = ""
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
    
   ingress {
    description      = ""
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
   
  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [ aws_security_group.bastion.id ]
  }
    
    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-webserver-${var.project_env}"
    project = var.project_name
     environment = var.project_env
  }
}


# --------------------------------------------------------------------
# Creating SecurityGroup database
# --------------------------------------------------------------------


resource "aws_security_group" "database" {
    
  name        = "${var.project_name}-database-${var.project_env}"
  description = "allow 3306 traffic"
  vpc_id      = module.vpc.vpc_id



    
   ingress {
    description      = ""
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [ aws_security_group.webserver.id ]
  }
   
  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [ aws_security_group.bastion.id ]
  }
    
    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-database-${var.project_env}"
    project = var.project_name
     environment = var.project_env
  }
}


# --------------------------------------------------------------------
# Creating Bastion Instance
# --------------------------------------------------------------------

resource "aws_instance" "bastion" {
    
  ami           = "ami-03fa4afc89e4a8a09"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.terraform.id
  vpc_security_group_ids = [ aws_security_group.bastion.id ]
  subnet_id = module.vpc.subnet_public2_id
  user_data = file("setup.sh")
  tags = {
    Name = "${var.project_name}-bastion-${var.project_env}"
    project = var.project_name
     environment = var.project_env
  }
}

# --------------------------------------------------------------------
# Creating webserver Instance
# --------------------------------------------------------------------

resource "aws_instance" "webserver" {
    
  ami           = "ami-03fa4afc89e4a8a09"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.terraform.id
  vpc_security_group_ids = [ aws_security_group.webserver.id ]
  subnet_id = module.vpc.subnet_public1_id
  user_data = file("setup.sh")
  tags = {
    Name = "${var.project_name}-webserver-${var.project_env}"
    project = var.project_name
     environment = var.project_env
  }
}


# --------------------------------------------------------------------
# Creating database Instance
# --------------------------------------------------------------------

resource "aws_instance" "database" {
    
  ami           = "ami-03fa4afc89e4a8a09"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.terraform.id
  vpc_security_group_ids = [ aws_security_group.database.id ]
  subnet_id = module.vpc.subnet_private1_id
  user_data = file("setup.sh")
  tags = {
    Name = "${var.project_name}-database-${var.project_env}"
    project = var.project_name
     environment = var.project_env
  }
}

terraform {
  backend "s3" {
    bucket = "state-file-s33-bucket"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
