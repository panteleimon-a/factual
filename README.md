<p align="center">
  <img src="apps/web/public/logo.png" width="200" alt="factual logo">
</p>

<h1 align="center">factual</h1>

<p align="center">
  <strong>An open-source tool to enhance the fact-checking process.</strong><br>
  Cross-validate sources · Detect news reproductions · Surface what the world is asking.
</p>

<p align="center">
  <a href="https://www.factual.gr">🌐 factual.gr</a> &nbsp;·&nbsp;
  <a href="https://github.com/panteleimon-a/factual/actions/workflows/deploy-github-pages.yml">
    <img src="https://github.com/panteleimon-a/factual/actions/workflows/deploy-github-pages.yml/badge.svg" alt="Deploy">
  </a>
</p>

---

## The Problem

In a world where media outlets are increasingly censored, consolidated, and controlled, independent and truly unbiased journalism is under threat. Verifying a story means opening dozens of tabs, manually comparing sources, and guessing at bias — all under deadline pressure.

**factual** changes that.

---

## What It Does

> *"Review how news is reported throughout the world from different sources — easily and fast, from your phone."*

factual is a mobile-first platform built for journalists, researchers, and informed citizens. It aggregates, cross-validates, and contextualises news in real time using AI-powered agents — so you spend less time searching and more time understanding.

### Core Features

| Feature | Description |
|---|---|
| **Cross-Source Validation** | Compare the same story across multiple publishers side by side |
| **Duplicate & Reproduction Detection** | Identify when stories are copied, repackaged, or amplified |
| **AI Fact-Checking Agents** | Gemini-powered agents assess credibility and surface divergence from consensus |
| **Adaptive Feed** | Personalised news stream built from your reading history, location, and interests |
| **Geographic News Map** | See how a story is reported differently across regions on an interactive map |
| **Voice Search** | Natural language queries — ask anything, hands-free |
| **Spread Velocity Graph** | Visualise how fast a story is propagating across sources |

---

## How the AI Works

factual uses a **three-axis intelligence model**:

**1. User Modeling & Adaptation**  
Tracks reading history and search patterns to build a personal interest profile. Uses Gemini to generate three tailored search strategies — *Direct Mix*, *Tangential*, and *Discovery* — fetching personalised articles in parallel.

**2. Affective Computing**  
Analyses the emotional tone of queries and articles to distinguish factual reporting from sensationalism, and adjusts results to match user intent.

**3. Spatio-Temporal Connectivity**  
Links articles that share the same location, time window, and topic — revealing coordinated reporting patterns and geopolitical context invisible to a standard search.

```
User Query / Voice Input
      ↓
Gemini Agent — sentiment + intent + query generation
      ↓
NewsData.io — parallel fetch (3 strategies)
      ↓
Dedup + Credibility Assessment + Spread Analysis
      ↓
Personalised Feed + Map Visualisation
      ↓
User feedback → model updates
```

---

## SR Editorial Protocol

factual applies a **tiered source credibility model** to every article:

| Tier | Source Type | Weight |
|---|---|---|
| **Tier 1** | Primary sources & official data | Highest |
| **Tier 2** | Public service media & established agencies | High |
| **Tier 3** | Commercial news media | Medium |

The AI agents use this framework to cross-reference claims, flag divergence, and rate certainty — giving you a clinical, non-judgmental view of every story.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter (Android, cross-platform) |
| AI | Google Gemini 2.0 Flash |
| News Data | NewsData.io API |
| Auth & Sync | Firebase Anonymous Auth + Cloud Firestore |
| Local Storage | SQLite |
| Maps | Google Maps API |
| Landing Page | Vite + vanilla JS → GitHub Pages |

---

## Repository Structure

```
factual/
├── apps/
│   ├── mobile/          # 📱 Flutter Android app
│   │   └── factual/     # Flutter project root
│   └── web/             # 🌐 Vite landing page → www.factual.gr
├── .github/
│   └── workflows/
│       └── deploy-github-pages.yml
└── README.md
```

### Getting Started

**Mobile app**
```bash
cd apps/mobile/factual
flutter pub get
flutter run
```
> Requires Flutter ≥ 3.x, Android 8.0+, Google Play Services.  
> See [`apps/mobile/factual/README.md`](apps/mobile/factual/README.md) for Firebase setup and full docs.

**Landing page (local dev)**
```bash
cd apps/web
npm install
npm run dev
```

---

## Branches

| Branch | Purpose |
|---|---|
| `main` | Production — landing page auto-deploys from here |
| `dev` | Development — legacy Django+Node backend in `apps/django-web/` |
| `gh-pages` | Auto-managed by GitHub Actions (do not edit manually) |

---

## Who It's For

- **Independent journalists** — verify stories fast, under deadline
- **News consumers** — understand reporting bias without the noise
- **Fact-check organisations** — monitor misinformation patterns at scale
- **Academic researchers** — study media bias and geographic coverage

---

## License

[MIT](LICENSE) · Built at the National Technical University of Athens (NTUA) · School of Electrical & Computer Engineers
