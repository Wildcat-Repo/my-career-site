# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a static personal portfolio website for Theron Blount, served by a minimal Express.js server. The site showcases professional profile, portfolio projects, and research work with a focus on security through strict Content Security Policy (CSP).

## Development Commands

### Start the Server
```bash
node server.js
```
The server runs on `http://localhost:8000` by default and serves the `site/` directory.

### Install Dependencies
```bash
npm install
```

## Architecture

### Server Architecture
- **server.js**: Minimal Express server (15 lines) that:
  - Applies strict CSP header: `default-src 'self'` to all responses
  - Serves static files from `site/` directory
  - Runs on port 8000 by default (`process.env.PORT || 8000`)

### Site Structure
The `site/` directory contains a multi-page static site organized by section:

```
site/
├── index.html              # Homepage
├── styles.css              # Global styles with shared navigation/footer/social media components
├── about/
│   ├── index.html
│   └── about.css           # Section-specific styles
├── portfolio/
│   ├── index.html          # Portfolio grid listing 4 projects
│   ├── portfolio.css
│   └── [project].html      # Individual project detail pages
├── research/
│   ├── index.html
│   ├── research.css
│   └── [article].html      # Individual research articles
├── contact/
│   ├── index.html
│   └── contact.css
└── assets/
    └── icons/              # SVG social media icons
```

### CSS Architecture
- **Global styles** (`site/styles.css`): Defines navigation, footer, and reusable social media components using BEM-like naming (`.social-media__*`)
- **Section-specific styles**: Each section (about, portfolio, research, contact) has its own CSS file for section-specific layouts
- **Social media icons**: Embedded as inline SVG data URIs in styles.css for LinkedIn, GitHub, and Twitter
- **Layout pattern**: Fixed header navigation, centered main content (max-width: 800px), fixed footer

### Navigation Pattern
All HTML pages follow a consistent navigation structure:
- Relative links from root: `href="about/"`, `href="portfolio/"`
- Relative links from subdirectories: `href="../about/"`, `href="../index.html"`
- Active page indicated with `aria-current="page"`

### Content Security Policy
The server applies `Content-Security-Policy: default-src 'self'` to prevent loading external resources. When adding external resources (CDN fonts, images, scripts), the CSP header in `server.js:6` must be updated to allow specific sources.

## Key Files

- **server.js**: Express server configuration and CSP implementation
- **site/styles.css**: Global styles and shared component definitions
- **site/portfolio/index.html**: Portfolio grid with project cards
- **resources/**: SVG architecture diagrams for portfolio projects

## Static Assets
- SVG icons are in `site/assets/icons/` but also embedded inline in `styles.css`
- Architecture diagrams for portfolio projects are in `resources/` directory
- No client-side JavaScript is used (purely static HTML/CSS)

## Port Configuration
The server port defaults to 8000 and is configurable via the `PORT` environment variable: `const port = process.env.PORT || 8000;` (defined in `server.js:3`).
