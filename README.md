# sg-dr

Recover StackGuardian-managed infrastructure when StackGuardian is unavailable.

`sg-dr` rebuilds a workflow's working environment from the artifacts your
private runner wrote to **your own object storage**. It never contacts the
StackGuardian API, because the case it exists for is the one where that API is
down.

**Download it and check it works before you need it.** A disaster recovery tool
that has never been exercised is not a recovery tool.

> This repository holds releases only. The tool's source is maintained
> privately by StackGuardian; the binaries here are built and signed by that
> repository's release pipeline, which the signature lets you confirm.

## Download

The archives are the recommended way to get `sg-dr`: they are what you verify,
and what you keep somewhere you will still have during an outage. A package
manager is the better way to *stay current* — a recovery tool three versions
old is its own kind of risk — so both are supported.

### Homebrew, macOS and Linux

The formula lives in StackGuardian's shared tap, alongside its other
command-line tools:

```bash
brew trust --tap stackguardian/tap
brew install stackguardian/tap/sg-dr
```

Homebrew 6.0 requires explicit trust for taps outside its own, and refuses to
load an untrusted one rather than prompting — hence the first command. Trusting
the tap covers every formula in it, now and later; if `sg-dr` is the only one
you want, `brew trust --formula stackguardian/tap/sg-dr` grants strictly less,
which is Homebrew's own recommendation.

Later, `brew upgrade sg-dr` moves you to the current release. If you installed
from the tap this repository used to serve, `brew untap stackguardian/sg-dr`
removes it; it no longer carries the formula.

### Scoop, Windows

```powershell
scoop bucket add sg-dr https://github.com/StackGuardian/sg-dr
scoop install sg-dr/sg-dr
```

### Archives, every platform

Archives are named for the version they hold, so a file kept for years still
says what it is. Pick your platform from the
[latest release](https://github.com/StackGuardian/sg-dr/releases/latest), or:

```bash
VERSION=1.0.0
BASE=https://github.com/StackGuardian/sg-dr/releases/download/v$VERSION

curl -fsSLO $BASE/sg-dr_${VERSION}_linux_amd64.tar.gz
curl -fsSLO $BASE/checksums.txt
curl -fsSLO $BASE/checksums.txt.sig
curl -fsSLO $BASE/checksums.txt.pem

tar xzf sg-dr_${VERSION}_linux_amd64.tar.gz
```

Builds are published for Linux, macOS and Windows, on both amd64 and arm64.
They are static, so the machine you recover on needs nothing else installed.

## Verify it before you store it

Homebrew and Scoop pin the same checksums, so they cover integrity. Only this
path exercises the signature, which is what establishes where the binary came
from:

```bash
sha256sum --ignore-missing -c checksums.txt

cosign verify-blob checksums.txt \
  --certificate checksums.txt.pem \
  --signature checksums.txt.sig \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/StackGuardian/business-continuity/\.github/workflows/release\.yml@refs/tags/'
```

The signing is keyless, so the certificate identifies the workflow and tag that
built the release rather than a key someone has to keep. The signature is in
the public Rekor transparency log, so this check still works years later with
StackGuardian unreachable.

## Using it

```bash
sg-dr recover \
  --org acme \
  --bucket acme-runner-storage \
  --region eu-central-1 \
  --workflow my-workflow
```

That writes a runnable working directory under `./recovery/` and stops. Nothing
is applied and no state is changed.

Check what could be recovered, without recovering anything:

```bash
sg-dr verify --org acme --bucket acme-runner-storage --region eu-central-1
```

Compare a recovered workflow against your live infrastructure:

```bash
sg-dr recover ... --workflow my-workflow --init --plan
```

Recover a whole stack, in the order its dependencies require:

```bash
sg-dr recover ... --stack my-stack
```

## You supply the access

`sg-dr` signs in with **your** credentials — your AWS profile or Azure login,
your git configuration — and never reuses the credentials StackGuardian stored
alongside a workflow run.

Two reasons. A stored credential resurrected during an incident may long
outlive its intended lifetime; and a tool that reads credentials out of a
bucket turns read access to that bucket into access to everything it describes.

Only private-runner workflows can be recovered. Shared-runner workflows persist
their artifacts to StackGuardian's own storage, which you cannot read.

## What it touches

Every file, directory and network destination it uses, for anyone reviewing an
unfamiliar binary before pointing it at their infrastructure:

```bash
sg-dr help files
```

That ships in the binary rather than in a document, so you cannot end up
reading a description of a version other than the one you are running.

## Changes

See [CHANGELOG.md](CHANGELOG.md). It also ships inside every archive.

## Support

Please raise anything through your usual StackGuardian support channel.
