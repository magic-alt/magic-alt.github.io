# Repository Guidelines

## Project Structure & Module Organization

```
magic-alt.github.io/
├── _config.yml          # Site configuration (title, theme, plugins, author, defaults)
├── _data/
│   └── navigation.yml   # Top navigation menu
├── _pages/              # Static pages (about, tags, categories, search, 404, archive)
├── _posts/              # Blog posts, named YYYY-MM-DD-title.md
├── assets/
│   ├── css/main.scss    # Main stylesheet with custom overrides
│   └── images/          # Site images (avatar, etc.)
├── index.html           # Homepage (layout: home)
├── Gemfile              # Ruby dependencies for local Jekyll builds
└── _site/               # Generated output (not committed)
```

## Build, Test, and Development Commands

Run these from the repository root:

- `bundle install`: install Ruby dependencies.
- `bundle exec jekyll serve`: run a local dev server with live reload.
- `bundle exec jekyll build`: generate the static site into `_site/`.
- `bundle exec jekyll clean`: clear generated files and caches.

This repo is designed for GitHub Pages with the `github-pages` gem and
Minimal Mistakes remote theme (v4.27.3).

## Content Guidelines

### Blog Posts

- Place in `_posts/` with filename `YYYY-MM-DD-title.md`.
- Required front matter: `layout`, `title`, `date`, `categories`, `tags`, `excerpt`.
- Categories should be one of: `随笔`, `技术笔记`, `项目实战`, `论文笔记`.
- Tags should be descriptive and reusable (e.g., `LangChain`, `PyTorch`, `AI`).
- Posts automatically get TOC, author profile, read time, share buttons, and related posts via defaults in `_config.yml`.

### Pages

- Place in `_pages/` with a `permalink` in front matter.
- Update `_data/navigation.yml` if adding new top-level pages.

## Coding Style & Naming Conventions

- Use Markdown for content; keep headings and lists consistent.
- Files should be UTF-8, with LF line endings.
- Custom CSS goes in `assets/css/main.scss` after the `@import "minimal-mistakes"` line.
- Image assets go in `assets/images/`.

## Testing Guidelines

No automated tests are configured. Validate changes by running
`bundle exec jekyll build` and checking for errors. Use `bundle exec jekyll serve`
to preview locally.

## Commit & Pull Request Guidelines

- Use clear, imperative commit messages (e.g., "Add LangChain usage summary post").
- After adding new functionality, run local validation and then push to Git.
- PRs should include a short summary of changes.
- If you change layouts or navigation, describe the rendered result.

## Security & Configuration Tips

- Do not commit `_site/`, `.sass-cache`, `.jekyll-cache`, or `vendor/`.
- API keys and secrets must never appear in posts or config files.
- Keep `url`/`baseurl` in `_config.yml` matching GitHub Pages settings.
