# Repository Guidelines

## Project Structure & Module Organization

- `_config.yml`: site configuration (title, theme, plugins, permalinks).
- `_posts/`: blog posts, named `YYYY-MM-DD-title.md` with YAML front matter.
- `index.md`, `about.md`, `tags.md`: top-level pages.
- `Gemfile`: Ruby dependencies for local Jekyll builds.
- `_site/`: generated output (not committed).

## Build, Test, and Development Commands

Run these from the repository root:

- `bundle install`: install Ruby dependencies.
- `bundle exec jekyll serve`: run a local dev server with live reload.
- `bundle exec jekyll build`: generate the static site into `_site/`.

This repo is designed for GitHub Pages with the `github-pages` gem.

## Coding Style & Naming Conventions

- Use Markdown for content; keep headings and lists consistent.
- Files should be UTF-8, with LF line endings.
- Posts must include front matter (`layout`, `title`, `date`, optional `tags`).
- Naming: posts in `_posts/` must follow `YYYY-MM-DD-title.md`.

## Testing Guidelines

No automated tests are configured. Validate changes by running
`bundle exec jekyll build` and `bundle exec jekyll serve` locally.

## Commit & Pull Request Guidelines

- No strict commit message convention is established; use clear, imperative
  messages (e.g., “Add tags page”).
- After adding new functionality, run local validation (self-test) and then
  push to Git.
- PRs should include a short summary of changes and local preview notes.
- If you change layouts or navigation, include a screenshot or a brief
  description of the rendered result.

## Security & Configuration Tips

- Do not commit `_site/` or generated cache folders.
- If setting `url`/`baseurl`, keep them in `_config.yml` to match GitHub Pages
  settings.
