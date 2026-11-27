# Parca Patches

[![CI](https://github.com/simonepri/parca-patches/actions/workflows/ci.yaml/badge.svg)](https://github.com/simonepri/parca-patches/actions/workflows/ci.yaml)
[![Release Please](https://github.com/simonepri/parca-patches/actions/workflows/release-please.yaml/badge.svg)](https://github.com/simonepri/parca-patches/actions/workflows/release-please.yaml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](license)
<!-- renovate: datasource=github-releases depName=parca-dev/parca -->
[![Tested on Parca](https://img.shields.io/badge/tested%20on%20parca-v0.30.0-blue)](https://github.com/parca-dev/parca/releases/tag/v0.30.0)

[Parca](https://github.com/parca-dev/parca) server and [parcagpu](https://github.com/parca-dev/parcagpu) images with upstream fixes applied as patches, for running Parca with its ClickHouse storage backend and profiling GPUs with parcagpu before those fixes ship upstream.

Every patch is the diff of an open upstream pull request, unchanged and credited to its author. A patch is deleted as soon as upstream ships it (a Parca release, or a parcagpu `main` commit), and the repository is archived once no patches remain.

## Patch Catalog

### Parca

| Patch | Upstream | Fixes |
| --- | --- | --- |
| [`0001`](patches/parca/0001-fix-append-clickhouse-column-number-for-each-line-to-stop-flamegraph-crashes.patch) | [parca-dev/parca#6420](https://github.com/parca-dev/parca/pull/6420) | Flamegraph queries crash on the ClickHouse backend with `arrow/array: index out of range` ([#6409](https://github.com/parca-dev/parca/issues/6409)) |
| [`0002`](patches/parca/0002-fix-make-hasprofiledata-an-existence-probe-to-stop-full-table-scans.patch) | [parca-dev/parca#6402](https://github.com/parca-dev/parca/pull/6402) | `HasProfileData` scans the whole ClickHouse table instead of stopping at the first row |
| [`0003`](patches/parca/0003-fix-store-merge-profile-timestamps-in-milliseconds-to-stop-pprof-time-overflow.patch) | [parca-dev/parca#6508](https://github.com/parca-dev/parca/pull/6508) | Merged pprof downloads carry a wrong time because a nanosecond timestamp overflows |
| [`0004`](patches/parca/0004-fix-skip-the-column-when-decoding-clickhouse-lines-to-stop-dropping-interpreted-function-names.patch) | [parca-dev/parca#6510](https://github.com/parca-dev/parca/pull/6510) | The ClickHouse backend stores interpreted frames, such as Python frames, without function names, so flame graphs show them as `0x0` |
| [`0005`](patches/parca/0005-feat-add-a-flag-to-open-the-ui-without-a-default-query-to-stop-fleet-wide-first-loads.patch) | [parca-dev/parca#6509](https://github.com/parca-dev/parca/pull/6509) | Opening the UI without a query runs a default query over every series; `--ui-disable-auto-query` opens it empty instead |

### parcagpu

| Patch | Upstream | Fixes |
| --- | --- | --- |
| [`0001`](patches/parcagpu/0001-fix-keep-pc-sampling-off-when-the-driver-denies-profiling-to-stop-losing-all-gpu-activity.patch) | [parca-dev/parcagpu#61](https://github.com/parca-dev/parcagpu/pull/61) | With the driver's default `NVreg_RestrictProfilingToAdminUsers=1` and no `CAP_SYS_ADMIN`, enabling PC sampling makes CUPTI finalize itself, so the process reports no kernel activity at all; parcagpu now keeps PC sampling off there ([#59](https://github.com/parca-dev/parcagpu/issues/59)) |

## Images


Releases publish `ghcr.io/simonepri/parca:<upstream>-p<patch version>` for `linux/amd64` and `linux/arm64`, for example `ghcr.io/simonepri/parca:v0.30.0-p0.1.0`. The image runs `/parca` as user `nobody`, with the same layout as the upstream `ghcr.io/parca-dev/parca` image, so it replaces it without other changes. Pin it by digest.

Releases publish `ghcr.io/simonepri/parcagpu:<upstream commit>-p<patch version>` for `linux/amd64` and `linux/arm64`, where the upstream commit is the first 7 characters of the pinned `parca-dev/parcagpu` `main` commit, for example `ghcr.io/simonepri/parcagpu:ba7a419-p0.1.0`. It is built from the `runtime` stage of upstream's own Dockerfile, so it has the same layout as `ghcr.io/parca-dev/parcagpu`: a busybox image with `/usr/lib/libparcagpucupti.so` and the bundled CUPTI it falls back to, `/usr/lib/libcupti.so.12`, `/usr/lib/libcupti.so.13`, `/usr/lib/libnvperf_host.so.12`, and `/usr/lib/libnvperf_host.so.13`. Pin it by digest.

## Development

[mise](https://github.com/jdx/mise) installs the pinned tools and runs every task:

```sh
mise run patch   # clone the pinned upstreams into third_party/parca and third_party/parcagpu and apply the patches
mise run test    # run the unit tests the patches touch or add (the parcagpu tests need Docker)
mise run build   # build the images for the local platform (needs Docker)
```

Each task also runs for one upstream, such as `mise run build:parcagpu`. To change a patch, delete `third_party/<upstream>`, run `mise run patch`, edit the code, and regenerate the patch with `git format-patch` from a commit on top of the pinned upstream.

Renovate proposes new Parca releases and new parcagpu `main` commits by updating `PARCA_UPSTREAM` and `PARCAGPU_UPSTREAM` in `mise.toml`.

## Releases

[release-please](https://github.com/googleapis/release-please) opens a release pull request when commits change `patches/parca` or `patches/parcagpu`. Merging it tags `parca-v<version>` or `parcagpu-v<version>`, updates `PARCA_PATCH_VERSION` or `PARCAGPU_PATCH_VERSION` in `mise.toml`, and publishes that image.
