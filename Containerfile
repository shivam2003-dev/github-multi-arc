FROM docker.io/library/alpine:3.22

LABEL org.opencontainers.image.title="Buildah Multi-Arch Demo" \
      org.opencontainers.image.description="A tiny image that reports its runtime architecture"

COPY hello-multiarch.sh /usr/local/bin/hello-multiarch
RUN chmod +x /usr/local/bin/hello-multiarch

ENTRYPOINT ["/usr/local/bin/hello-multiarch"]
