variable "cloudflare_api_token" {
  description = "Cloudflare API token with Pages, DNS, and Zone settings permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "rustpoint_ai_zone_id" {
  description = "Zone ID for rustpoint.ai"
  type        = string
}

variable "rustpoint_io_zone_id" {
  description = "Zone ID for rustpoint.io"
  type        = string
}
