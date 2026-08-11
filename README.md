# Multi-Arch Buildah vs Buildx

[![Multi-Arch Buildah vs Buildx](https://github.com/shivam2003-dev/github-multi-arc/actions/workflows/build-multiarch.yml/badge.svg)](https://github.com/shivam2003-dev/github-multi-arc/actions/workflows/build-multiarch.yml)

A parallel GitHub Actions benchmark that builds the same OCI image for
`linux/amd64` and `linux/arm64` using both Buildah and Docker Buildx. Each job
publishes its own tags to Docker Hub, and a final comparison job reports how
long both approaches took.

## Run either published image

Docker automatically pulls the variant matching the host architecture:

```bash
docker run --rm shivam718/buildah-multiarch-demo:buildah-latest
docker run --rm shivam718/buildah-multiarch-demo:buildx-latest
```

Example output:

```text
Hello from a multi-architecture image!
Architecture: aarch64
Word size: 64-bit
```

The architecture line will normally be `x86_64` on AMD64 and `aarch64` on
ARM64.

## Parallel benchmark

The workflow starts two independent jobs at the same time:

| Job | Builder | Published tags |
| --- | --- | --- |
| Buildah | `redhat-actions/buildah-build@v3` | `buildah-latest`, `buildah-<commit-sha>` |
| Buildx | `docker/build-push-action@v7` | `buildx-latest`, `buildx-<commit-sha>` |

Both jobs use the same `ubuntu-24.04` runner image, `Containerfile`, platforms,
and Docker Hub repository. External build caches are intentionally not enabled.
The Actions run summary reports:

- Buildah build and push durations.
- Buildx combined build-and-push duration.
- Total measured steps for each job.
- Which timed engine phase was faster and by how many seconds.

The comparison is useful for this small demo, but it is not a universal
performance result. GitHub runner allocation, registry/network conditions, and
base-image caching can vary between runs.

Pull requests build both variants without publishing. Pushes to `main`, version
tags, and manual workflow runs publish both manifests.

## Required repository secrets

| Secret | Purpose |
| --- | --- |
| `DOCKERHUB_USERNAME` | Docker Hub account name |
| `DOCKERHUB_TOKEN` | Docker Hub personal access token with write access |

Set them with GitHub CLI:

```bash
gh secret set DOCKERHUB_USERNAME --repo shivam2003-dev/github-multi-arc
gh secret set DOCKERHUB_TOKEN --repo shivam2003-dev/github-multi-arc
```

Never commit the token to the repository.
