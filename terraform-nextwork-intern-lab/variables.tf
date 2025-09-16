# Input variables for instance types, AMI IDs, tags, usernames

# region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"
}
# ---------- AMI selection (no hardcoding) ----------
# Choose which base image to use without touching ec2.tf
# Allowed: "al2023", "ubuntu_jammy", "al2"

# Lets you choose a preset for the OS / AMI
variable "base_image" {
  description = "Base image preset to use for EC2"
  type        = string
  default     = "al2023"
}

# These control generic filters and can be overridden if needed.

# Filters AMIs by CPU type
variable "ami_architecture" {
  description = "CPU architecture to filter AMIs"
  type        = string
  default     = "x86_64"
}
# Filters AMIs by virtualization type (HVM, PV)
variable "ami_virtualization_type" {
  description = "Virtualization type to filter AMIs"
  type        = string
  default     = "hvm"
}
# Filters AMIs by root device type (ebs, instance-store)
variable "ami_root_device_type" {
  description = "Root device type to filter AMIs"
  type        = string
  default     = "ebs"
}

# owner tag for instances
variable "owner" {
  description = "The owner tag for the EC2 instances"
  type        = string
  default     = "suleyman"
}
# instance type for both instances
variable "instance_type" {
  description = "The type of instance to use for both EC2 instances"
  type        = string
  default     = "t2.micro"
}
# AMI for development instance
variable "dev_ami" {
  description = "The AMI ID for the development EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Example AMI ID, replace with a valid one
}
# AMI for production instance
variable "prod_ami" {
  description = "The AMI ID for the production EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Example AMI ID, replace with a valid one
}
# dev group name
variable "dev_group_name" {
  description = "The name of the IAM group for development"
  type        = string
  default     = "nextwork-dev-group"
}
# intern username
variable "intern_username" {
  description = "The username for the intern IAM user"
  type        = string
  default     = "nextwork-dev-lebronjr"
  
}
