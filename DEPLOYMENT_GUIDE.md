# Deployment Guide: factual.gr

## Current Status

The GitHub Pages deployment infrastructure is **fully configured and operational**:

- ✅ Deployment workflow: `.github/workflows/deploy-github-pages.yml`
- ✅ Latest successful deployment: 2026-01-19T08:54:08Z (Run #13)
- ✅ Deployment branch: `gh-pages` (auto-updated by workflow)
- ✅ Custom domain CNAME: `www.factual.gr`
- ✅ Site verified working locally (Vite dev server)
- ✅ Node.js dependencies installed successfully
- ⚠️ **GitHub Pages needs to be enabled in repository settings**

## Making the Site Live

### Step 1: Enable GitHub Pages (One-Time Setup)

GitHub Pages must be enabled in the repository settings:

1. Navigate to: https://github.com/panteleimon-a/factual/settings/pages
2. Under "Source", select **"Deploy from a branch"**
3. Under "Branch":
   - Select branch: **`gh-pages`**
   - Select folder: **`/ (root)`**
4. Click **"Save"**

### Step 2: Verify Deployment

After enabling GitHub Pages, the site will be deployed automatically. It may take a few minutes to become available.

The site will be accessible at:
- **Primary URL**: https://www.factual.gr
- **GitHub Pages URL**: https://panteleimon-a.github.io/factual/

### Step 3: DNS Configuration (Already Done)

The DNS configuration should point to GitHub Pages:

```
www.factual.gr → CNAME → panteleimon-a.github.io
factual.gr → A records → 185.199.108.153
                       → 185.199.109.153
                       → 185.199.110.153
                       → 185.199.111.153
```

**Note**: Both www subdomain and apex domain should be configured for proper functionality. The CNAME file in the repository is set to `www.factual.gr`, which will be the primary domain.

DNS propagation may take up to 48 hours, but typically completes within a few hours.

## Local Development

To run and test the site locally:

```bash
# Switch to the landing page branch
git checkout landing-page-deployment

# Install dependencies (first time only)
npm install

# Start the development server
npm run dev

# The site will be available at: http://localhost:5173/
```

The site is built with:
- **Vite** - Fast development server and build tool
- **Vanilla JavaScript** - No framework overhead
- **Modern CSS** - Clean, responsive design

## Automatic Deployment

The site automatically redeploys when changes are pushed to the `landing-page-deployment` branch:

```bash
# Make changes to the landing page
git checkout landing-page-deployment
# ... make your changes ...
git add .
git commit -m "Update landing page"
git push origin landing-page-deployment

# The GitHub Actions workflow will automatically:
# 1. Build the site
# 2. Push to gh-pages branch
# 3. Update the live site
```

## Troubleshooting

### Site Not Accessible

1. **Check GitHub Pages is enabled**: Visit the repository settings page
2. **Verify gh-pages branch exists**: Check https://github.com/panteleimon-a/factual/tree/gh-pages
3. **Check workflow status**: Visit https://github.com/panteleimon-a/factual/actions
4. **DNS propagation**: Use `dig www.factual.gr` or https://www.whatsmydns.net/

### Workflow Failures

Check the Actions tab for error logs:
https://github.com/panteleimon-a/factual/actions/workflows/deploy-github-pages.yml

### Custom Domain Issues

If www.factual.gr doesn't work after 24 hours:

1. Verify DNS records with your domain provider
2. Check CNAME file in gh-pages branch: https://github.com/panteleimon-a/factual/blob/gh-pages/CNAME
3. Review GitHub's custom domain documentation: https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site

## Manual Deployment Trigger

You can manually trigger a deployment:

1. Go to: https://github.com/panteleimon-a/factual/actions/workflows/deploy-github-pages.yml
2. Click "Run workflow"
3. Select branch: `landing-page-deployment`
4. Click "Run workflow"

## Site Content

The deployed site is a minimal landing page for the factual research project, including:

- Project description and branding
- Links to GitHub repository
- Links to LinkedIn profile
- Responsive design
- Clean, modern UI

## Contact

For issues or questions about the deployment, please open an issue in the repository.
