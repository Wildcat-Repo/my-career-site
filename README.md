# My Career Site

A simple, secure static website for showcasing Theron Blount’s personal profile, portfolio, and research, served by a minimal Express server.

## Overview

This repository contains:
- A static site under the `site/` directory (HTML/CSS) with sections for Home, About, Portfolio, Research, and Contact.
- A tiny Node/Express server (`server.js`) that serves the `site/` directory and applies a strict Content Security Policy (CSP).

Default server address: http://localhost:3000

## Features

- Lightweight static site (no client-side JS required).
- Express-based static file hosting.
- Content Security Policy set to `default-src 'self'` to prevent loading external resources by default.

## Prerequisites

- Node.js 18+ (recommended)
- npm (comes with Node.js)

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start the server:
   ```bash
   node server.js
   ```

3. Open your browser and navigate to:
   ```
   http://localhost:3000
   ```

The server will serve files from the `site/` folder.

## Project Structure

```
my-career-site/
├─ server.js            # Minimal Express server (port 3000)
├─ site/                # Static website content
│  ├─ index.html        # Home page
│  ├─ styles.css        # Global styles with navigation, footer, and social media components
│  ├─ about/
│  │  ├─ index.html
│  │  └─ about.css
│  ├─ portfolio/
│  │  ├─ index.html
│  │  ├─ portfolio.css
│  │  ├─ spinjockey-network.html
│  │  ├─ bookshare-architecture.html
│  │  ├─ nfl-etl-architecture.html
│  │  └─ development-server.html
│  ├─ research/
│  │  ├─ index.html
│  │  ├─ research.css
│  │  ├─ computing_curricula_comparison.html
│  │  ├─ fti_consulting_overview.html
│  │  ├─ fti_internship_plan.html
│  │  └─ sdet_interview_guide.html
│  ├─ contact/
│  │  ├─ index.html
│  │  └─ contact.css
│  └─ assets/
│     └─ icons/         # SVG social media icons
├─ resources/           # Architecture diagrams (SVG)
├─ package.json         # Dependencies (Express)
└─ .gitignore
```

## Configuration

- Port: The server currently listens on port `3000` (hard-coded in `server.js`). If you need a different port, update the `port` constant in `server.js`.
- Content Security Policy (CSP): The server applies `default-src 'self'`. If you need to load external fonts, images, scripts, or CSS (e.g., from a CDN), you’ll need to adjust the CSP header in `server.js` accordingly. Example:
  ```js
  res.set('Content-Security-Policy', "default-src 'self'; img-src 'self' https:; style-src 'self' 'unsafe-inline' https:; font-src 'self' https:; script-src 'self' https:");
  ```

## Suggested npm Scripts (optional)

While not required, you can add these to `package.json` for convenience:
```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "node server.js"
  }
}
```
Then run:
```bash
npm run start
```

## Deployment

This application is configured for deployment to AWS Lightsail with automated CI/CD.

**Quick Deploy:**
```bash
npm run deploy
```

**Deployment Methods:**
1. **Automated (Gitea Actions)**: Automatically deploys when pushing to `main` branch
2. **Manual Script**: Run `npm run deploy` or `./scripts/deploy-to-lightsail.sh`
3. **Manual SSH**: SSH to server and run deployment commands

**Production Environment:**
- **Platform**: AWS Lightsail (Bitnami Nginx Stack)
- **URL**: http://44.235.108.165:3000 (or via Nginx on port 80)
- **Process Manager**: PM2
- **Auto-restart**: Enabled on crashes and reboots

**For detailed deployment instructions**, see [DEPLOYMENT.md](./DEPLOYMENT.md)

## License

Add a license if you intend to open-source the site. For example, MIT License.

## Author

Theron Blount
