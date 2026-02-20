# ===========================================================
# Cloudflare Pages Project
# ===========================================================

resource "cloudflare_pages_project" "rustpoint_web" {
  account_id        = var.cloudflare_account_id
  name              = "rustpoint-web"
  production_branch = "main"
}

# Custom domain binding: rustpoint.ai → Pages project
resource "cloudflare_pages_domain" "rustpoint_ai" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.rustpoint_web.name
  domain       = "rustpoint.ai"
}

# ===========================================================
# DNS: rustpoint.ai zone
# ===========================================================

# Apex CNAME → Pages subdomain (proxied for Cloudflare routing)
resource "cloudflare_dns_record" "rustpoint_ai_apex" {
  zone_id = var.rustpoint_ai_zone_id
  name    = "@"
  type    = "CNAME"
  content = cloudflare_pages_project.rustpoint_web.subdomain
  proxied = true
  ttl     = 1 # Auto-TTL when proxied
}

# www → apex (proxied)
resource "cloudflare_dns_record" "rustpoint_ai_www" {
  zone_id = var.rustpoint_ai_zone_id
  name    = "www"
  type    = "CNAME"
  content = "rustpoint.ai"
  proxied = true
  ttl     = 1
}

# ===========================================================
# Redirect: rustpoint.io → rustpoint.ai (301)
# Uses Cloudflare Redirect Rules (free tier, no Workers cost)
# ===========================================================

resource "cloudflare_redirect_rules" "rustpoint_io_to_ai" {
  zone_id = var.rustpoint_io_zone_id

  rules {
    description = "Redirect all rustpoint.io traffic to rustpoint.ai"
    enabled     = true

    action {
      response {
        status_code           = 301
        url                   = "https://rustpoint.ai"
        preserve_query_string = false
      }
    }

    # Match all requests unconditionally
    expression = "true"
  }
}
