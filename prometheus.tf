#..................Prometheus node........................................

resource "aws_instance" "aws-prom" {
  ami = "ami-08a2aed6e0a6f9c7d"
    availability_zone = "eu-west-1a"
  instance_type = var.instance_type
  key_name = var.aws_key_name
  vpc_security_group_ids =[aws_security_group.bastion.id]
  subnet_id = aws_subnet.eu-west-1a-public.id
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
