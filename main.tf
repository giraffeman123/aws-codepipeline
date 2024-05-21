provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "nodejs_api" {
    source = "./modules/ec2"    
    environment = "dev"
    application_name = "test-api"    
    # vpc_id = var.vpc_id
    subnet_id = var.subnet_id
    ec2_ami_id = "ami-024e6efaf93d85776"
    ec2_instance_type = "t2.micro"   
    ec2_key_name = "aws-test"
}

module "codepipeline" {
    source = "./modules/codepipeline"    
    environment = "dev"
    application_name = "test-api"    
    github_repository_url = "https://github.com/giraffeman123/merge-sort-api"
}