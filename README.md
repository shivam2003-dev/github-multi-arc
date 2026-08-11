# Buildah Multi-Arch Image and Manual Benchmark

[![Buildah Multi-Arch Image](https://github.com/shivam2003-dev/github-multi-arc/actions/workflows/buildah.yml/badge.svg)](https://github.com/shivam2003-dev/github-multi-arc/actions/workflows/buildah.yml)

Normal CI uses a simple Buildah workflow to build the five-stage image for
`linux/amd64` and `linux/arm64`. The original Buildah-versus-Buildx timing
benchmark is retained separately and runs only when manually dispatched.

## Production-style workload

The image contains a Go HTTP service with:

- Chi routing and recovery, timeout, request-ID, and real-IP middleware.
- Prometheus Go and process metrics at `/metrics`.
- Health and readiness endpoints at `/healthz` and `/readyz`.
- Runtime architecture metadata at `/api/info`.
- A static web interface.
- Unit tests in the cross-architecture build stage.
- A non-root final image, health check, CA certificates, and timezone data.

The `Containerfile` uses five stages and multiple independently cacheable
layers:

1. Toolchain and Alpine build packages.
2. Go module download and verification.
3. Unit tests.
4. Stripped static binary compilation.
5. Hardened non-root runtime assembly.

## Workflows

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| [`buildah.yml`](.github/workflows/buildah.yml) | Push, tag, pull request | Simple Buildah build; pushes on non-PR events |
| [`build-multiarch.yml`](.github/workflows/build-multiarch.yml) | **Run workflow** only | Parallel Buildah/Buildx benchmark and timing comparison |

## Manual benchmark method

When manually dispatched, the two benchmark jobs start in parallel on separate
`ubuntu-24.04` runners. Each job:

1. Performs a cold two-platform build with no external cache.
2. Changes only `benchmark-version.txt`, preserving dependency and test layers.
3. Performs a warm incremental two-platform rebuild.
4. Publishes the warm image and smoke-tests its API.

The final Actions job reports these metrics:

| Metric | Meaning |
| --- | --- |
| Cold build | First build on a fresh job runner |
| Warm rebuild | Rebuild after a small source-only change |
| Publish | Registry publication; Buildx includes its cached export pass |
| Code-change delivery | Warm rebuild plus publish |
| Total job steps | Setup, both builds, publication, and validation |

Use several workflow runs before making a production decision. GitHub runner
allocation, network conditions, registry latency, and base-image cache state can
vary between runs.

Start the benchmark from the Actions page by selecting **Production Multi-Arch
Benchmark (Manual)** and clicking **Run workflow**, or use:

```bash
gh workflow run build-multiarch.yml --repo shivam2003-dev/github-multi-arc --ref main
```

## Run either published image

```bash
docker run --rm -p 8080:8080 shivam718/buildah-multiarch-demo:buildah-latest
docker run --rm -p 8080:8080 shivam718/buildah-multiarch-demo:buildx-latest
```

Then open `http://localhost:8080` or inspect the runtime architecture:

```bash
curl http://localhost:8080/api/info
```

## Published tags

| Builder | Tags |
| --- | --- |
| Buildah | `buildah-latest`, `buildah-<commit-sha>` |
| Buildx | `buildx-latest`, `buildx-<commit-sha>` |

## Required repository secrets

| Secret | Purpose |
| --- | --- |
| `DOCKERHUB_USERNAME` | Docker Hub account name |
| `DOCKERHUB_TOKEN` | Docker Hub personal access token with write access |

```bash
gh secret set DOCKERHUB_USERNAME --repo shivam2003-dev/github-multi-arc
gh secret set DOCKERHUB_TOKEN --repo shivam2003-dev/github-multi-arc
```

Never commit the token to the repository.
