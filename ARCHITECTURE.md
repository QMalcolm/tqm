# Architecture

Personal website and portfolio built with Phoenix/Elixir (~1.8), hosted on Fly.io. Features a public blog, an about/career history page, and a private admin interface for content management.

## Stack

- **Framework:** Phoenix 1.8 with Phoenix LiveView 1.1
- **Language:** Elixir (~1.14)
- **Database:** PostgreSQL via Ecto
- **Frontend:** Tailwind CSS, Heroicons, esbuild (no JS framework)
- **Email:** Swoosh
- **Markdown:** Earmark
- **Deployment:** Docker + Fly.io

## Directory Layout

```
lib/
  tqm/                   # Business logic (contexts)
    accounts/            # Users, sessions, auth tokens
    blog/                # Blog posts
    jobs/                # Job and role history
    seeds.ex             # Hardcoded career history data
  tqm_web/               # Web layer
    controllers/         # HTTP handlers (pages, blog, sessions)
    live/                # LiveView pages (blog editor, settings, auth flows)
    live_components/     # Reusable LiveView components
    components/          # Stateless HTML components (CoreComponents)
    router.ex
    endpoint.ex
    person_auth.ex       # Auth plugs and LiveView on_mount hooks

priv/
  repo/migrations/       # 7 migration files
  static/images/         # Company logos, site images

assets/
  css/                   # Tailwind entry point
  js/                    # Phoenix LiveView JS
  tailwind.config.js

config/
  config.exs             # Base config
  dev.exs / test.exs / prod.exs / runtime.exs

test/
  tqm/                   # Context unit tests
  tqm_web/               # Controller and LiveView tests
  support/               # DataCase, ConnCase, fixtures
```

## Contexts

### `Tqm.Accounts`
Users (`Person` schema) with email/password auth. Three roles: `:owner`, `:non_stranger`, `:stranger`. Includes email confirmation, password reset, remember-me tokens, and an `approved` boolean for registration gating.

### `Tqm.Blog`
Blog posts with draft/published/scheduled states via `published_at`:
- `nil` → draft (owner only)
- `<= now` → published (public)
- `> now` → scheduled (owner only)

`Blog.viewing_permissions_for_person/1` returns `:all` or `:published` to parameterize queries.

### `Tqm.Jobs`
Job and role history used on the About page. Jobs have many roles (positions held), cast as a nested association so a job and its roles are edited through a single changeset. Editable by the owner via the job editor; `Tqm.Seeds` provides initial data.

## Data Models

| Schema | Key Fields |
|---|---|
| `Person` | email, hashed_password, confirmed_at, role, approved |
| `BlogPost` | title, content (Markdown), published_at |
| `Job` | company_name, logo, description (Markdown), url |
| `Role` | title, start_date, end_date, details (belongs_to Job) |

## Routing

Four pipeline groups in `router.ex`:

| Group | Plug/Guard | Routes |
|---|---|---|
| Public | none | `/`, `/blog`, `/blog/:id`, `/about` |
| Guest-only | redirect if logged in | `/people/register`, `/people/log_in`, password reset |
| Authenticated | require login | `/people/settings`, log out |
| Owner-only | require `:owner` role | `GET /blog/new`, `GET /blog/:id/edit`, `DELETE /blog/:id`, `GET /about/jobs/new`, `GET /about/jobs/:id/edit` |

LiveView routes use `live_session` with `on_mount` hooks (`ensure_owner`, `ensure_authenticated`, `redirect_if_authenticated`) for role enforcement.

## LiveView Pages

| Module | Route | Purpose |
|---|---|---|
| `AboutLive.Index` | `/about` | Job history display with sorting; owner edit links |
| `BlogPostLive.Form` | `/blog/new`, `/blog/:id/edit` | Blog editor (draft/publish/schedule) |
| `JobLive.Form` | `/about/jobs/new`, `/about/jobs/:id/edit` | Job editor with nested role rows; job deletion |
| `PersonSettingsLive` | `/people/settings` | Email and password changes |
| Registration/login/reset flows | various | Standard auth UI |

## Authentication

- Session tokens stored in `PersonToken` (DB-backed, expiring)
- Remember-me cookie (30 days)
- `PersonAuth` plug module handles login/logout, session loading, and role enforcement
- Passwords hashed with `bcrypt_elixir`

## Testing

- **ExUnit** with `async: true` throughout
- **`DataCase`** — context tests with Ecto SQL Sandbox
- **`ConnCase`** — controller/LiveView tests with HTTP conn setup
- Fixtures in `test/support/fixtures/` (factory-style helpers)
- Doctests where appropriate

## Deployment

- `Dockerfile` + `fly.toml` for Fly.io
- `config/runtime.exs` reads secrets from environment
- `Tqm.Release` module for migrations at release startup
- `priv/repo/seeds.exs` seeds job/role data
