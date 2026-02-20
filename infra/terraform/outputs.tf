output "pages_project_subdomain" {
  description = "Cloudflare Pages default subdomain (*.pages.dev)"
  value       = cloudflare_pages_project.rustpoint_web.subdomain
}

output "pages_project_name" {
  description = "Cloudflare Pages project name"
  value       = cloudflare_pages_project.rustpoint_web.name
}
