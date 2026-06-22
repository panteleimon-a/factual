# Factual

> AI-powered news research platform — monorepo

[![Deploy to GitHub Pages](https://github.com/panteleimon-a/factual/actions/workflows/deploy-github-pages.yml/badge.svg)](https://github.com/panteleimon-a/factual/actions/workflows/deploy-github-pages.yml)

---

## Repository Structure

```
factual/
├── apps/
│   ├── mobile/          # Flutter Android app
│   │   └── factual/     # Flutter project root
│   └── web/             # Vite landing page → www.factual.gr
│       ├── index.html
│       ├── src/
│       └── public/
├── .github/
│   └── workflows/
│       └── deploy-github-pages.yml   # Auto-deploys apps/web on push to main
└── README.md
```

---

## Apps

### 📱 Mobile — `apps/mobile/`

Flutter Android application.

**Requirements:** Flutter SDK ≥ 3.x, Android Studio / SDK

```bash
cd apps/mobile/factual
flutter pub get
flutter run
```

See [`apps/mobile/factual/README.md`](apps/mobile/factual/README.md) for full setup, Firebase configuration, and feature documentation.

---

### 🌐 Web — `apps/web/`

Minimal Vite landing page deployed to [www.factual.gr](https://www.factual.gr) via GitHub Pages.

**Requirements:** Node.js ≥ 20

```bash
cd apps/web
npm install
npm run dev      # local dev server
npm run build    # production build → dist/
```

**Deployment:** Pushing to `main` (with changes under `apps/web/`) automatically triggers the GitHub Actions workflow and redeploys the live site.

---

## Branches

| Branch | Purpose |
|---|---|
| `main` | Production — landing page auto-deploys from here |
| `dev` | Development — legacy Django+Node app lives in `apps/django-web/` |
| `gh-pages` | Auto-managed by GitHub Actions (do not edit manually) |

---

## License

[MIT](LICENSE)
