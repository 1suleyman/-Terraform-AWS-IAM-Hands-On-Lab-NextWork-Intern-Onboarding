# Terraform core configuration (provider, resources)


# 1. Configure AWS Provider

provider "aws" {
  region = var.aws_region
}

# 2. Using the aws_ami data source to fetch the latest Amazon Linux AMI

# 🔧 AMI presets: switch images by changing var.base_image
# - al2023       (owners = amazon)
# - ubuntu_jammy (owners = Canonical: 099720109477)
# - al2          (owners = amazon)
locals {
    # Amazon Machine Image Presets
  ami_presets = {
    # Imagine this as a restaurant menu:
    # Each recipe lists the chef (owners) and the dish name pattern (name).
    # owners → AWS account IDs or “amazon” to indicate the official owner.
    # name → The AMI name pattern (supports * wildcards) that matches the AMI you want.

    # Amazon Linux 2023 preset
    al2023 = {
      owners = ["amazon"]
      name   = "al2023-ami-*-kernel-6.1-x86_64"
    }
    # Ubuntu Jammy preset
    ubuntu_jammy = {
      owners = ["099720109477"] # Canonical
      name   = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    }
    # Amazon Linux 2 preset
    al2 = {
      owners = ["amazon"]
      name   = "amzn2-ami-hvm-*-x86_64-gp2"
    }
  }

# next ami_selected
# Purpose: Pick one preset from the menu based on the user’s choice in var.base_image.

# lookup(map, key, default) → Finds a value in a map by key, or returns a default if the key doesn’t exist.

# Here:

# local.ami_presets → The AMI menu we just built.

# var.base_image → The AMI name you want (passed in via Terraform variable).

# local.ami_presets["al2023"] → Default to Amazon Linux 2023 if you pass an invalid or missing value.

# Analogy:
# It’s like saying:

# “Look up the recipe for the image name I asked for. If it’s not on the menu, just give me the Amazon Linux 2023 recipe.”

  ami_selected = lookup(local.ami_presets, var.base_image, local.ami_presets["al2023"])
}

# 🔍 Dynamically find the latest AMI for the selected preset in this region
data "aws_ami" "selected" {
  most_recent = true
# Tells Terraform to pick the latest image that matches your filters.
# Without this, AWS might return an older one first.
  owners      = local.ami_selected.owners
# Uses the owners value from your earlier ami_selected local.
# Examples:
# ["amazon"] → Official Amazon Linux AMIs.
# ["099720109477"] → Canonical’s official Ubuntu AMIs.
# This ensures you don’t accidentally pull a fake/malicious image someone else published.

# the filter blocks narrow down the search results — each one is ANDed together (must match all)

  filter {
    name   = "name"
    values = [local.ami_selected.name]
# Matches the AMI name pattern from your preset (ami_presets).
# Supports * wildcards — so "al2023-ami-*-kernel-6.1-x86_64" matches any AL2023 image with kernel 6.1.
  }

  filter {
    name   = "architecture"
    values = [var.ami_architecture]
# Ensures you get the right CPU type (e.g., x86_64 or arm64).
# Controlled by a variable so you can switch if you ever run ARM-based EC2.
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]
# Most modern AWS instances use HVM (hardware virtual machine).
# Rarely changes unless using legacy PV virtualization.
  }

  filter {
    name   = "root-device-type"
    values = [var.ami_root_device_type]
# Defines the boot disk type:
# ebs → Root disk is an EBS volume (most common).
# instance-store → Temporary storage tied to the instance.
  }
}
# This data "aws_ami" currently runs a search in AWS for:

# Owner Amazon

# Name starting with al2023-ami...

# Architecture x86_64

# Virtualization hvm

# Root device ebs

# It picks the newest match in your current AWS region.

# Analogy:
# Think of this like ordering a coffee from a menu:

# The preset (ami_selected) is the type of drink you chose (Latte, Cappuccino, Espresso).

# The filters are your customizations (size, milk type, temperature).

# most_recent = true means “give me the freshest one available right now.”

# ...then in your aws_instance "app":
# ami = data.aws_ami.selected.id

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = ["your vpc id here"] # replace with your VPC ID
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}


# 3. Defining two EC2 instances

resource "aws_instance" "nextwork_dev" {
  ami           = data.aws_ami.selected.id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnets.public.ids[0]
  tags = {
    Name = "nextwork-dev-${var.owner}"
    Env  = "development"
  }
}

resource "aws_instance" "nextwork_prod" {
  ami           = data.aws_ami.selected.id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnets.public.ids[0]
  tags = {
    Name = "nextwork-prod-${var.owner}"
    Env  = "production"
  }
}

# 4. Creating the IAM JSON policy document using the iam_policy_dev json file

resource "aws_iam_policy" "nextwork_dev_policy" {
  name        = "NextWorkDevEnvironmentPolicy"
  description = "IAM Policy for NextWork's development environment"
  policy      = file("iam-policy-dev.json")
}

# This policy allows interns to manage EC2 instances tagged Env=development, but prevents them from touching production.

# 5. Creating IAM User Group and User

resource "aws_iam_group" "nextwork_dev_group" {
  name = "${var.dev_group_name}"
}

resource "aws_iam_group_policy_attachment" "attach_policy" {
  group      = aws_iam_group.nextwork_dev_group.name
  policy_arn = aws_iam_policy.nextwork_dev_policy.arn
}

resource "aws_iam_user" "intern_user" {
  name = "${var.intern_username}"
}

resource "aws_iam_user_group_membership" "intern_membership" {
  user = aws_iam_user.intern_user.name
  groups = [aws_iam_group.nextwork_dev_group.name]
}

# 6. Creating an account alias for easier login URL
resource "aws_iam_account_alias" "nextwork_alias" {
  account_alias = "nextwork-interns"
}
