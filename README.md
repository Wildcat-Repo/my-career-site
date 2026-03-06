# My Career Site

A simple, secure static website for showcasing Theron Blount's personal profile, portfolio, and research, served by a minimal Express server.

## Overview

This repository contains:
- A static site under the `site/` directory (HTML/CSS) with sections for Home, About, Portfolio, Research, and Contact.
- A tiny Node/Express server (`server.js`) that serves the `site/` directory and applies a strict Content Security Policy (CSP).
- Cypress E2E test suite for automated testing.
- Gitea Actions CI/CD workflows for testing and deployment.

Default server address: http://localhost:8000

## Features

- Lightweight static site (no client-side JS required).
- Express-based static file hosting.
- Content Security Policy set to `default-src 'self'` to prevent loading external resources by default.
- Cypress E2E testing with Chrome browser support.
- Automated CI/CD via Gitea Actions (E2E tests on push, deployment to AWS Lightsail).
- Code formatting with Prettier.

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
   npm start
   ```

3. Open your browser and navigate to:
   ```
   http://localhost:8000
   ```

The server will serve files from the `site/` folder.

## npm Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Start the Express server |
| `npm test` | Run Cypress E2E tests (headless) |
| `npm run test:e2e:headed` | Run Cypress tests with browser UI |
| `npm run test:open` | Open Cypress interactive test runner |
| `npm run format` | Format code with Prettier |
| `npm run format:check` | Check code formatting |
| `npm run deploy` | Deploy to AWS Lightsail via rsync |

## Project Structure

```
my-career-site/
├── server.js              # Minimal Express server (default port 8000)
├── package.json           # Dependencies and scripts
├── cypress.config.js      # Cypress E2E test configuration
├── .gitea/
│   └── workflows/
│       ├── test.yml       # E2E test workflow (runs on push/PR to main)
│       └── deploy.yml     # AWS Lightsail deployment workflow
├── cypress/
│   ├── e2e/               # E2E test specs
│   └── support/           # Cypress support files
├── scripts/
│   ├── deploy-rsync.sh    # Rsync-based deployment script
│   ├── deploy-to-lightsail.sh
│   ├── deploy.sh
│   └── setup-nginx.sh     # Nginx configuration script
├── site/                  # Static website content
│   ├── index.html         # Home page
│   ├── styles.css         # Global styles (navigation, footer, social media)
│   ├── 404.html           # Custom 404 page
│   ├── about/
│   │   ├── index.html
│   │   └── about.css
│   ├── portfolio/
│   │   ├── index.html     # Portfolio grid
│   │   ├── portfolio.css
│   │   ├── spinjockey-network.html
│   │   ├── bookshare-architecture.html
│   │   ├── nfl-etl-architecture.html
│   │   └── development-server.html
│   ├── research/
│   │   ├── index.html     # Research article grid
│   │   ├── research.css
│   │   ├── computing_curricula_comparison.html
│   │   ├── fti_consulting_overview.html
│   │   ├── fti_internship_plan.html
│   │   └── sdet_interview_guide.html
│   ├── contact/
│   │   ├── index.html
│   │   └── contact.css
│   └── assets/
│       └── icons/         # SVG social media icons
├── resources/             # Architecture diagrams (SVG)
├── CLAUDE.md              # Claude Code project instructions
├── DEPLOYMENT.md          # Detailed deployment guide
└── .gitignore
```

## Configuration

- **Port**: The server listens on port `8000` by default, configurable via the `PORT` environment variable:
  ```bash
  PORT=3000 node server.js
  ```
- **Content Security Policy (CSP)**: The server applies `default-src 'self'`. To load external resources (fonts, images, scripts from CDNs), adjust the CSP header in `server.js`:
  ```js
  res.set('Content-Security-Policy', "default-src 'self'; img-src 'self' https:; style-src 'self' 'unsafe-inline' https:; font-src 'self' https:; script-src 'self' https:");
  ```

## Deployment

This application is configured for deployment to AWS Lightsail with automated CI/CD.

**Deployment Methods:**
1. **Automated (Gitea Actions)**: Automatically deploys when pushing to `main` branch
2. **Manual Script**: Run `npm run deploy`
3. **Manual SSH**: SSH to server and run deployment commands

**Production Environment:**
- **Platform**: AWS Lightsail (Bitnami Nginx Stack)
- **Process Manager**: PM2
- **Auto-restart**: Enabled on crashes and reboots

**For detailed deployment instructions**, see [DEPLOYMENT.md](./DEPLOYMENT.md)

## License

Add a license if you intend to open-source the site. For example, MIT License.

## Author

Theron Blount
