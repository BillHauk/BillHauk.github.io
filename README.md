# haukeconomics.com

Source for [www.haukeconomics.com](https://www.haukeconomics.com) — the academic
site of William R. Hauk, Jr., Associate Professor of Economics at the Darla Moore
School of Business, University of South Carolina.

A Jekyll site built by GitHub Pages' native builder. There is no CI workflow and
no Node toolchain: push to `master` and GitHub rebuilds it.

## Adding content

Almost everything is data, not markup. You should rarely need to touch HTML.

| To add… | Edit | Notes |
| --- | --- | --- |
| a published article | `_data/publications.yml` | reverse chronological |
| a working paper | `_data/working_papers.yml` | newest first |
| a media item | `_data/media.yml` | two lists, auto-sorted by date |
| a profile link | `_data/profiles.yml` | also add it to `social.links` in `_config.yml` |
| a nav item | `_data/navigation.yml` | |
| a blog post | `_posts/YYYY-MM-DD-slug.md` | |

Copy an existing block, change the values, done. Both paper files use the **same
field names**, so promoting a working paper to a publication is a cut-and-paste
plus three lines (`journal`, `year`, `url`).

Two rules that will save you an afternoon:

- **Always quote titles.** Several contain a colon, which is YAML syntax.
- **Abstracts must use `|`, never `>`.** The folded `>` marker collapses blank
  lines, so a multi-paragraph abstract would render as one run-on paragraph.
  Indent every line of the block four spaces. Save files as UTF-8 **without** a
  BOM — a BOM breaks the build with an unhelpful error.

New working-paper PDFs go in `pages/working_papers/`. **Do not move or rename the
files already there**, or `/assets/CV.pdf`: Google Scholar, SSRN, and coauthors'
sites link to those exact URLs.

## Images

Drop a high-resolution portrait at `assets/_src/headshot-original.jpg` (that
folder is gitignored) and run:

```powershell
powershell -ExecutionPolicy Bypass -File tools\build-images.ps1
```

That regenerates the responsive headshot variants, the favicons, and the social
sharing card into `assets/img/`, stripping all EXIF along the way. It uses only
`System.Drawing`, which ships with Windows — no ImageMagick needed. Until a photo
exists, the home page renders a monogram placeholder of the same size.

## Previewing locally

Requires Ruby (`winget install RubyInstallerTeam.RubyWithDevKit.3.3`), then:

```powershell
bundle install
bundle exec jekyll serve --force_polling --destination "$env:LOCALAPPDATA\hauk_site"
```

Both flags matter on this machine. `--force_polling` is needed because OneDrive
interferes with filesystem change notifications, and building to a destination
outside OneDrive stops every rebuild from triggering a sync storm.

## Structure

```text
_data/        content: papers, media, profiles, navigation
_includes/    render partials; paper.html is the important one
_layouts/     default, home, page, post
_sass/        design tokens and component styles -> assets/css/style.scss
pages/        working-paper PDFs (stable URLs, do not reorganize)
tools/        image generation script
```

The design follows the [USC brand toolkit](https://sc.edu/about/offices_and_divisions/communications/toolbox/):
garnet `#73000A` as an accent against warm near-white, with Georgia and Arial,
the toolkit's designated web substitutes for the licensed Berlingske family.
Dark mode lifts garnet to `#E0798A`, since `#73000A` is invisible on a dark
ground.

## License

Prose and images © William R. Hauk, Jr., licensed
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). See `LICENSE.md`.

Earlier versions of this site were built from Marisa Carlos's *simple academic
website* tutorial, itself derived from [Karl Broman](https://kbroman.org)'s site.
No code from those templates remains, but the debt is worth recording.
