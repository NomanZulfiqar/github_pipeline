# ##########################################
# ##  AWS terraform Remote Backend Config ##
# ##########################################

terraform {
  backend "s3" {
    region         = "us-east-1"                                              # Terraform Backend AWS regions (Need to update the key to the account name)
    key            = "ec2/terraform.tfstate"                                  # S3 bucket directoy structure for terraform state file to store
    bucket         = "noman-rocket-zulfiqar-terraform-backend-us-east-1"      # Update S3 bucket name output from terraform backend script
    dynamodb_table = "noman-rocket-zulfiqar-terraform-backend-us-east-1.lock" # Update DynamoDB name output from terraform backend script
    encrypt        = true
  }

  required_version = ">= 1.0.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.7"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
  }
}


# ####################################
# ##  AWS terraform Provider Config ##
# ####################################

provider "aws" {

  region = local.region

  default_tags {
    tags = {
      Application = "${local.application}"
      Owner       = "${local.owner}"
      Purpose     = "${local.purpose}"
      Stack       = "${local.stack_name}"
      Terraform   = "true"
      Environment = "${local.environment}"
    }
  }

}


provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

