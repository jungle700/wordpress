
resource "aws_security_group" "web" {
    name = "Wordpress_Private_SG"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion.id]
         
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.elb.id]
    }
    
    ingress {
        from_port = 9100
        to_port = 9100
        protocol = "tcp"
        security_groups = [aws_security_group.prometh.id]
    }
    
   
   egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }



    vpc_id = aws_vpc.default.id

    tags = {
        Name = "Wordpress_Private_SG"
    }
}


resource "aws_security_group" "bastion" {
    name = "vpc_bastion"
    description = "Allow incoming connections to Bastion host."

   
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

   
    vpc_id = aws_vpc.default.id

    tags = {
        Name = "Bastion_Host_SG"
    }
}




resource "aws_security_group" "db" {
    name = "vpc_db"
    description = "Allow incoming database connections."

    ingress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.web.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    

    vpc_id = aws_vpc.default.id

    tags = {
        Name = "DBServerSG"
    }
}

resource "aws_security_group" "elb" {
    name = "elb_SG"
    description = "Allow incoming HTTP connections."
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }  
   egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

    vpc_id = aws_vpc.default.id

    tags = {
        Name = "elb_SG"
    }
}
