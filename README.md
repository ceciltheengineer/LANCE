LANCE Website
===============

This repository contains the static website for LANCE AI.

What this repo contains
- `index.html` — main site
- `netlify.toml` — Netlify configuration (publish = ".")
- `Images/`, `Logo/` — static assets

Is this connected to a live site?
- The public site https://lance-ai.com is live and currently serves the same content as `index.html` in this repo.
- This repo contains `netlify.toml`, so it's configured to be deployed to Netlify from the repo root. However, there is no local `.netlify` folder or site ID in the repository, so we can't prove the exact Netlify dashboard binding from files alone.

Quick verification steps (PowerShell)

# 1) Inspect HTTP headers to confirm host and provider
curl -I https://lance-ai.com

# 2) Fetch the homepage HTML to compare fingerprints
curl https://lance-ai.com | Select-String -Pattern "LANCE AI" -SimpleMatch

# 3) If this directory is a Git repo, check remotes
if (Test-Path .git\config) { Get-Content .git\config }

How to publish or redeploy

Option A — Push to connected Git provider
- If Netlify is connected to your Git provider (GitHub/GitLab/Bitbucket), push to the branch Netlify watches (commonly `main` or `master`) and Netlify will auto-deploy.

Option B — Deploy from your machine using Netlify CLI
```powershell
# install netlify CLI (if not installed)
npm install -g netlify-cli

# login interactively (opens browser)
netlify login

# test deploy to a draft URL (useful to preview)
netlify deploy --dir=. 

# publish to production
netlify deploy --prod --dir=.
```

Notes & recommendations
- I updated `og:url` and added a `canonical` link in `index.html` to use `https://lance-ai.com` as the canonical domain. If you prefer `lancecompany.com.mx` instead, tell me and I can switch it.
- If you want me to confirm the Git remote or add Netlify automation (e.g., a GitHub Action or README with CI), I can do that next.

Next steps I can take for you
- Inspect `.git/config` (if this is a Git repo here) to find the remote and check for automatic Netlify linkage.
- Add a small deployment script or GitHub Actions workflow to automatically build and deploy (not necessary since this is static).
- Wire Netlify CLI deploy steps into a tiny `scripts/deploy.ps1` to make local deploys one-command.

Tell me which next step you want and I will do it.

GitHub Actions: auto-deploy to Netlify
------------------------------------

A GitHub Actions workflow was added at `.github/workflows/deploy-netlify.yml` that runs on `push` to `main` or `master` and uses the Netlify CLI to publish the site.

Required repository secrets (set these in GitHub > Settings > Secrets & Variables > Actions):
- `NETLIFY_AUTH_TOKEN` — a personal access token from Netlify (create in Netlify user settings > Applications > Personal access tokens).
- `NETLIFY_SITE_ID` — the Netlify site ID for the site that will receive the deploys (you can find this in your site settings on Netlify or by running `netlify sites:list` locally while authenticated).

Security notes:
- Keep `NETLIFY_AUTH_TOKEN` secret. The workflow injects it into the `netlify` command only at runtime.
- If you prefer not to store tokens in GitHub, you can remove the workflow and use the `scripts/deploy.ps1` local workflow instead.

Repository cleanup performed
--------------------------

During a workspace inspection I found a stray Git metadata file at `Images/.git/COMMIT_EDITMSG`. I removed that file to avoid accidental nested Git repositories which can confuse CI or deploy tools. If you intentionally had a nested repository there, tell me and I will restore or move it.

Quick scripts (PowerShell)
---------------------------

Two small helper scripts are added under `scripts/` to make verification and deploys easy from Windows PowerShell:

- `scripts\verify_site.ps1` — compares a SHA256 fingerprint of your local `index.html` against a live URL (defaults to `https://lance-ai.com`). Useful to confirm the live site matches this repository copy.
- `scripts\deploy.ps1` — wraps Netlify CLI to create a preview deploy or publish to production. It checks for `netlify` in PATH and prints install guidance if missing.

Usage examples (PowerShell):

```powershell
# Verify live site matches local index
.\scripts\verify_site.ps1

# Verify another domain
.\scripts\verify_site.ps1 -Url "https://example.com"

# Create a draft deploy (preview)
.\scripts\deploy.ps1

# Publish to production
.\scripts\deploy.ps1 -Prod
```

Notes
- `deploy.ps1` requires `netlify-cli` installed globally (`npm install -g netlify-cli`).
- `verify_site.ps1` saves the fetched remote HTML into a temporary file if the contents differ so you can inspect the remote copy.
