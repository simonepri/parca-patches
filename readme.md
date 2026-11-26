# Parca Patches

[![CI](https://github.com/simonepri/parca-patches/actions/workflows/ci.yaml/badge.svg)](https://github.com/simonepri/parca-patches/actions/workflows/ci.yaml)
[![Release Please](https://github.com/simonepri/parca-patches/actions/workflows/release-please.yaml/badge.svg)](https://github.com/simonepri/parca-patches/actions/workflows/release-please.yaml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](license)
<!-- renovate: datasource=github-releases depName=parca-dev/parca -->
[![Tested on Parca](https://img.shields.io/badge/tested%20on%20parca-v0.30.0-blue)](https://github.com/parca-dev/parca/releases/tag/v0.30.0)

A [Parca](https://github.com/parca-dev/parca) server image with upstream fixes applied as patches, for running Parca with its ClickHouse storage backend before those fixes ship in an upstream release.

Every patch is the diff of an open upstream pull request, unchanged and credited to its author. A patch is deleted as soon as an upstream release contains it, and the repository is archived once no patches remain.

## Patch Catalog

| Patch | Upstream | Fixes |
| --- | --- | --- |
| [`0001`](patches/parca/0001-fix-append-clickhouse-column-number-for-each-line-to-stop-flamegraph-crashes.patch) | [parca-dev/parca#6420](https://github.com/parca-dev/parca/pull/6420) | Flamegraph queries crash on the ClickHouse backend with `arrow/array: index out of range` ([#6409](https://github.com/parca-dev/parca/issues/6409)) |

## Image

Releases publish `ghcr.io/simonepri/parca:<upstream>-p<patch version>` for `linux/amd64` and `linux/arm64`, for example `ghcr.io/simonepri/parca:v0.30.0-p0.1.0`. The image runs `/parca` as user `nobody`, with the same layout as the upstream `ghcr.io/parca-dev/parca` image, so it replaces it without other changes. Pin it by digest.

## Development

[mise](https://github.com/jdx/mise) installs the pinned tools and runs every task:

```sh
mise run patch   # clone the pinned upstream release into third_party/parca and apply the patches
mise run test    # run the unit tests of the packages the patches touch
mise run build   # build the image for the local platform (needs Docker)
```

To change a patch, delete `third_party/parca`, run `mise run patch`, edit the code, and regenerate the patch with `git format-patch` from a commit on top of the pinned release.

## Releases

[release-please](https://github.com/googleapis/release-please) opens a release pull request when commits change `patches/parca`. Merging it tags `parca-v<version>`, updates `PARCA_PATCH_VERSION` in `mise.toml`, and publishes the image.
