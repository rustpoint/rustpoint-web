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
  name         = "rustpoint.ai"
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
# DNS: rustpoint.ai email & verification (pre-existing)
# ===========================================================

resource "cloudflare_dns_record" "rustpoint_ai_mx" {
  zone_id  = var.rustpoint_ai_zone_id
  name     = "@"
  type     = "MX"
  content  = "smtp.google.com"
  priority = 10
  ttl      = 1
}

resource "cloudflare_dns_record" "rustpoint_ai_txt_google" {
  zone_id = var.rustpoint_ai_zone_id
  name    = "@"
  type    = "TXT"
  content = "google-site-verification=XTdAdyG-tJRh5Dzs3SuzCcC94vKvR1lkO63KSZtkR5M"
  ttl     = 1
}

resource "cloudflare_dns_record" "rustpoint_ai_caa_sectigo" {
  zone_id = var.rustpoint_ai_zone_id
  name    = "@"
  type    = "CAA"
  ttl     = 1
  data = {
    flags = 0
    tag   = "issue"
    value = "sectigo.com"
  }
}

resource "cloudflare_dns_record" "rustpoint_ai_caa_google" {
  zone_id = var.rustpoint_ai_zone_id
  name    = "@"
  type    = "CAA"
  ttl     = 1
  data = {
    flags = 0
    tag   = "issue"
    value = "pki.goog"
  }
}

resource "cloudflare_dns_record" "rustpoint_ai_caa_letsencrypt" {
  zone_id = var.rustpoint_ai_zone_id
  name    = "@"
  type    = "CAA"
  ttl     = 1
  data = {
    flags = 0
    tag   = "issue"
    value = "letsencrypt.org"
  }
}

# ===========================================================
# Email DNS: Resend domain verification for rustpoint.ai
# Ref: Resend dashboard → Domains → rustpoint.ai
# ===========================================================

# DKIM signing key (Resend account-specific public key)
resource "cloudflare_dns_record" "rustpoint_ai_resend_dkim" {
  zone_id = var.rustpoint_ai_zone_id
  name    = "resend._domainkey"
  type    = "TXT"
  content = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDK5hOfrsYfHxtxIlx1LO0y5da0sYY71YmLm7eJJ4A/EpWewhGEaJn9OnZulZWbZirmaPwF5+MIR/ol7LMraFHkx7AmgDCIUjX/g9Ae10mLPmloGs03dMy1XUK48uwayP3hNuvkEVrES6/KEQ6kfp9O9Ab7RjtPOSNW07m2qinseQIDAQAB"
  proxied = false
  ttl     = 1
}

# MX: SES bounce/feedback routing for send.rustpoint.ai
resource "cloudflare_dns_record" "rustpoint_ai_send_mx" {
  zone_id  = var.rustpoint_ai_zone_id
  name     = "send"
  type     = "MX"
  content  = "feedback-smtp.us-east-1.amazonses.com"
  proxied  = false
  ttl      = 1
  priority = 10
}

# SPF: Authorize SES to send from send.rustpoint.ai
resource "cloudflare_dns_record" "rustpoint_ai_send_spf" {
  zone_id = var.rustpoint_ai_zone_id
  name    = "send"
  type    = "TXT"
  content = "v=spf1 include:amazonses.com ~all"
  proxied = false
  ttl     = 1
}

# DMARC policy for rustpoint.ai
resource "cloudflare_dns_record" "rustpoint_ai_dmarc" {
  zone_id = var.rustpoint_ai_zone_id
  name    = "_dmarc"
  type    = "TXT"
  content = "v=DMARC1; p=none;"
  proxied = false
  ttl     = 1
}

# ===========================================================
# Redirect: rustpoint.io → rustpoint.ai (301)
# Uses Cloudflare Ruleset (http_request_dynamic_redirect phase)
# ===========================================================

resource "cloudflare_ruleset" "rustpoint_io_redirect" {
  zone_id     = var.rustpoint_io_zone_id
  name        = "Redirect rustpoint.io to rustpoint.ai"
  description = "301 redirect all rustpoint.io traffic to rustpoint.ai"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [{
    ref         = "redirect_io_to_ai"
    description = "Redirect all rustpoint.io traffic to rustpoint.ai"
    expression  = "(http.host eq \"rustpoint.io\") or (http.host eq \"www.rustpoint.io\")"
    action      = "redirect"
    action_parameters = {
      from_value = {
        status_code = 301
        target_url = {
          value = "https://rustpoint.ai"
        }
        preserve_query_string = false
      }
    }
  }]
}
