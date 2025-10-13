# AI Assistant Usage Guide for `botd`

This guide helps AI collaborators work effectively inside the Book of the Dead (Phoenix) codebase.

## Project Snapshot

- **Stack**: Elixir 1.14+, Phoenix 1.7, PostgreSQL, LiveView, Tailwind, Esbuild.
- **App entry**: OTP app `:botd` with main supervision tree in `lib/botd/application.ex`.
- **Contexts** (domain logic lives under `lib/botd/`):
  - `Accounts` (users, auth flows, Mailer notifications).
  - `People` (deceased characters CRUD + file uploads).
  - `ActivityLogs` (audit trail, admin dashboard).
  - `Suggestions` (member submissions & review flow).
  - `Adapters/Telegram` (bot integration & webhook processing).
- **Web layer** (`lib/botd_web/`): standard Phoenix MVC + LiveView, `Router` defines auth pipelines (`browser`, `moderator`, `admin`).
- **Tests** in `test/`, with helper modules in `test/support` (e.g. `DataCase`, `ConnCase`).

## Local Setup & Runtime Requirements

1. Install dependencies and bootstrap the database:
   - `mix setup` (runs `deps.get`, `ecto.setup`, asset installers).
2. Required environment vars:
   - `TELEGRAM_BOT_TOKEN` for bot features (see export snippet in `README.md`).
   - Production build also expects `DATABASE_URL`, `SECRET_KEY_BASE`, optional `PHX_HOST`, `PORT`, `DNS_CLUSTER_QUERY` (see `config/runtime.exs`).
3. Start the server via `mix phx.server` or `iex -S mix phx.server` after sourcing credentials.
4. Asset tooling: Tailwind + Esbuild watchers defined in `config/dev.exs`; keep them in sync with HEEx templates.

## Coding Conventions & Style

- **Formatting**: run `mix format` (configured via `.formatter.exs`, includes HEEx formatting plugin).
- **Static analysis**: prefer `mix credo --strict` before finalizing substantial changes.
- **Naming**: follow context-driven boundaries (expose public API functions on the context modules under `lib/botd/<context>.ex`).
- **Pattern usage**: leverage `with` pipelines (common in controllers) and avoid deeply nested `case` statements.
- **Auth guard plugs**: reuse `BotdWeb.Plugs.EnsureRole` and helpers in `BotdWeb.UserAuth` when touching protected routes.

## Web Markup Expectations

- **Tailwind-first styling**: Build UI with Tailwind utility classes using the shared config in `assets/tailwind.config.js`. Avoid custom CSS unless absolutely necessary; if you must add it, prefer co-locating it in `assets/css/app.css` and document the rationale.
- **Phoenix components**: Reuse abstractions in `BotdWeb.CoreComponents` and other modules under `lib/botd_web/components/` rather than hand-writing markup in controllers or LiveViews.
- **Heroicons**: Use the bundled heroicons via `<.icon name="hero-..." />` from `BotdWeb.CoreComponents`; pick icons from https://heroicons.com/ and align with the existing outline/solid naming convention.
- **Responsiveness & accessibility**: Follow the patterns already present in core components (e.g., flex/grid utilities, focus/ARIA attributes) to keep new markup consistent and accessible.

## Working with Data & DB

- Migrations live in `priv/repo/migrations`; create new ones with `mix ecto.gen.migration`.
- Seed scripts live in `priv/repo/seeds*.exs` (see `mix aliases` in `mix.exs` and the CSV import script in `priv/repo/seeds/movie_characters.exs`).
- Use `Botd.Repo` helpers inside contexts only; controllers should call context functions instead of `Repo` directly.
- Ensure tests interacting with the DB use `DataCase` (shared sandbox setup already provided).

## Feature-Specific Tips

- **People & uploads**: file uploads are stored under `priv/static/uploads`; reuse helpers in `BotdWeb.UploadController`.
- **Suggestions workflow**: `SuggestionController` and `Suggestions` context handle member submissions, moderator review, and approvals.
- **Activity logs**: Admin dashboard lives under `/admin/logs`; logs are aggregated via `ActivityLogs` context.
- **Telegram integration**: check modules under `lib/botd/adapters/telegram` and LiveView playground at `/telegram/playground` (moderator-only).

## Testing & QA Expectations

- Run `mix test` (CI sets up database via alias in `mix.exs`). For iterative work, `mix test.watch` is available (requires `mix_test_watch`).
- Feature changes should include coverage in the relevant `test/botd/...` or `test/botd_web/...` directories.
- For browser-level tweaks, add/adjust LiveView or controller tests rather than relying on manual verification.
- Pair doc updates with code changes when you touch API or UI behaviors.

## Check code style

Execute `mix credo --strict` and fix the warnings or errors.

## Workflow for AI-Driven Changes

1. **Understand the domain**: inspect context modules before modifying behavior; keep controllers thin.
2. **Plan updates**: enumerate new context functions, changesets, or LiveView assigns before editing files.
3. **Implement incrementally**: edit Elixir code with `mix format` + targeted tests; when touching assets, run `mix assets.build`.
4. **Validate**: execute the smallest relevant subset of tests or `mix test` and share the results.
5. **Document**: update `README.md`, changelog, or inline moduledocs when behavior shifts.
6. **Safety checks**: mention any required env vars, migrations, or background jobs in the final summary.

## Helpful References

- Phoenix docs: https://hexdocs.pm/phoenix
- Ecto guides: https://hexdocs.pm/ecto
- Repo README for quick commands: `README.md`

Following these conventions keeps automated contributions aligned with the maintainers' expectations and minimizes review overhead.
