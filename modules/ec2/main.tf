resource "aws_iam_role" "this" {
  name = "EC2-Role"
  path = "/"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  count = length(local.role_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = element(local.role_policy_arns, count.index)
}

resource "aws_iam_role_policy" "this" {
  name = "EC2-Inline-Policy"
  role = aws_iam_role.this.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameter"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_instance_profile" "this" {
  name = "EC2-Profile"
  role = aws_iam_role.this.name
}

resource "aws_security_group" "ec2_sg" {
  # vpc_id = var.vpc_id
  name        = "api"
  description = "Acceso por parte de maquina"

  dynamic "ingress" {
    for_each = var.ec2_sg_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks      
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = {
    Name = "${var.application_name}-${var.environment}-ec2-sg"
  }
}

resource "aws_network_interface" "ec2_eni" {
  security_groups = [aws_security_group.ec2_sg.id]
  # <--- HAS TO BE ON THE SAME AVAILABILITY ZONE AS aws_ebs_volume.availability_zone --->
  subnet_id = var.subnet_id  
  tags = {
    Name = "${var.application_name}-${var.environment}-ec2_network_interface"
  }
}

resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = "${file("${path.module}/${local.cw_agent_policy_filepath}")}"
  //value       = file("cw_agent_config.json")
}

data "template_file" "ec2_user_data" {
    template = "${file("${path.module}/${local.ec2_user_data_filepath}")}"
    vars = {
        app_port = var.app_port
        ssm_cloudwatch_config = aws_ssm_parameter.cw_agent.name
    }  
}

resource "aws_instance" "ec2_instance" {
  # <--- CURRENT AMI IS Ubuntu Server 22.04 LTS [ami-024e6efaf93d85776] --->
  ami                    = var.ec2_ami_id    
  instance_type          = var.ec2_instance_type 
  iam_instance_profile   = aws_iam_instance_profile.this.name

  # <--- CREATE KEY-PAIR IN AWS CONSOLE THEN REFERENCE NAME OF IT HERE --->
  key_name = var.ec2_key_name
  user_data = "${base64encode(data.template_file.ec2_user_data.rendered)}"
  tags = {
	  Name = "${var.application_name}-${var.environment}-node"			
  }

  network_interface {
    network_interface_id = aws_network_interface.ec2_eni.id
    device_index         = 0
  }

  # <--- THIS IS THE ROOT DISK --->
  root_block_device {
    volume_size           = "8"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
    tags = {
	    Name = "${var.environment}-demo_root_ebs_block_device"			
    }
  }

  # <--- [OPTIONAL] THIS IS AN EXTERNAL DATA DISK --->
  /*
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 1
    volume_type = "gp2"    
    encrypted = false
    delete_on_termination = true
    tags = {
	    Name = "${var.application_name}-${var.environment}-demo_data_ebs_block_device"			
    }
    #... other arguments ...
  }  
  */
}

/*
# <--- [OPTIONAL] THIS IS AN EXTERNAL DATA DISK --->
resource "aws_ebs_volume" "demo_ebs_volume" {  
  # <--- HAS TO BE ON THE SAME AVAILABILITY ZONE AS aws_network_interface.subnet_id --->
  availability_zone = aws_instance.ec2_instance.availability_zone
  size = 4 
  encrypted = false
  type = "gp2"
  tags = {
    Name = "${var.application_name}-${var.environment}-demo_ebs_volume"
  }

}

resource "aws_volume_attachment" "demo_ebs_volume_attachment" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.demo_ebs_volume.id
  instance_id = aws_instance.ec2_instance.id 
}
*/