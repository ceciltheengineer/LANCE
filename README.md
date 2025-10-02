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

Netlify / GitHub helper scripts
-------------------------------

I added two helper scripts under `scripts/` to simplify two common tasks:

- `scripts\get_netlify_site_id.ps1` — uses `netlify sites:list --json` (requires `netlify-cli`) to list your Netlify sites and copy the chosen site's `site_id` to the clipboard. Use `-Domain` to try to auto-find a site by domain.
- `scripts\set_github_secret.ps1` — uses the GitHub CLI (`gh`) to set a repository secret (detects the `origin` remote to infer `owner/repo` if not supplied). Example: `.\scripts\set_github_secret.ps1 -Name NETLIFY_SITE_ID` will prompt for the secret value and then store it in GitHub Actions secrets.

Example flow to enable CI deploys:

1. Install and login to Netlify CLI:

```powershell
npm install -g netlify-cli
netlify login
```

2. Get the Netlify site ID and copy it:

```powershell
.\scripts\get_netlify_site_id.ps1 -Domain "lance-ai.com"
```

3. Install and authenticate GitHub CLI (https://cli.github.com/) and then set secrets:

```powershell
gh auth login
.\scripts\set_github_secret.ps1 -Name NETLIFY_AUTH_TOKEN    # paste the token when prompted
.\scripts\set_github_secret.ps1 -Name NETLIFY_SITE_ID -Value "<your-site-id>"
```

After these steps the GitHub Actions workflow will be able to publish to Netlify automatically on push to `main`.

Troubleshooting: interactive login didn't open
------------------------------------------------

If the automatic browser auth did not open on your machine ("nothing opened"), here are manual alternatives to finish wiring Netlify → GitHub:

1) Netlify site ID (already known)

	- Site ID for `lance-ai.com`: 503478ba-32ee-47b1-9817-519db2fdedfc

2) Create a Netlify personal access token manually

	- Open: https://app.netlify.com/user/applications
	- Create a personal access token and copy its value.

3) Add GitHub repository secrets manually (if `gh` login doesn't open)

	- Open the repository on GitHub: https://github.com/ceciltheengineer/LANCE/settings/secrets/actions
	- Click "New repository secret" and add these two secrets:
	  - `NETLIFY_AUTH_TOKEN` — paste the Netlify personal access token you created.
	  - `NETLIFY_SITE_ID` — value: `503478ba-32ee-47b1-9817-519db2fdedfc`

4) If you prefer the CLI approach but interactive login didn't open, try these one-liners locally in PowerShell (you will need a browser for the auth flows):

```powershell
# Netlify CLI interactive login (opens browser)
netlify login

# GitHub CLI interactive login (opens browser)
gh auth login --web

# then set secrets via gh (once authenticated)
gh secret set NETLIFY_AUTH_TOKEN -R ceciltheengineer/LANCE
gh secret set NETLIFY_SITE_ID -R ceciltheengineer/LANCE --body "503478ba-32ee-47b1-9817-519db2fdedfc"
```

If you run into permissions or browser blockers, the manual GitHub UI steps above are the fastest way to finish.

Note about CI behavior
----------------------

I set the workflow to manual-only (`workflow_dispatch`) to avoid automatic failing runs while repository secrets are not configured. Netlify is already linked to the GitHub repo (the site settings show the repo), so pushes to the repository will still trigger Netlify's automatic deploys even if the GitHub Actions workflow remains manual.



