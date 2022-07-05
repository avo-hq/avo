# Release schedule

A new Avo version is released every two weeks. It does not follow semver for now but a series release.

The current series is series 2 (version `2.1`, `2.2`, `2.9`, etc). Every two weeks we'll increment the minor version number (from `2.7`` to `2.8`).

## Patch releases

In-between that release cycle we might release patches (`2.7.1` or `2.9.5`) or pre-releases (`2.7.1.pre.1` or `2.5.2.pre.7`).

## Pre-releases

The pre-releases are usually built on my machine and will be builds from a specific branch, so they don't follow any particular convention. The `pre.2` might contain a fix, but the `pre.3` might not containt tht fix because they might be built from different branches. I usually mention on a PR or issue to the bug reporter if they should or shouldn't use pre-releases. They won't get installed in regular `bundle update avo` commands, unless you instruct it in the `Gemfile`.
