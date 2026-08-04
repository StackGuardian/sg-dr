# Changelog

Notable changes to `sg-dr`, written for the people who run it.

<!--
  This file is the single source of the release notes. On release, rename the
  Unreleased heading to the version and date being tagged, then push the tag:
  the workflow extracts that section and refuses to publish if it is missing.

  It also ships inside every archive, so a binary kept cold for years carries
  its own history without needing this repository.

  Nothing may follow the last version's section — no link definitions, no
  footer. A section runs until the next "## [" heading, so anything trailing
  the file would be published as part of the oldest release's notes.
-->

## [Unreleased]

## [1.0.0] - 2026-08-04

First released version. It replaces the shell proof of concept, which is kept
on the `legacy` branch and is no longer maintained.

### Recovering

- Rebuild a workflow's working environment from the artifacts your private
  runner wrote to your own object storage, without contacting StackGuardian.
- Recover a whole stack in the order its dependencies require, rather than the
  order the workflows happen to be listed in.
- Recover a specific run, including one that failed, with
  `--run-id` and `--accept-state-mismatch`.
- `sg-dr verify` reports what could be recovered without recovering anything,
  so the tool can be exercised before an incident.
- Run the recovered workflow against your live infrastructure with `--init`
  and `--plan`. Nothing is applied and no state is changed without them.

### What it reconstructs

- Input variables and environment variables, which snapshots do not carry.
- A backend pointing at your existing state, when StackGuardian managed it.
  None is written if the state cannot be found, since a backend pointing at
  nothing plans to create your infrastructure from scratch.
- References to other workflows' outputs, resolved from stored outputs.
  Values only StackGuardian holds are collected into `sg-secrets.yaml` for you
  to fill in and supply back with `--secrets`.

### Storage

- Amazon S3 and Azure Blob Storage, read-only, using your own credentials.
- `--prefix` for deployments whose runner writes under a path inside the
  bucket or container.

### Running the tool

- Obtains the exact OpenTofu or Terraform version a run used, verifying the
  download against the publisher's checksums. Terraform is fetched only up to
  1.5.7, the last release under the MPL.
- Binaries are cached in `~/.cache/sg`, shared with other StackGuardian tools.
- `sg-dr help files` lists every file, directory and network destination the
  tool touches, so an unfamiliar binary can be reviewed before it is pointed at
  your infrastructure.
- `sg-dr cleanup` removes what a recovery wrote.
