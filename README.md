# Production Multi-Arch Buildah vs Buildx

[![Production Multi-Arch Buildah vs Buildx](https://github.com/shivam2003-dev/github-multi-arc/actions/workflows/build-multiarch.yml/badge.svg)](https://github.com/shivam2003-dev/github-multi-arc/actions/workflows/build-multiarch.yml)

A GitHub Actions workflow for a production multi-architecture container
pipeline. Buildah builds the five-stage image for `linux/amd64` and
`linux/arm64` on normal pushes. Docker Buildx is available as an on-demand
benchmark, where both builders publish separate tags and report timings side by
side.

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
3. Unit and race tests.
4. Stripped static binary compilation.
5. Hardened non-root runtime assembly.

## Benchmark method

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

## Trigger behavior

| Event | Jobs that run |
| --- | --- |
| Push to `main` or version tag | Buildah only |
| Pull request | Buildah only, without Docker Hub publication |
| **Run workflow** (`workflow_dispatch`) | Buildah, Buildx, and timing comparison |

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
