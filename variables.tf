variable "aws_region" {
  description = "AWS region to launch servers."
  default = "eu-west-1"

}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/20"
}

variable "public_1a_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/23"
}



variable "private_1a_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.10.0/23"
}

variable "public_1b_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.2.0/23"
}



variable "private_1b_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.12.0/23"
}

variable "amis" {
  type = map(string)
  default = {
    "eu-west-1" = "ami-0ea3405d2d2522162"
    "us-east-1" = "ami-08f3d892de259504d"
  }
}

variable "instance_type" {
   default = "t2.micro"
}

variable "aws_key_name" {
   default = "tkay"
}

variable "identifier" {
    default = "wordpress"
}

variable "name" {
    default = "wordpress"
}


variable "path_to_public_key" {

  default = "~/devops/terrapro/project2/tkay.pub"

}