#!/bin/sh
set -eu

echo "Hello from a Buildah multi-architecture image!"
echo "Architecture: $(uname -m)"
echo "Word size: $(getconf LONG_BIT)-bit"
