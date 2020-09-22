resource "aws_vpc" "default" {

    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
        Name = "wordpress-aws-vpc"
    }
}

#.................internet gateway..............................

resource "aws_internet_gateway" "default" {

  vpc_id = aws_vpc.default.id

}

#...............key pair....................................

resource "aws_key_pair" "tkay" {

  key_name = "tkay"

  public_key = file(var.path_to_public_key)

}

#..............................Availability Zone 1a.....................................................

#...............route table.....................................

resource "aws_route_table" "eu-west-1a-public" {
    vpc_id = aws_vpc.default.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }

    tags = {
        Name = "Public_1a Subnet"
    }
}


resource "aws_route_table" "eu-west-1a-private" {
    vpc_id = aws_vpc.default.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.gw.id
    }

    tags = {
        Name = "Private_1a route_table"
    }
}




#.............route table associations........................



resource "aws_route_table_association" "eu-west-1a-public" {
    subnet_id = aws_subnet.eu-west-1a-public.id
    route_table_id = aws_route_table.eu-west-1a-public.id
}



resource "aws_route_table_association" "eu-west-1a-private" {
    subnet_id = aws_subnet.eu-west-1a-private.id
    route_table_id = aws_route_table.eu-west-1a-private.id
}





#.............subnets.......................................

resource "aws_subnet" "eu-west-1a-private" {
    vpc_id = aws_vpc.default.id
    
    cidr_block = var.private_1a_subnet_cidr
    availability_zone = "eu-west-1a"

    tags = {
        Name = "Private_1a Subnet"
    }
}



 resource "aws_subnet" "eu-west-1a-public" {
    vpc_id = aws_vpc.default.id

    cidr_block = var.public_1a_subnet_cidr
    availability_zone = "eu-west-1a"

    tags = {
        Name = "Public_1a Subnet"
    }
}


#.............................Availability Zone 1b..............................................

#...............route table.....................................


resource "aws_route_table" "eu-west-1b-public" {
    vpc_id = aws_vpc.default.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }

    tags = {
        Name = "Public_1b Subnet"
    }
}


resource "aws_route_table" "eu-west-1b-private" {
    vpc_id = aws_vpc.default.id

    route {
        cidr_block = "0.0.0.0/0"
        #nat_gateway_id = aws_nat_gateway.gw1b.id
        nat_gateway_id = aws_nat_gateway.gw.id
    }

    tags = {
        Name = "Private_1b route_table"
    }
}


#.............route table associations........................



resource "aws_route_table_association" "eu-west-1b-public" {
    subnet_id = aws_subnet.eu-west-1b-public.id
    route_table_id = aws_route_table.eu-west-1b-public.id
}



resource "aws_route_table_association" "eu-west-1b-private" {
    subnet_id = aws_subnet.eu-west-1b-private.id
    route_table_id = aws_route_table.eu-west-1b-private.id
}





#.............subnets.......................................

resource "aws_subnet" "eu-west-1b-private" {
    vpc_id = aws_vpc.default.id
    
    cidr_block = var.private_1b_subnet_cidr
    availability_zone = "eu-west-1b"

    tags = {
        Name = "Private_1b Subnet"
    }
}



 resource "aws_subnet" "eu-west-1b-public" {
    vpc_id = aws_vpc.default.id

    cidr_block = var.public_1b_subnet_cidr
    availability_zone = "eu-west-1b"

    tags = {
        Name = "Public_1b Subnet"
    }
}


#..............Elastic Load Balancer...............................

resource "aws_elb" "bar" {
  name               = "wordpress-elb"
  #availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  subnets = [aws_subnet.eu-west-1a-public.id, aws_subnet.eu-west-1b-public.id]
  security_groups = [aws_security_group.elb.id]

  

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "http:80/wordpress/wp-admin/install.php"
    interval            = 5
  }
 

  #instances                   = [aws_instance.bastion_1a.id, aws_instance.bastion_1b.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "wordpress-elb"
  }
}

#..................Launch Configuration...............................

resource "aws_launch_configuration" "as_conf" {
  #image_id      = var.amis[var.aws_region]
  image_id      = "ami-00127e6d28650776b"
  instance_type = var.instance_type
  name ="terraform-launch-config"
  key_name = var.aws_key_name
  security_groups = [aws_security_group.web.id]
  iam_instance_profile = aws_iam_instance_profile.prometheus-instance-profile.name
  user_data = data.template_file.myuserdata1.rendered
  #associate_public_ip_address = false
  #depends_on = ["aws_db_instance.default"]

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "myuserdata1" {

  template = file("${path.cwd}/word.tpl")
  vars = {
    #database_host="tunde"
     database_host=aws_db_instance.default.address
   }
}

# output "database_host" {
#   value = aws_db_instance.default.address
# }

#..................Autoscaling Group...............................

resource "aws_autoscaling_group" "bar" {
  name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 1
  max_size             = 3
  health_check_grace_period = 30
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  #placement_group           = aws_placement_group.test.id
  vpc_zone_identifier       = [aws_subnet.eu-west-1a-private.id, aws_subnet.eu-west-1b-private.id]
  #availability_zones = ["eu-west-1a", "eu-west-1b"]
  

  lifecycle {
    create_before_destroy = true
  }

 tag {
   
   key = "Name"
   value = "wordpress_AS"
   propagate_at_launch = true
  
}

}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.bar.id
  elb                    = aws_elb.bar.id
}






