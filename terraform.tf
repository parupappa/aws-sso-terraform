terraform {
  cloud {
    organization = "organization-name"

    workspaces {
      name = "workspace-name"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }

  required_version = "~> 1.4.6"
}
