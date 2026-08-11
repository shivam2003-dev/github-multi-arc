# Multi-Arch Build with Buildah

[![Multi-Arch Build with Buildah](https://github.com/shivam2003-dev/github-multi-arc/actions/workflows/build-multiarch.yml/badge.svg)](https://github.com/shivam2003-dev/github-multi-arc/actions/workflows/build-multiarch.yml)

A minimal demo that builds one OCI image for both `linux/amd64` and
`linux/arm64` using Buildah, then publishes the multi-architecture manifest to
Docker Hub.

## Run the published image

Docker automatically pulls the variant matching the host architecture:

```bash
docker run --rm shivam718/buildah-multiarch-demo:latest
```

Example output:

```text
Hello from a Buildah multi-architecture image!
Architecture: aarch64
Word size: 64-bit
```

The architecture line will normally be `x86_64` on AMD64 and `aarch64` on
ARM64.

## How the build works

The workflow:

1. Installs QEMU user-mode emulation on the GitHub-hosted runner.
2. Uses `redhat-actions/buildah-build@v3` to build `linux/amd64` and
   `linux/arm64` variants from the same `Containerfile`.
3. Inspects the generated manifest and runs its native variant.
4. Uses `redhat-actions/push-to-registry@v3` to push `latest` and the immutable
   Git commit SHA tag to Docker Hub.

Pull requests build and test the image without pushing it. Pushes to `main`,
version tags, and manual workflow runs publish it.

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
