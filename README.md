# rustpoint-web

Static website for [rustpoint.ai](https://rustpoint.ai) — hosted on Cloudflare Pages.

## Structure

```
rustpoint-web/
├── infra/terraform/        # IaC: Pages project, DNS, redirect rules
├── site/                   # Static HTML/CSS site
│   ├── index.html          # Home page
│   ├── privacy.html        # Privacy policy
│   ├── support.html        # Support page
│   ├── styles.css
│   └── assets/logo.svg
└── .github/workflows/
    └── deploy.yml          # Deploys site/ to Cloudflare Pages on push to main
```

## Deploy

Push to `main` — GitHub Actions deploys automatically via `wrangler pages deploy`.

### Required GitHub Secret

| Secret | Value |
|--------|-------|
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token with `Pages:Edit` + `Zone:DNS:Edit` permissions |

## Infrastructure (Terraform)

Managed via Terraform Cloud workspace `rustpoint-web-prod`.

### Variables (set in TFC)

| Variable | Description |
|----------|-------------|
| `cloudflare_api_token` | Cloudflare API token (sensitive) |
| `cloudflare_account_id` | Cloudflare account ID |
| `rustpoint_ai_zone_id` | Zone ID for rustpoint.ai |
| `rustpoint_io_zone_id` | Zone ID for rustpoint.io |

### Apply

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

## Local Preview

Open `site/index.html` in a browser, or use any static file server:

```bash
cd site
python3 -m http.server 8080
# → http://localhost:8080
```
