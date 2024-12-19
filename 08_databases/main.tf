terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      School  = var.school
      Project = var.project
    }
  }
}

provider "random" {
}

module "network" {
  source  = "./modules/network"
  region  = var.region
  project = var.project
}

module "databases" {
  source  = "./modules/databases"
  region  = var.region
  project = var.project
  vpc_id  = module.network.vpc_id
  subnet_a_id = module.network.subnet_a_id
  subnet_b_id = module.network.subnet_b_id
  public_subnet_a_id = module.network.public_subnet_a_id
}

