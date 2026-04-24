# SpinJockey Network: A Modular Content Management and Production Platform for Independent Film

**Technical White Paper v1.0**
**Author:** Theron Blount
**Date:** February 2026

---

## Executive Summary

**SpinJockey Network** is a modular content management and production platform purpose-built for independent filmmakers and creative studios. The system addresses a gap in the film production tooling landscape: existing solutions either lack the domain-specific features screenwriters and producers need, or lock teams into monolithic SaaS platforms that offer limited extensibility and no self-hosting option.

The platform is architected around three components. **SpinJockey Network** serves as the core application — a Rails 8 multi-tenant CMS providing project management, role-based access control across an 8-tier permission model, secure content distribution, and administrative oversight with full audit logging. **Screenplay Editor**, a mountable Rails engine with a React/TypeScript frontend built on TipTap (ProseMirror), integrates directly into the platform to deliver industry-standard screenplay authoring, version history, inline review, and PDF/text export via a Playwright rendering pipeline. **Script Analysis**, a standalone Node.js/Express application, provides a structured 100-point scoring framework for screenplay evaluation across four phases — designed for independent use today, with a planned integration path into the platform.

A key architectural decision underpins the entire suite: the elimination of Redis as an infrastructure dependency. All three concerns traditionally requiring Redis — background jobs, caching, and WebSocket pub/sub — are handled by Rails 8's Solid Stack (Solid Queue, Solid Cache, Solid Cable), backed by PostgreSQL. This reduces operational complexity for self-hosted deployments without sacrificing capability.

The platform is production-deployed at spinjockey.net, backed by Gitea Actions CI/CD, and supports both self-hosted (Debian/systemd) and cloud (Render.com) deployment models.

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [SpinJockey Network — Core Platform](#3-spinjockey-network--core-platform)
4. [Screenplay Editor — Integrated Engine](#4-screenplay-editor--integrated-engine)
5. [Script Analysis — Companion Tool](#5-script-analysis--companion-tool)
6. [Cross-Cutting Concerns](#6-cross-cutting-concerns)
7. [Deployment & Operations](#7-deployment--operations)
8. [Roadmap](#8-roadmap)
9. [Conclusion](#9-conclusion)

---

## 1. Introduction

### 1.1 Problem Statement

Independent film production demands coordination across a wide range of digital assets — screenplays, storyboards, character guides, budgets, contracts, marketing materials, and more — typically managed through a fragmented mix of generic tools: Google Drive for storage, Final Draft or WriterSolo for screenwriting, spreadsheets for budgeting, and email for distribution. This fragmentation creates several concrete problems:

- **No unified access control.** Production teams need granular control over who can see what. A lead actor shouldn't access budget documents; an investor shouldn't see early rough drafts. Generic cloud storage offers folder-level permissions at best.
- **No domain-specific workflow support.** Screenplay authoring requires strict formatting standards (Courier 12pt, fixed margins, industry-standard element indentation). General-purpose editors cannot enforce these constraints.
- **No integrated evaluation pipeline.** Script coverage — the structured evaluation of a screenplay's commercial and artistic viability — is typically performed manually with no connection to the authoring tool or project management system.
- **Vendor lock-in and cost.** Commercial screenwriting software is proprietary, often expensive, and rarely offers self-hosting. For independent studios operating on constrained budgets, this is a significant barrier.

### 1.2 Design Goals

SpinJockey Network was designed around four core principles:

1. **Modularity.** The platform is composed of distinct, independently deployable components. The screenplay editor is a mountable Rails engine — not a tightly coupled feature — meaning it can be versioned, tested, and published independently. The script analysis tool operates standalone today and will integrate via API in a future release.

2. **Self-hosting as a first-class concern.** The infrastructure dependency graph is deliberately minimal. By eliminating Redis through Rails 8's Solid Stack and using PostgreSQL as the single external database dependency, the platform can run on a single Debian server with systemd — no container orchestration required.

3. **Domain specificity.** Every technical decision is informed by film production requirements. The permission model maps to real production roles. The content type system reflects actual production asset categories. The screenplay editor enforces industry formatting standards.

4. **Security by default.** The platform assumes adversarial conditions: strict Content Security Policy, rate limiting on authentication endpoints, account lockout, session fixation protection, audit logging for all administrative actions, and input sanitization with XSS prevention.

### 1.3 Scope of This Document

This white paper provides a technical overview of the SpinJockey Network platform architecture, its integrated Screenplay Editor engine, and the standalone Script Analysis companion tool. It is intended for engineers and architects evaluating the system's design, integration patterns, and deployment characteristics. Business context is included where it informs technical decisions.

---

## 2. System Architecture Overview

### 2.1 Component Map

The system is organized into three distinct components with well-defined boundaries:

```
+---------------------------------------------------------------+
|                    SpinJockey Network                          |
|                  (Rails 8 Application)                        |
|                                                               |
|  +------------------+  +------------------+  +--------------+ |
|  |   User & Auth    |  |    Project &     |  |    Admin      | |
|  |   Management     |  |    Content CMS   |  |   Dashboard   | |
|  +------------------+  +------------------+  +--------------+ |
|                                                               |
|  +----------------------------------------------------------+|
|  |           Screenplay Editor (Mounted Engine)               ||
|  |  Rails API  |  React/TipTap Frontend  |  Node.js Renderer ||
|  +----------------------------------------------------------+|
|                                                               |
|  +------------------+  +------------------+  +--------------+ |
|  |   Solid Queue    |  |   Solid Cache    |  |  Solid Cable  | |
|  |  (Background)    |  |   (Caching)      |  |  (WebSocket)  | |
|  +------------------+  +------------------+  +--------------+ |
|                                                               |
|  +----------------------------------------------------------+|
|  |              PostgreSQL (Multi-Database)                    ||
|  |   primary  |   queue   |   cache   |   cable              ||
|  +----------------------------------------------------------+|
+---------------------------------------------------------------+

+---------------------------------------------------------------+
|                  Script Analysis (Standalone)                  |
|              Node.js / Express / SQLite                        |
|                                                               |
|  +------------------+  +------------------+  +--------------+ |
|  |   Dashboard &    |  |   Analysis       |  |   REST API    | |
|  |   Management UI  |  |   Interface      |  |   (7 endpts)  | |
|  +------------------+  +------------------+  +--------------+ |
|                                                               |
|  +----------------------------------------------------------+|
|  |                     SQLite Database                         ||
|  |              scripts  |  analyses                          ||
|  +----------------------------------------------------------+|
+---------------------------------------------------------------+
```

**SpinJockey Network** is the core platform — a full Rails 8 application that handles authentication, authorization, project management, content distribution, and administration. It hosts the Screenplay Editor as a mounted engine at the `/screenplays` route namespace, sharing authentication context, database connections, and background job infrastructure.

**Screenplay Editor** is distributed as a Ruby gem (`screenplay_editor`, v0.1.7) and mounted into the host application. It brings its own models, controllers, views, migrations, and a React/TypeScript frontend bundled via Vite. It also includes four standalone TypeScript packages (`@studio/screenplay-model`, `@studio/screenplay-parse`, `@studio/screenplay-export`, `@studio/screenplay-cli`) that are framework-agnostic and usable outside the Rails context.

**Script Analysis** is a self-contained Node.js/Express application with its own SQLite database, designed for independent deployment. It communicates with no external services today. Future integration with SpinJockey Network will be achieved through a REST API bridge, allowing analysis scores to be associated with platform projects.

### 2.2 Technology Selection Rationale

| Decision | Choice | Rationale |
|---|---|---|
| **Core framework** | Rails 8.1.2 | Convention-over-configuration reduces boilerplate; Rails 8's Solid Stack eliminates Redis; mature ecosystem for CMS workloads |
| **Editor framework** | TipTap 2.1 (ProseMirror) | Schema-enforced document model prevents invalid formatting; extensible node/mark system maps naturally to screenplay elements; collaborative editing support via Yjs planned |
| **Frontend strategy** | React + TypeScript (editor), Hotwire (platform) | React's component model suits the complex, interactive editor UI; Hotwire's server-driven approach suits the CMS pages where interactivity is minimal |
| **PDF rendering** | Playwright (Chromium) | Vector PDF output with precise pagination; HTML-to-PDF pipeline allows CSS-based formatting control; avoids fragile PDF generation libraries |
| **Script analysis stack** | Express + SQLite | Lightweight, zero-dependency stack appropriate for a standalone evaluation tool; SQLite eliminates database server management for single-user deployments |
| **Background jobs** | Solid Queue | PostgreSQL-backed job processing; no Redis required; advisory locks for reliability; native Rails 8 integration |
| **Authorization** | Pundit | Policy-object pattern keeps authorization logic testable and colocated with domain models; avoids DSL complexity of CanCanCan |
| **Authentication** | Custom (BCrypt) | Full control over security policy (lockout, expiration, complexity); avoids Devise's opinionated session management; fewer dependencies |

### 2.3 Deployment Topology

The platform supports two deployment models:

**Self-Hosted (Primary)**
```
Debian Server (optiserv)
├── systemd service: spinjockey-network (Puma)
├── systemd service: postgresql
├── Gitea Actions runner (CI/CD)
├── DNS: spinjockey.net (GoDaddy)
└── SSL: enforced in production
```

**Cloud (Render.com)**
```
Render Multi-Service
├── Web Service: Rails application (Puma + Thruster)
├── Worker Service: Solid Queue background jobs
├── Node Renderer: Playwright PDF service
└── PostgreSQL: Managed database
```

Both models deploy from the same codebase with environment-driven configuration. The self-hosted model is the production deployment; the Render configuration serves as a cloud-ready alternative.

---

## 3. SpinJockey Network — Core Platform

### 3.1 Application Architecture

SpinJockey Network follows standard Rails MVC conventions with a few deliberate structural choices:

**Multi-Database Configuration.** Rails 8's multi-database support is used to isolate concerns across four PostgreSQL databases per environment:

| Database | Purpose | Rationale |
|---|---|---|
| `spinjockey_network_primary` | Application data (users, projects, content) | Core domain storage |
| `spinjockey_network_queue` | Solid Queue job tables | Isolates job throughput from application queries |
| `spinjockey_network_cache` | Solid Cache entries | Prevents cache eviction from impacting application tables |
| `spinjockey_network_cable` | Solid Cable pub/sub state | WebSocket message storage isolated from transactional data |

This separation ensures that background job polling, cache writes, and WebSocket message delivery do not contend with application queries at the database level.

**Controller Organization.** The application uses a namespaced admin interface (`Admin::BaseController`) separate from the public-facing controllers. Admin controllers inherit a shared base that enforces admin-role authentication and provides common audit logging behavior.

```
controllers/
├── admin/
│   ├── base_controller.rb          # Auth enforcement, audit hooks
│   ├── dashboard_controller.rb     # System statistics
│   ├── projects_controller.rb      # Project CRUD
│   ├── users_controller.rb         # User management
│   └── content_items_controller.rb # Content management
├── auth_sessions_controller.rb     # Login/logout
├── auth_registrations_controller.rb
├── auth_passwords_controller.rb
├── projects_controller.rb          # Public project views
├── content_items_controller.rb     # Content display
├── dashboard_controller.rb         # User dashboard
└── screenplays_controller.rb       # Screenplay editor bridge
```

**Service Layer.** Domain logic that spans multiple models is extracted into service objects:

- `ContentProcessorService` — HTML parsing, sanitization, and transformation for user-submitted content
- `PresenceService` — Manages collaborative presence state for screenplay editing sessions

### 3.2 Authentication System

Authentication is implemented from scratch rather than using Devise. This was a deliberate choice to maintain full control over security policy without inheriting Devise's session management opinions or its large dependency surface.

**Registration Flow:**
1. User submits registration form
2. Password validated against complexity requirements (8+ characters, mixed case, numbers, special characters)
3. User record created with `registered` role and `email_confirmed: false`
4. Confirmation email dispatched asynchronously via Resend API (Solid Queue)
5. User clicks confirmation link, setting `email_confirmed: true`

**Login Flow:**
1. Email/password validated against BCrypt hash
2. Account lockout check: 5 failed attempts triggers 30-minute lockout
3. Password expiration check: 90-day policy
4. Session created with fixation protection (`reset_session` before assignment)
5. Session timeout: 2 hours of inactivity

**Password Security:**
- BCrypt hashing with automatic salt
- Complexity validation: minimum 8 characters, requires uppercase, lowercase, numeric, and special characters
- 90-day expiration with forced password change flow
- Password reset via time-limited email tokens

### 3.3 Authorization Model

Authorization uses Pundit's policy-object pattern. The system defines eight user roles organized into a hierarchical permission model:

```
guest → registered → premium → industry_professional → collaborator → admin
                                                         ↓
                                                    quarantined → blocked
```

**Role Capabilities:**

| Role | Content Access | Project Access | Admin Access |
|---|---|---|---|
| Guest | Public only | View public projects | None |
| Registered | Public + registered | View accessible projects | None |
| Premium | Public + registered + premium | View + limited interaction | None |
| Industry Professional | All non-admin content | Full project interaction | None |
| Collaborator | Project-scoped access | Assigned projects only | None |
| Admin | All content | All projects | Full dashboard |

Content access is enforced at two levels: the project level and the individual content item level. A content item's access level cannot exceed its parent project's access level, ensuring that a public project cannot contain admin-only content items that would be invisible to the project's intended audience.

### 3.4 Content Management

The content model is designed around film production asset types:

**Supported Content Types:**
screenplay, storyboard, character guide, marketing material, production notes, budget, contract, image, video, audio, document, webpage

**Storage Strategy.** Content items support two storage modes:
- **HTML content** — Rich text stored directly in the database, processed through `ContentProcessorService` with Sanitize (RELAXED configuration) for XSS prevention
- **File reference** — Path to an uploaded file, managed through `ProjectDirectoryMapping` for organized filesystem storage

**Access Tracking.** The `UserContentAccess` join model records every content view, enabling:
- View count aggregation per content item
- Unique viewer counts
- Per-user access history for audit purposes
- Content engagement analytics on the admin dashboard

### 3.5 Security Architecture

Security is implemented as a layered defense:

**Network Layer — Rack::Attack:**
```ruby
# Rate limiting configuration
throttle("password_reset/ip", limit: 3, period: 1.hour)
throttle("password_reset/email", limit: 2, period: 1.hour)
# Suspicious request blocking (PHP, ASP, .env probes)
blocklist("suspicious_requests") { |req| req.path =~ /\.(php|asp|env)/ }
```

**Application Layer:**
- Content Security Policy enforced on all responses
- Session fixation protection via `reset_session` on login
- CSRF token validation on all state-changing requests
- Input sanitization via Sanitize gem (RELAXED config with scoped CSS classes)
- Host authorization headers in production

**Audit Layer:**
- `SecurityAuditLog` model records all sensitive administrative actions
- User quarantine/block/restore operations logged with reasons and IP addresses
- Admin preference persistence for filter/sort/search state (preventing UI-based information leakage through shared admin sessions)

**Monitoring:**
- Sentry integration for exception tracking and performance monitoring in production
- reCAPTCHA v3 on public-facing forms

### 3.6 Database Design

The core schema comprises six primary models with nine performance indices:

```
users
├── id, email, password_digest, role, email_confirmed
├── failed_login_attempts, locked_until
├── password_changed_at
└── timestamps

projects
├── id, title, slug, description, status, access_level
├── creator_id (FK → users)
└── timestamps

content_items
├── id, project_id (FK → projects)
├── title, content_type, access_level
├── html_content, file_path
├── metadata (JSON)
└── timestamps

user_content_accesses
├── id, user_id (FK → users), content_item_id (FK → content_items)
└── accessed_at

security_audit_logs
├── id, admin_id, target_user_id, action, reason, ip_address
└── timestamps

project_directory_mappings
├── id, project_id (FK → projects)
├── base_path
└── timestamps
```

**Index Strategy:**
- Composite index on `user_content_accesses(user_id, content_item_id)` for efficient access checks
- Index on `projects(slug)` for URL resolution
- Index on `projects(creator_id)` for user dashboard queries
- Index on `content_items(project_id, content_type)` for filtered content listings
- Index on `users(email)` for authentication lookups
- Additional indices on foreign keys and status fields for admin filtering

**Project Status Workflow:**
```
development → pre_production → production → post_production → completed → archived
```

---

## 4. Screenplay Editor — Integrated Engine

### 4.1 Rails Engine Architecture

The Screenplay Editor is packaged as a mountable Rails engine (`screenplay_editor` gem, v0.1.7), following Rails' engine conventions for namespace isolation and host application integration.

**Mounting:**
```ruby
# Host application routes.rb
mount ScreenplayEditor::Engine, at: "/screenplays"
```

**Shared Infrastructure.** When mounted in SpinJockey Network, the engine inherits:
- Authentication context (current user from host application session)
- Authorization policies (Pundit, using the host's 8-tier role system)
- Background job infrastructure (Solid Queue)
- Caching layer (Solid Cache)
- WebSocket pub/sub (Solid Cable)
- Database connection (PostgreSQL, host application's primary database)

**Isolation.** The engine maintains its own:
- Model namespace (`ScreenplayEditor::Script`, `ScreenplayEditor::ScriptVersion`, `ScreenplayEditor::ScriptComment`)
- Controller namespace (`ScreenplayEditor::ScriptsController`, etc.)
- Database migrations (3 migrations, prefixed to avoid collision)
- Frontend assets (React bundle via Vite Rails)
- TypeScript packages (independent npm monorepo)

This architecture allows the engine to be versioned and published independently. Updates to the screenplay editor are delivered as gem version bumps, with migrations run during the host application's standard migration process.

### 4.2 Frontend Stack

The editor frontend is a React 18 application written in TypeScript, using TipTap 2.1 (a ProseMirror wrapper) as the core editing framework. This is a deliberate divergence from the host application's Hotwire frontend — the interactive complexity of a screenplay editor (real-time formatting, cursor management, collaborative presence) exceeds what Hotwire's server-driven model can efficiently deliver.

**Why TipTap/ProseMirror:**
- **Schema-enforced documents.** ProseMirror's schema system prevents invalid document structures at the editor level. A screenplay element (scene heading, action, dialogue) is a schema node, not a CSS-styled paragraph — the editor physically cannot produce a malformed screenplay.
- **Extensibility.** Custom TipTap extensions map directly to screenplay elements, each with their own input rules, keyboard shortcuts, and rendering logic.
- **Collaboration-ready.** ProseMirror's transaction-based state model is compatible with Yjs, enabling conflict-free real-time collaboration in a future release.

**Build Pipeline:**
The React frontend is bundled via Vite and served through Vite Rails integration. In development, Vite provides hot module replacement. In production, assets are precompiled and served through the Rails asset pipeline (Propshaft).

### 4.3 Document Model

Screenplays are stored as ProseMirror JSON documents in the `doc_json` JSONB column of `screenplay_editor_script_versions`:

```typescript
interface ScriptDoc {
  elements: ScriptElement[];
}

interface ScriptElement {
  id: string;           // UUID (unique within document)
  type: ElementType;
  text: string;
  metadata?: Record<string, unknown>;
}

type ElementType =
  | "scene_heading"
  | "action"
  | "character"
  | "parenthetical"
  | "dialogue"
  | "transition"
  | "shot"
  | "note";
```

This model is defined in the `@studio/screenplay-model` TypeScript package — a standalone, framework-agnostic module that can be consumed by any JavaScript/TypeScript application.

**Formatting Rules:**
The editor enforces industry-standard screenplay formatting:
- Courier 12pt monospaced font
- Fixed margins (~55 lines per page)
- Element-specific indentation (character names centered, dialogue at 2.5" left margin, parentheticals at 3" left margin)
- Automatic page breaks with scene continuation headers

### 4.4 Import/Export Pipeline

**Import Paths:**

| Format | Parser | Package |
|---|---|---|
| Plain text (April-style) | Regex-based line parser | `@studio/screenplay-parse` |
| PDF | Text extraction + structural parsing | `@studio/screenplay-parse` |

Both parsers produce a `ScriptDoc` object that is stored as a new `ScriptVersion`.

**Export Paths:**

| Format | Generator | Pipeline |
|---|---|---|
| Plain text | Template formatter | `@studio/screenplay-export` → text file |
| PDF | HTML renderer → Playwright | `@studio/screenplay-export` → HTML → Chromium → vector PDF |

**PDF Rendering Pipeline:**
PDF export uses a Node.js sidecar process running Playwright (headless Chromium). The pipeline:

1. `ExportPdfJob` enqueued via Solid Queue
2. Job invokes `ScreenplayEditor::NodeRunner`, which shells out to the Node.js process
3. `@studio/screenplay-export` generates semantic HTML with CSS print styles
4. Playwright renders HTML in Chromium with `@media print` rules
5. Vector PDF captured and stored via `ProjectDirectoryMapping`

This approach produces publication-quality PDFs with correct pagination, headers, and scene numbering — capabilities that are difficult to achieve with Ruby-native PDF libraries.

### 4.5 Version History and Review System

**Versioning.** Every save creates a new `ScriptVersion` record with an auto-incremented `version_num`. The full document JSON is stored in each version, enabling point-in-time restoration without diff reconstruction.

**Inline Comments.** The `ScriptComment` model supports positional annotations:
- `range_anchor` (JSONB) stores the ProseMirror position reference
- Comments can be resolved/unresolved with `resolved_at` timestamps
- Comments are scoped to the script, visible to authorized users per Pundit policies

**Review Features:**
- Scene numbering (automatic, based on scene heading elements)
- Watermark support for draft distribution
- Title page generation from script metadata

### 4.6 TypeScript Package Architecture

The editor's core logic is extracted into four standalone npm packages, organized as a monorepo under `packages/`:

```
packages/
├── screenplay-model/     # @studio/screenplay-model
│   └── src/types.ts      # ScriptDoc, ScriptElement, ElementType
├── screenplay-parse/     # @studio/screenplay-parse
│   └── src/text.ts       # Plain text and PDF import parsers
├── screenplay-export/    # @studio/screenplay-export
│   └── src/text.ts       # Plain text and HTML export formatters
└── screenplay-cli/       # @studio/screenplay-cli
    └── src/index.ts      # CLI tool for batch import/export
```

These packages are framework-agnostic. They depend only on TypeScript standard library types and can be consumed by any JavaScript runtime. This means the import/export pipeline can be used outside the Rails context — in a CLI tool, a CI pipeline, or a future standalone editor application.

### 4.7 Collaboration Infrastructure

Real-time collaboration infrastructure is in place but not yet fully activated:

**Current State (v0.1.7):**
- `ScreenplaySession` model tracks active editing sessions
- `PresenceService` manages presence state (who is editing, cursor positions)
- Solid Cable (Action Cable without Redis) provides WebSocket transport
- Frontend presence indicators display active collaborators
- `CleanupStaleSessionsJob` garbage-collects abandoned sessions

**Planned (v2.0):**
- Yjs integration for conflict-free real-time collaborative editing
- Operational transformation via ProseMirror's collaboration plugin
- Per-element locking for concurrent scene editing

---

## 5. Script Analysis — Companion Tool

### 5.1 Application Architecture

Script Analysis is a deliberately lightweight application — a single Express.js server backed by SQLite, serving a vanilla HTML/CSS/JavaScript frontend. This architectural simplicity is intentional: the tool is designed to be deployable anywhere Node.js runs, with zero external service dependencies.

```
Express Server (server.js, 251 lines)
├── Database Layer: SQLite3 with Promise wrappers
├── Validation Layer: express-validator chains
├── Static Files: public/ (dashboard.html, analyze.html)
└── Migration System: lib/migrate.js
```

**Database Helper Pattern:**
All database access is wrapped in Promise-returning functions, enabling async/await throughout the application:

```javascript
async function dbRun(sql, params) { /* Promise-wrapped sqlite3.run */ }
async function dbGet(sql, params) { /* Promise-wrapped sqlite3.get */ }
async function dbAll(sql, params) { /* Promise-wrapped sqlite3.all */ }
```

**Schema:**

```sql
scripts (
  id          INTEGER PRIMARY KEY,
  title       TEXT NOT NULL,
  author      TEXT,
  genre       TEXT,
  page_count  INTEGER,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP
)

analyses (
  id              INTEGER PRIMARY KEY,
  script_id       INTEGER REFERENCES scripts(id) ON DELETE CASCADE,
  phase1_score    INTEGER CHECK(phase1_score BETWEEN 0 AND 35),
  phase2_score    INTEGER CHECK(phase2_score BETWEEN 0 AND 35),
  phase3_score    INTEGER CHECK(phase3_score BETWEEN 0 AND 25),
  phase4_score    INTEGER CHECK(phase4_score BETWEEN 0 AND 5),
  total_score     INTEGER CHECK(total_score BETWEEN 0 AND 100),
  checklist_data  TEXT,  -- JSON serialized checkbox states
  created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP
)
```

### 5.2 Scoring Framework

The analysis system implements a structured 100-point evaluation framework organized into four phases. The scoring model was designed to align with industry script coverage practices while providing quantifiable, repeatable assessments.

**Phase 1: Foundational Elements (35 points)**

| Category | Points | Evaluates |
|---|---|---|
| Format & Structure | 15 | Scene heading conventions, page length, white space, slug line formatting, act structure |
| Story Fundamentals | 20 | Premise clarity, inciting incident, stakes, conflict escalation, resolution |

**Phase 2: Character & Dialogue (35 points)**

| Category | Points | Evaluates |
|---|---|---|
| Character Development | 20 | Protagonist arc, antagonist dimension, supporting character distinction, motivation |
| Dialogue Quality | 15 | Voice distinction, subtext, exposition handling, rhythm, authenticity |

**Phase 3: Technical Craft (25 points)**

| Category | Points | Evaluates |
|---|---|---|
| Pacing & Scene Construction | 15 | Scene length variation, tension management, act breaks, momentum |
| Visual Storytelling | 10 | Show-don't-tell, action line quality, cinematic potential, sensory detail |

**Phase 4: Market Viability (5 points)**

| Category | Points | Evaluates |
|---|---|---|
| Commercial Potential | 5 | Genre fit, target audience clarity, marketability, comparable titles |

**Score Interpretation:**

| Range | Rating | Implication |
|---|---|---|
| 90-100 | Exceptional | Production-ready |
| 75-89 | Strong | Minor development needed |
| 60-74 | Promising | Moderate revision recommended |
| 45-59 | Needs Work | Substantial revision required |
| Below 45 | Major Revision | Comprehensive restructuring needed |

Each criterion within a phase is presented as a checklist item. The analyst checks applicable items, and the system calculates phase and total scores in real time. Checklist state is serialized as JSON and persisted alongside numeric scores, enabling reviewers to revisit and adjust individual criteria.

### 5.3 API Design

The application exposes seven RESTful endpoints with server-side validation via express-validator:

| Method | Endpoint | Purpose | Validation |
|---|---|---|---|
| `GET` | `/api/scripts` | List all scripts with latest scores | — |
| `GET` | `/api/scripts/:id` | Get script with full analysis data | id: positive integer |
| `POST` | `/api/scripts` | Create new script record | title: required, non-empty |
| `PUT` | `/api/scripts/:id` | Update script metadata | title: required, non-empty |
| `DELETE` | `/api/scripts/:id` | Delete script (cascades to analyses) | id: positive integer |
| `POST` | `/api/scripts/:id/analysis` | Save or update analysis (upsert) | Score ranges enforced per phase |
| `GET` | `/api/stats` | Dashboard statistics (aggregates) | — |

All endpoints return JSON. The `/api/stats` endpoint aggregates:
- Total script count
- Average score across all analyses
- Score distribution by rating tier
- Recently analyzed scripts

### 5.4 Integration Roadmap

Script Analysis is designed for standalone deployment today. The planned integration path into SpinJockey Network involves:

1. **API Bridge.** Expose Script Analysis scores via its existing REST API, consumed by SpinJockey Network as an internal service call.
2. **Project Association.** Map Script Analysis `scripts` records to SpinJockey Network `projects` via a shared identifier or API-mediated link.
3. **Unified Dashboard.** Surface analysis scores on SpinJockey Network project pages, providing a single view of a screenplay's authoring state and evaluation status.
4. **Authentication Delegation.** Integrate Script Analysis into SpinJockey Network's session management, eliminating the need for separate access control.

The integration is designed to be additive — Script Analysis will continue to function independently for users who do not require the full platform.

---

## 6. Cross-Cutting Concerns

### 6.1 Solid Stack — Eliminating Redis

A defining architectural decision across the platform is the use of Rails 8's Solid Stack to replace Redis for all three of its traditional roles:

| Concern | Traditional Approach | SpinJockey Approach | Backing Store |
|---|---|---|---|
| Background jobs | Sidekiq + Redis | Solid Queue | PostgreSQL |
| Caching | Redis / Memcached | Solid Cache | PostgreSQL |
| WebSocket pub/sub | Redis (Action Cable adapter) | Solid Cable | PostgreSQL |

**Why this matters for self-hosted deployments:**
- One fewer service to install, configure, monitor, and secure
- No Redis memory management (maxmemory policies, eviction strategies)
- PostgreSQL's ACID guarantees apply to job processing — no lost jobs on crash
- Solid Queue uses PostgreSQL advisory locks for job claiming — no polling contention
- Backup and restore covers all application state in a single PostgreSQL dump

**Trade-offs acknowledged:**
- PostgreSQL-backed pub/sub has higher latency than Redis for high-frequency WebSocket messages
- Solid Cache performance is lower than Redis for hot-path cache reads
- These trade-offs are acceptable for the platform's current scale (small to mid-size production teams, not high-traffic consumer applications)

### 6.2 CI/CD Pipeline

All three components use Gitea Actions for continuous integration, with self-hosted runners:

**SpinJockey Network CI:**
```yaml
trigger: push to main/develop, PR to main
jobs:
  - test: Rails minitest suite
  - security: Brakeman scan
  - lint: RuboCop
deploy:
  trigger: version tag push
  target: optiserv (Debian, systemd restart)
```

**Screenplay Editor CI:**
```yaml
trigger: push to main/develop, PR to main
jobs:
  - test: RSpec suite (186 tests)
  - build: gem build
  - publish: push to Gitea Package Registry
```

**Script Analysis CI:**
```yaml
trigger: push to main/develop, PR to main
jobs:
  - test: Jest suite (39 tests)
  - build: syntax and structure verification
  - lint: code quality checks
deploy:
  trigger: push to main or version tag
  artifact: .tar.gz package (7-day retention)
```

The Screenplay Editor's publish step is significant — when a new version tag is pushed, the gem is automatically built and published to the Gitea Package Registry, making it immediately available for consumption by SpinJockey Network via `bundle update screenplay_editor`.

### 6.3 Testing Strategy

Each component uses the testing framework idiomatic to its stack:

| Component | Framework | Test Count | Coverage Areas |
|---|---|---|---|
| SpinJockey Network | Rails Minitest + RSpec | ~50+ | Models, controllers, policies, integration |
| Screenplay Editor | RSpec 6.0 | 186 | Models, controllers, policies, services, jobs |
| Script Analysis | Jest 30.2 | 39 | Unit (validators, migrations), integration (API endpoints) |

**Screenplay Editor test infrastructure:**
- FactoryBot for test data generation
- Shoulda Matchers for model validation specs
- Pundit Matchers for authorization policy specs
- Test database: SQLite (faster test runs, PostgreSQL in production)

**Script Analysis test infrastructure:**
- Supertest for HTTP endpoint testing
- In-memory SQLite databases for test isolation
- Custom setup utilities for database seeding

### 6.4 Security Posture

Security measures are applied at every layer across the suite:

**Authentication Security:**
- BCrypt password hashing (SpinJockey Network)
- Account lockout: 5 failed attempts, 30-minute duration
- Session timeout: 2 hours
- Session fixation protection
- Password expiration: 90-day policy
- Password complexity enforcement

**Input Validation:**
- Sanitize gem with RELAXED configuration (SpinJockey Network)
- express-validator chains on all endpoints (Script Analysis)
- Pundit authorization on all controller actions (SpinJockey Network, Screenplay Editor)

**Rate Limiting:**
- Rack::Attack on authentication endpoints (SpinJockey Network)
- Suspicious request blocking (PHP/ASP/dotfile probes)

**Transport Security:**
- SSL enforced in production
- Content Security Policy on all responses
- Host authorization headers

**Audit:**
- SecurityAuditLog for administrative actions
- User quarantine/block with reason tracking
- Content access logging for analytics and compliance

---

## 7. Deployment & Operations

### 7.1 Self-Hosted Model

The production deployment runs on a Debian server (optiserv) managed via systemd:

**Service Configuration:**
```
[Unit]
Description=SpinJockey Network
After=postgresql.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/opt/spinjockey-network
ExecStart=/usr/bin/bundle exec puma -C config/puma.rb
Restart=always
Environment=RAILS_ENV=production
EnvironmentFile=/opt/spinjockey-network/.env

[Install]
WantedBy=multi-user.target
```

**Infrastructure Requirements:**
- Debian 11+ (or compatible Linux distribution)
- PostgreSQL 15+
- Ruby 3.2.2+
- Node.js 20+ (for Screenplay Editor's Playwright renderer)
- Systemd for process management
- 2GB+ RAM recommended (Puma workers + Playwright Chromium)

**Deployment Process:**
1. Push version tag to Gitea
2. Gitea Actions CI runs test suite
3. On success, deploy job SSH's to optiserv
4. Pull latest code, `bundle install`, run migrations
5. Restart systemd service
6. Total deployment time: ~2-3 minutes

### 7.2 Cloud Model

The Render.com configuration (`render.yml`) defines a multi-service deployment:

| Service | Type | Role |
|---|---|---|
| Web | Web Service | Rails application (Puma + Thruster for HTTP caching/compression) |
| Worker | Background Worker | Solid Queue job processing |
| Node Renderer | Private Service | Playwright PDF rendering |
| Database | Managed PostgreSQL | All four logical databases |

Environment variables are managed through Render's dashboard, with sensitive values (master key, API keys, database credentials) stored as secrets.

### 7.3 Database Migration Strategy

Migrations are version-controlled and run as part of the deployment process:

- **SpinJockey Network:** 23 Rails migrations covering core schema evolution
- **Screenplay Editor:** 3 engine migrations (auto-prefixed to avoid collision with host)
- **Script Analysis:** 2 migration files managed by a custom migration runner (`lib/migrate.js`)

The Screenplay Editor's migrations are installed into the host application via:
```bash
rails screenplay_editor:install:migrations
rails db:migrate
```

This ensures the engine's schema changes are tracked in the host application's migration history.

### 7.4 Monitoring

**Production Monitoring:**
- Sentry.io integration for exception tracking and performance monitoring
- Automatic error capture with environment context
- Performance transaction tracing for slow request identification

**Application-Level Monitoring:**
- Admin dashboard displays system statistics (user counts, content metrics, project status distribution)
- SecurityAuditLog provides a chronological record of sensitive operations
- Content access tracking enables engagement analytics

---

## 8. Roadmap

### 8.1 Script Analysis Platform Integration

**Priority: High | Timeline: Near-term**

Integrate Script Analysis into SpinJockey Network as an embedded evaluation tool, allowing analysis scores to appear alongside project content. This involves REST API bridging, shared authentication, and unified dashboard presentation.

### 8.2 Live Collaboration

**Priority: Medium | Timeline: Mid-term**

Implement real-time collaborative screenplay editing via Yjs integration with ProseMirror. The infrastructure is in place (Solid Cable, presence tracking, session management); the remaining work is Yjs document synchronization and conflict resolution.

### 8.3 Fountain/FDX Format Support

**Priority: Medium | Timeline: Mid-term**

Extend the import/export pipeline to support Fountain (plain-text screenwriting format) and FDX (Final Draft XML). Both parsers will be added to the `@studio/screenplay-parse` package, maintaining the framework-agnostic design.

### 8.4 Advanced Analytics

**Priority: Low | Timeline: Long-term**

Expand content engagement analytics with:
- Time-on-page tracking for content items
- Revision frequency analysis for screenplays
- Score trend visualization for script analysis over time
- Export analytics reports for stakeholder distribution

---

## 9. Conclusion

SpinJockey Network demonstrates that domain-specific platforms can be built with modern, minimal infrastructure while delivering professional-grade capabilities. The architecture prioritizes self-hosting viability (single database dependency, no Redis), modularity (mountable engine pattern, standalone companion tools), and security (defense-in-depth across network, application, and audit layers).

The platform's component boundaries are deliberate: the Screenplay Editor can be extracted and mounted in any Rails 7.1+ application; the Script Analysis tool can evaluate screenplays independently of the platform; the TypeScript packages can be consumed by any JavaScript runtime. These boundaries reduce coupling, enable independent testing and deployment, and provide flexibility for future architectural evolution.

For independent filmmakers and creative studios, the platform consolidates project management, content distribution, screenplay authoring, and script evaluation into a single, self-hostable system — replacing the fragmented tooling that currently characterizes independent film production workflows.

---

**Document Version:** 1.0
**Last Updated:** February 2026
**Repository:** https://github.com/Spinjockey-Network/spinjockey-network-website
**Production URL:** https://spinjockey.net
