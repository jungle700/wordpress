#..................Prometheus node........................................

resource "aws_instance" "aws-prom" {
  ami = "ami-08a2aed6e0a6f9c7d"
    availability_zone = "eu-west-1a"
  instance_type = var.instance_type
  key_name = var.aws_key_name
  vpc_security_group_ids =[aws_security_group.prometh.id]
  iam_instance_profile = aws_iam_instance_profile.prometheus-instance-profile.name
  subnet_id = aws_subnet.eu-west-1a-prometh.id
  associate_public_ip_address = true
  user_data = data.template_file.myprom.template

  tags = {
    Name = "aws-prom"
    prometheus = "true"
    node_exporter = "true"
  }
}

data "template_file" "myprom" {

  template = file("${path.cwd}/prom.tpl")
}

#.....................................role.....................................................................
resource "aws_iam_role" "prometheus-ec2-role" {
  name = "prometheus"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  tags = {
    tag-key = "prome_iam_role"
  }
}

resource "aws_iam_role_policy_attachment" "prometheus-sd-policy-attach" {
  role       = aws_iam_role.prometheus-ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess" 
}

resource "aws_iam_instance_profile" "prometheus-instance-profile" {
  name = "promtheus"
  role = aws_iam_role.prometheus-ec2-role.name
}

#................................security_group prometheus.........................................
resource "aws_security_group" "prometh" {
    name = "vpc_prometh"
    description = "Allow incoming connections to Prometheus."


   
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
   
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 9090
        to_port = 9090
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

     ingress {
        from_port = 9100
        to_port = 9100
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

     ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }



    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

   
    vpc_id = aws_vpc.foo.id

    tags = {
        Name = "Prometh_Host_SG"
    }
}

#......................Prometheus VPC.................................

resource "aws_vpc" "foo" {
  cidr_block = "10.1.0.0/20"
  enable_dns_hostnames = true
  tags = {
        Name = "prometh-aws-vpc"
    }

}

#.................internet gateway..............................

resource "aws_internet_gateway" "prometh" {

  vpc_id = aws_vpc.foo.id

}

#...................Subnet..........................................

resource "aws_subnet" "eu-west-1a-prometh" {
    vpc_id = aws_vpc.foo.id

    cidr_block = "10.1.10.0/23"  
    availability_zone = "eu-west-1a"

    tags = {
        Name = "Prometh_1a Subnet"
    }
}

#...............route table.....................................


resource "aws_route_table" "eu-west-1a-prometh" {
    vpc_id = aws_vpc.foo.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prometh.id
    }

    tags = {
        Name = "Prometh_1a_Subnet"
    }
}


#.............route table associations.......................................

resource "aws_route_table_association" "eu-west-1a-prometh" {
    subnet_id = aws_subnet.eu-west-1a-prometh.id
    route_table_id = aws_route_table.eu-west-1a-prometh.id
}

