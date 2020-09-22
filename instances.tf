#............Availability Zone 1a..........................................


#....................nat gateway............................

resource "aws_eip" "natgw_1a" {
    
    vpc = true
}


resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.natgw_1a.id
  subnet_id     = aws_subnet.eu-west-1a-public.id

  tags = {
    Name = "Private_1a NAT"
  }
}





#........................Bastion Host..............................

resource "aws_instance" "bastion_1a" {
    ami = var.amis[var.aws_region]
    availability_zone = "eu-west-1a"
    instance_type = var.instance_type
    key_name = var.aws_key_name
    vpc_security_group_ids = [aws_security_group.bastion.id]
    subnet_id = aws_subnet.eu-west-1a-public.id
    associate_public_ip_address = true
    
    tags = {
        Name = "Bastion Host_1a"
    }
}


#..........................database...................................

resource "aws_db_instance" "default" {
  #count                           = 1
  instance_class                  = "db.t2.micro"
  engine                          = "mysql"
  engine_version                  = "8.0.17"
  vpc_security_group_ids          = [aws_security_group.db.id]
  db_subnet_group_name            = aws_db_subnet_group.default.id
  
  identifier                      = var.identifier
  skip_final_snapshot             = true
  allocated_storage               = 20
  storage_type                    = "gp2"
  multi_az                        = false
  #backup_window                   = 
  #backup_retention_period         = 
  name                            = var.name
  username                        = "admin12"
  password                        = "wordpress2020"
  publicly_accessible             = false
  storage_encrypted               = false
  apply_immediately               = true
  #enabled_cloudwatch_logs_exports = []

  
   tags = {
    Environment = "dev"
  }
}

output "database_host" {
  value = aws_db_instance.default.address
}

resource "aws_db_subnet_group" "default" {
  name       = "main_subnet_group"
  subnet_ids = [aws_subnet.eu-west-1a-private.id, aws_subnet.eu-west-1a-public.id, aws_subnet.eu-west-1b-private.id, aws_subnet.eu-west-1b-public.id]

  tags = {
    Name = "My DB subnet group"
  }
}
#.......................................Availability Zone 1b.............................................


#........................Bastion Host..............................

resource "aws_instance" "bastion_1b" {
    ami = var.amis[var.aws_region]
    availability_zone = "eu-west-1b"
    instance_type = var.instance_type
    key_name = var.aws_key_name
    vpc_security_group_ids =[aws_security_group.bastion.id]
    subnet_id = aws_subnet.eu-west-1b-public.id
    associate_public_ip_address = true
    
    tags = {
        Name = "Bastion Host_1b"
    }
}

