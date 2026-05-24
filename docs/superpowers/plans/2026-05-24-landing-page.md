# Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a static landing page for the Rent & Fee Calculator app and deploy it to GitHub Pages through GitHub Actions.

**Architecture:** Use a dependency-free static site under `docs/` so it is easy to maintain and deploy. GitHub Actions packages the `docs/` directory with the official Pages artifact action and deploys it using the official Pages deploy action.

**Tech Stack:** HTML, CSS, small vanilla JavaScript, GitHub Pages, GitHub Actions.

---

### Task 1: Static Landing Page

**Files:**
- Create: `docs/index.html`
- Create: `docs/styles.css`
- Create: `docs/script.js`
- Create: `docs/assets/app_logo.png`

- [ ] Create a responsive product landing page with a hero, feature sections, workflow section, release CTA, and footer.
- [ ] Reuse the existing app logo as `docs/assets/app_logo.png`.
- [ ] Point all download CTAs to `https://github.com/shikdershondhi/rent/releases/latest`.
- [ ] Verify the page opens locally from `docs/index.html`.

### Task 2: GitHub Pages Workflow

**Files:**
- Create: `.github/workflows/deploy-pages.yml`

- [ ] Add a workflow triggered by pushes to `main` and manual dispatch.
- [ ] Grant `contents: read`, `pages: write`, and `id-token: write` permissions.
- [ ] Upload `docs/` with `actions/upload-pages-artifact@v3`.
- [ ] Deploy with `actions/deploy-pages@v4`.

### Task 3: Verification

**Files:**
- Read: `docs/index.html`
- Read: `.github/workflows/deploy-pages.yml`

- [ ] Run a local static check for expected links and files.
- [ ] Use a browser screenshot to verify the landing page renders correctly.
- [ ] Confirm `git status --short` only shows intended changes plus pre-existing unrelated changes.
