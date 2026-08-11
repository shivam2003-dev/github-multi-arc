ARG GO_VERSION=1.26
ARG ALPINE_VERSION=3.22

FROM docker.io/library/golang:${GO_VERSION}-alpine AS toolchain

WORKDIR /src

RUN apk add --no-cache \
      ca-certificates \
      git \
      tzdata

FROM toolchain AS dependencies

COPY go.mod go.sum ./
RUN go mod download
RUN go mod verify

FROM dependencies AS test

COPY cmd/ ./cmd/
COPY internal/ ./internal/
RUN go test -count=1 ./...

FROM test AS builder

COPY benchmark-version.txt ./benchmark-version.txt

RUN mkdir -p /out && \
    CGO_ENABLED=0 go build \
      -trimpath \
      -ldflags="-s -w -X main.version=$(cat benchmark-version.txt)" \
      -o /out/multiarch-api \
      ./cmd/server

FROM docker.io/library/alpine:${ALPINE_VERSION} AS runtime

LABEL org.opencontainers.image.title="Multi-Architecture Builder Benchmark" \
      org.opencontainers.image.description="Production-style Go service built with Buildah and Buildx" \
      org.opencontainers.image.source="https://github.com/shivam2003-dev/github-multi-arc"

RUN apk add --no-cache \
      ca-certificates \
      tzdata && \
    addgroup -S -g 10001 app && \
    adduser -S -D -H -u 10001 -G app app && \
    mkdir -p /app/web && \
    chown -R app:app /app

WORKDIR /app

COPY --from=builder --chown=app:app /out/multiarch-api /usr/local/bin/multiarch-api
COPY --chown=app:app web/ ./web/
COPY --chown=app:app benchmark-version.txt ./build-version.txt

ENV PORT=8080 \
    STATIC_DIR=/app/web

EXPOSE 8080

USER 10001:10001

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O - http://127.0.0.1:8080/healthz || exit 1

ENTRYPOINT ["/usr/local/bin/multiarch-api"]
