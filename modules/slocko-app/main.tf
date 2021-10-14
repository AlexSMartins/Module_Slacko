data "aws_ami" "slacko-app"  {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amazon*"]
    }
    
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
}

data "aws_subnet" "subnet_public" {
	cidr_block = var.subnet_cidr
}

resource "aws_key_pair" "slacko-sshkey" {
 key_name = var.Key_name
 public_key = var.public_key
}

resource "aws_instance" "slacko-app" {
 ami = data.aws_ami.slacko-app.id
 instance_type = "t2.micro"
 subnet_id = data.aws_subnet.subnet_public.id
 associate_public_ip_address = true
 
 tags = merge(
    var.tags,
    {
      Name = local.SufixName_ec2
    },
  )
 key_name = aws_key_pair.slacko-sshkey.id
 user_data = file("./modules/slocko-app/files/ec2.sh") 
} 

resource "aws_instance" "mongodb" {
 ami = data.aws_ami.slacko-app.id
 instance_type = "t2.micro"
 subnet_id = data.aws_subnet.subnet_public.id

 tags = merge(
    var.tags,
    {
      Name = local.SufixName_ec2
    },
  )
 
 key_name = aws_key_pair.slacko-sshkey.id
 user_data = file("./modules/slocko-app/files/mongodb.sh") 

} 

resource "aws_security_group" "allow_slacko" {
 name = local.SufixName_SG_App
 description = "Allow ssh and http port"
 vpc_id = var.vpc
 
 ingress = [ 
  {
   description = "Allow SSH"
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
   self = true
   prefix_list_ids = null 
   security_groups = null
  },
  {
   description = "Allow HTTP"
   from_port = 80
   to_port = 80
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
   self = true
   prefix_list_ids = null 
   security_groups = null
  }
 ]

 egress = [ 
  {
   description = "Allow SSH"
   from_port = 0
   to_port = 0
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
   self = true
   prefix_list_ids = null 
   security_groups = null
  }
 ]
 
 tags = merge(
    var.tags,
    {
      Name = local.SufixName_SG_App
    },
  )

}

resource "aws_security_group" "allow_mongodb" {
 name = local.SufixName_SG_Db
 description = "Allow mongodb"
 vpc_id = var.vpc
 
 ingress = [ 
  {
   description = "Allow mongodb"
   from_port = 27017
   to_port = 27017
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
   self = true
   prefix_list_ids = null 
   security_groups = null
  }
  ]
  
 egress = [ 
  {
   description = "Allow all"
   from_port = 0
   to_port = 0
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
   self = true
   prefix_list_ids = null 
   security_groups = null
  }
 ]
 
 tags = merge(
    var.tags,
    {
      Name = local.SufixName_SG_Db
    },
  )
}

resource "aws_network_interface_sg_attachment" "mongodb-sg" {
    security_group_id = aws_security_group.allow_mongodb.id
    network_interface_id = aws_instance.mongodb.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "slacko-sg" {
    security_group_id = aws_security_group.allow_slacko.id
    network_interface_id = aws_instance.slacko-app.primary_network_interface_id
}

resource "aws_route53_zone" "slack_zone" {
	name = local.SufixName_r53
	
	vpc {
		vpc_id = var.vpc
	}
}

resource "aws_route53_record" "mongodb" {
	zone_id = aws_route53_zone.slack_zone.id
	name = "mongodb.iaac0506.com.br"
	type = "A"
	ttl = "300"
	records = [aws_instance.mongodb.private_ip]
}