variable "aws_region" {
    type = string
    default = "us-east-2"
}

variable "aws_access_key" {
    type = string 
    default = ""
}

variable "aws_secret_key" {
    type = string 
    default = ""
}

variable "environment" {
    type = string 
    default = "dev"
}

variable "application" {
    type = string 
    default = "merge-sort"
}
