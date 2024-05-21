variable "environment" {
    type = string 
    default = "dev"
}

variable "application_name" {
    type = string 
    default = "merge-sort"
}

variable "app_port" {
    type = string 
    default = "3000"
}


variable "vpc_id" {
    type = string 
    default = ""
}

variable "subnet_id" {
    type = string
    default = ""
}

variable "ec2_ami_id" {
    type = string
    default = "ami-024e6efaf93d85776"
}

variable "ec2_instance_type" {
    type = string
    default = "t2.micro"
}

variable "ec2_key_name" {
    type = string
    default = "terraform-test"
}

variable "ec2_sg_ingress_rules" {
    type = map(object({
        description = string
        from_port = number
        to_port = number
        protocol = string
        cidr_blocks = list(string)
    }))
    default = {
        "http port" = {
            description = "HTTP port"
            from_port   = 3000
            to_port     = 3000
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]      
        },        
        "ssh port" = {
            description = "SSH port"
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }        
    }
}