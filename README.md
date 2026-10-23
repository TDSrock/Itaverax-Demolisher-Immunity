# Itaverax Segmented Unit Immunity

A temporary stopgap mod that fixes vanilla demolishers (and other
`segmented-unit`/`segment` prototype enemies) self-destructing on Vulcanus
when running alongside **Abacayba: Infested Death Twin of Nauvis**.

## The problem

Abacayba applies a bonus melee damage type (`itaverax`) to _all_
`SegmentedUnitPrototype` entities in the game, not just its own new content.
Vanilla demolisher resistances were authored before the `itaverax` damage
type existed, so they have no resistance entry for it and take full,
unmitigated self-inflicted damage from their own attacks -- draining to
death on their own, even completely undisturbed.

## The fix

This mod runs in `data-final-fixes.lua` (after every other mod's data
stage) and grants 100% `itaverax` resistance to every `segmented-unit` and
`segment` prototype in the game, mirroring how broadly Abacayba itself
applies the damage type. It will not override an existing resistance entry
if one is already present.

## Status

This is a stopgap only. Abacayba's author (emerson5442) is aware of the
underlying issue and intends to ship a proper fix in a future Abacayba
update. Once that lands, this mod can be disabled or removed.

## Requirements

- Factorio 2.1+, Space Age (`info.json` targets 2.1; a 2.0 build needs
  `"factorio_version": "2.0"` and `base >= 2.0.0`)
- **Abacayba: Infested Death Twin of Nauvis** (hard dependency -- this mod
  does nothing without it)

## Installation

Download the latest release zip from the
[Releases page](../../releases) and place it in your Factorio `mods`
directory, then enable it in the mod list. Alternatively, once published,
install it directly through the in-game mod portal.

---

## Repo setup (one time)

1. Run `scripts/configure_repo.sh` once (needs the GitHub CLI, logged in
   with admin rights). It makes squash merge the only merge method, uses
   the PR title as the commit subject and the PR description as the commit
   body, and deletes merged branches.
2. Add a `FACTORIO_API_KEY` secret in the repo's
   Settings -> Secrets and variables -> Actions (create the key at
   factorio.com/profile). The key needs the "ModPortal: Upload Mods" usage
   and, so the very first release can create the mod listing, also
   "ModPortal: Publish Mods".
3. Optionally add `thumbnail.png` (144x144), `locale/en/locale.cfg` and a
   `portal-description.md` (markdown description for the portal; it is not
   packaged into the mod).
4. Every PR needs a `Changelog:` section in its description (see "PR
   Changelog" below).

---

## Development / release process

Trunk-based: there is only `master`. Work happens on short-lived branches
that are squash-merged into `master` through a PR. There is no `dev` or
`staging`; to test a change, download the zip artifact that CI attaches to
the PR and load it in Factorio. `master` is always the latest work. A
release is a tag you create deliberately with the **Release** button.

### CI (PRs into `master`, pushes to `master`)

Validates `info.json` and `changelog.txt` (against the
[official changelog format](https://lua-api.factorio.com/latest/auxiliary/changelog-format.html)),
and does a dry-run package build. Does not publish anything. The built zip is
attached as a workflow artifact for inspection.

### PR reminders (PRs into `master`) -- non-blocking

The **PR Reminders** workflow posts a single comment on every PR (and keeps
updating it on new pushes) listing optional files that are still missing,
with links to the relevant docs. Currently checked:

- `thumbnail.png` (144x144)
- `locale/en/locale.cfg`
- the optional `portal-description.md`

It never fails the build. If everything is in place and no comment exists
yet, it stays quiet. PRs from forks cannot receive comments; the same
reminder is then shown in the run's summary instead.

To change what is checked, edit `scripts/check_optional_files.sh` (the
workflow itself is `.github/workflows/pr-reminders.yml`).

### PR Changelog (PRs into `master`) -- required

Every pull request description must contain a line that reads `Changelog:`,
followed by the changes of that PR. The **PR Changelog** workflow fails when
the section is missing or invalid, keeps one comment on the PR up to date
(with a preview of the exact lines that will end up in `changelog.txt`), and
re-runs when the description is edited. A PR template pre-fills the section.
To make the check required, add it to the branch protection / ruleset of
`master`.

```
Changelog:
Features:
- A single line entry.
- A multi-line entry continues on the next line
  without a new dash.
Bugfixes:
- Fixed something that was broken.
```

- Categories are the ones the game recognises: Major Features, Features,
  Minor Features, Graphics, Sounds, Optimizations, Balancing, Combat
  Balancing, Circuit Network, Changes, Bugfixes, Modding, Scripting, Gui,
  Control, Translation, Debug, Ease of use, Info, Locale, Compatibility.
  Matching ignores case. Use as many as the change needs.
- Every entry sits under a category. Use a multi-line entry when one line
  does not explain the change.
- Write `Changelog: none` for changes players do not care about (CI, docs,
  refactoring). It is a deliberate choice, so a PR cannot forget it.
- Markdown decoration (`## Changelog:`, `**Features:**`, `*` bullets) is
  accepted, and HTML comments are ignored.

The parser writes the entries in the exact format of the game: 99 dashes, the
version, the date, categories with 2 spaces, entries with 4 spaces and `- `,
continuation lines with 6 spaces, no duplicates, no tabs or trailing
whitespace. You never format that yourself.

### Changelog (built from the pull requests)

When you run the Release workflow, `scripts/changelog.py` collects the
`Changelog:` sections of all PRs merged since the last `v*` tag (read through
the GitHub API, falling back to the commit message, which holds the PR
description for squash merges) and writes the new version section at the top
of `changelog.txt`. Identical entries from different PRs are merged. The
**date is filled in automatically**, in the style of the official example
(`DD. MM. YYYY`). The same entries become the notes of the GitHub release.

The release **fails before anything is committed or tagged** if no entries
were found or the result would not follow the format. PRs that were merged
without a `Changelog:` section are listed as warnings.

**Manual override:** add a section at the top of `changelog.txt` for the
version the release will become (you choose the bump when you click Release,
so it is only known then). If the top entry already has that version, the
generator leaves it untouched. If your top entry is a *different, newer*
version than the release (e.g. you wrote `0.1.0` but the bump produced
`0.0.5`), generation is refused so the file stays in order. Every version
needs a `Date:` line and at least one entry.

**Internal versions:** every version gets its own changelog entry, whether or
not it ever reaches the mod portal. Entries and published versions don't
have to line up 1:1. When you publish a later version, the portal simply
shows the entries of the internal versions in between as well.

`python3 scripts/changelog.py` has four commands: `check-pr`, `validate`,
`release` and `notes` (see `--help`); it needs nothing but Python 3.

### Release -- manual button

A release only ever happens when you trigger the **Release** workflow
yourself: Actions tab -> Release -> **Run workflow**, from `master`. Inputs:

- **bump**: `release` (default), `minor` or `major`. Resets the numbers to
  the right of it to 0.
- **internal**: tick this for a version you keep to yourself. The GitHub
  Release is marked as a pre-release, and "Publish to Mod Portal" skips
  pre-releases when it picks the latest release.

The workflow then:

1. Stops if there are no commits since the last tag (guards against a double
   click).
2. Bumps the version in `info.json`.
3. Generates the changelog entry from the PR changelog sections (unless a
   manual entry exists), commits `info.json` and `changelog.txt` back to
   `master` and tags it `vX.Y.Z`. It stops before this step if the changelog
   cannot be generated.
4. Packages the mod into `itaverax-demolisher-immunity_X.Y.Z.zip` with the
   correct mod-portal folder structure.
5. Creates a GitHub Release with that zip attached and the changelog entry
   as the release notes.

The workflow pushes the version-bump commit directly to `master`. If you add
branch protection that requires pull requests on `master`, that push will be
blocked unless you give it a bypass.

This does **not** touch the live mod portal listing -- it only prepares a
GitHub Release you can inspect first.

### Publish to Mod Portal -- manual button

A separate workflow, **"Publish to Mod Portal"**, only ever runs when you
trigger it yourself: go to the repo's **Actions** tab, select it in the
left sidebar, and click **Run workflow**. You can optionally type a
specific tag (e.g. `v0.1.4`) to publish; leave it blank to publish
the latest GitHub Release that is not marked as a pre-release (so internal
versions are skipped).

That workflow downloads the chosen release's zip and publishes it to the
Factorio Mod Portal. Nothing ever reaches the live mod portal without this
manual step.

It works in two steps:

1. **The easy way:** add a release to the existing mod through the
   [Mod upload API](https://wiki.factorio.com/Mod_upload_API).
2. **If the mod does not exist on the portal yet** (the portal answers
   `UnknownMod`), publish it as a **new mod** through the
   [Mod publish API](https://wiki.factorio.com/Mod_publish_API). Only that
   one specific answer triggers this, so a bad key or a version that already
   exists never creates a listing by accident. The checkbox
   `new_mod_fallback` in the Run workflow form (on by default) turns this step
   off. A workflow cannot ask a question halfway through, so that form is the
   prompt: the click on **Run workflow** is the confirmation.

For a new mod the form also takes an optional `category`, `license` and
`source_url` (default: this repository). The portal description is the
contents of `portal-description.md` in the repo root if that file exists (it
is not packaged into the mod), otherwise the `description` from `info.json`.
Title, tags, FAQ and images can be finished on the mod's portal page
afterwards.
