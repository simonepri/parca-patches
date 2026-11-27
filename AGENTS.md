# Meta

## Context

- **Governs patch development for the Parca server and parcagpu**: this document defines the patch engineering standards, release conventions, and verification workflow for the `parca-patches` repository.
- **Pinned upstream versions**: Parca `v0.30.0`, set by `PARCA_UPSTREAM` in `mise.toml`, and parcagpu `main` at commit `ba7a419`, set by `PARCAGPU_UPSTREAM` as a full commit SHA.

# Security & Confidentiality

## Principles

- **Withhold private corporate identity and colleague handles**: never mention internal organization names, private repositories, internal hostnames, cluster names, internal cloud accounts, or colleague GitHub handles anywhere in public repository code, patches, comments, git commit messages, or documentation.
- **Enforce upstream open-source attribution standards**: attribute upstream issues and pull requests using public `parca-dev` identifiers only, and keep the original author of every upstream pull request in its patch header.

# Patch Engineering

## Principles

- **Carry only patches that have an upstream pull request**: every patch is the diff of an open pull request against `parca-dev/parca` or `parca-dev/parcagpu`, exported with `git format-patch` and otherwise unchanged; open the upstream pull request first, then add the patch.
- **Delete a patch once upstream ships it**: when Renovate bumps `PARCA_UPSTREAM` to a release, or `PARCAGPU_UPSTREAM` to a `main` commit, that contains a patch, delete that patch in the same change.
- **Structure patches as atomic, independent units**: each patch fixes one problem and applies cleanly on the pinned upstream, alone and in sequence.
- **Order bug fixes strictly before features**: patches are numbered so that `000X-fix-...` precede `000X-feat-...`.

## Decisions

- **Name patches after the fix**: `<number>-<type>-<what it changes>-to-<what it stops or enables>.patch`, in lowercase words.
- **Keep the images drop-in replacements for upstream**: the Parca image keeps upstream's layout (`/parca`, `/parca.yaml`, `/data`, user `nobody`), and the parcagpu image is built from the `runtime` stage of upstream's own Dockerfile, so deployments switch between the upstream and patched images by changing only the image reference.

# Testing & Verification

## Decisions

- **Verify clean patch application before testing**: verify that patches apply from scratch with `rm -rf third_party && mise run patch`.
- **Run the unit tests before pushing**: pass `mise run test` before committing.
- **Write commit messages in problem-then-solution format**: commit subjects follow unscoped conventional commits (`type: summary`); bodies describe the problem in one paragraph and the solution in a second.
