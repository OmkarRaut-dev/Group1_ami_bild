packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "AMI-BUILD"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "amazon-ebs" "Blue" {
  ami_name      = "${var.ami_prefix}-Blue-${local.timestamp}"
  instance_type = "t3.small"
  region        = "ap-northeast-3"
 

  source_ami_filter {
    filters = {
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
    ssh_username = "ubuntu"
    tags = {
      "Name" = "Blue-Server"
    }
  
}

build {
  name = "  Blue-packer"
  sources = [
    "source.amazon-ebs.Blue",
  ]
  provisioner "ansible" {
    playbook_file   = "./playbooks/bluewebserver.yml"
  
  }
}

source "amazon-ebs" "Green" {
  ami_name      = "${var.ami_prefix}-Green-${local.timestamp}"
  instance_type = "t3.small"
  region        = "ap-northeast-3"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    "Name" = "Green-Server"
  }
  deprecate_at = timeadd(timestamp(), "8766h")
}

build {
  name = " Green-packer"
  sources = [
    "source.amazon-ebs.Green"
  ]
  provisioner "ansible" {
    playbook_file   = "./playbooks/greenwebserver.yml"
  }
}