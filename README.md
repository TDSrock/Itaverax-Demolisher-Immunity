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

- Factorio 2.0+, Space Age
- **Abacayba: Infested Death Twin of Nauvis** (hard dependency -- this mod
  does nothing without it)

## Installation

Download the latest release zip from the
[Releases page](../../releases) and place it in your Factorio `mods`
directory, then enable it in the mod list. Alternatively, once published,
install it directly through the in-game mod portal.

---

## Development / release process

Branches:

- `dev` -- active development
- `staging` -- testing
- `master` -- production; pushing here triggers the release pipeline

### CI (`dev`, `staging`, PRs into any branch)

Validates `info.json` and does a dry-run package build. Does not publish
anything. The built zip is attached as a workflow artifact for inspection.

### Release (`master`) -- automatic

On every push to `master`:

1. Bumps the version in `info.json` (`Major.Minor.Release`). Defaults to
   bumping `Release`; include `[minor]` or `[major]` in the triggering
   commit message to bump one of those instead (resets the numbers to the
   right of it to 0).
2. Commits the version bump back to `master` and tags it `vX.Y.Z`.
3. Packages the mod into `itaverax-demolisher-immunity_X.Y.Z.zip` with the
   correct mod-portal folder structure.
4. Creates a GitHub Release with that zip attached.

This does **not** touch the live mod portal listing -- it only prepares a
GitHub Release you can inspect first.

### Publish to Mod Portal -- manual button

A separate workflow, **"Publish to Mod Portal"**, only ever runs when you
trigger it yourself: go to the repo's **Actions** tab, select it in the
left sidebar, and click **Run workflow**. You can optionally type a
specific tag (e.g. `v0.1.4`) to publish; leave it blank to publish
whatever the latest GitHub Release is.

That workflow downloads the chosen release's zip and publishes it to the
Factorio Mod Portal via the official
[Mod Upload API](https://wiki.factorio.com/Mod_upload_API). Nothing ever
reaches the live mod portal without this manual step.
