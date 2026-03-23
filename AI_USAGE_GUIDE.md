# AI Assistant Usage Guide for `botd`

This guide helps AI collaborators work effectively inside the Book of the Dead (Phoenix) codebase.

## Coding Conventions & Style

- **Formatting**: run `mix format` (configured via `.formatter.exs`, includes HEEx formatting plugin).
- **Static analysis**: prefer `mix credo --strict` before finalizing substantial changes.
- **Naming**: follow context-driven boundaries (expose public API functions on the context modules under `lib/botd/<context>.ex`).
- **Pattern usage**: leverage `with` pipelines (common in controllers) and avoid deeply nested `case` statements.

## Web Markup Expectations

- **Tailwind-first styling**: Build UI with Tailwind utility classes using the shared config in `assets/tailwind.config.js`. Avoid custom CSS unless absolutely necessary; if you must add it, prefer co-locating it in `assets/css/app.css` and document the rationale.
- **Phoenix components**: Reuse abstractions in `BotdWeb.CoreComponents` and other modules under `lib/botd_web/components/` rather than hand-writing markup in controllers or LiveViews.
- **Heroicons**: Use the bundled heroicons via `<.icon name="hero-..." />` from `BotdWeb.CoreComponents`; pick icons from https://heroicons.com/ and align with the existing outline/solid naming convention.
- **Responsiveness & accessibility**: Follow the patterns already present in core components (e.g., flex/grid utilities, focus/ARIA attributes) to keep new markup consistent and accessible.

## Testing & QA Expectations

- Run `mix test` (CI sets up database via alias in `mix.exs`). For iterative work, `mix test.watch` is available (requires `mix_test_watch`).
- Feature changes should include coverage in the relevant `test/botd/...` or `test/botd_web/...` directories.
- For browser-level tweaks, add/adjust LiveView or controller tests rather than relying on manual verification.
- Pair doc updates with code changes when you touch API or UI behaviors.

## Check code style

Before reporting results or submitting changes, ensure you have:

- Run the test suite: `mix test` (or targeted tests for your changes).
- Run Credo: `mix credo --strict` and fix reported issues.
- Run formatter: `mix format`.

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
