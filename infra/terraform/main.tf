terraform {
  required_version = ">= 1.9"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "rustpoint"
    workspaces {
      name = "rustpoint-web-prod"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
