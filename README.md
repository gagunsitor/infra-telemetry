# perf-agent

Lightweight system performance telemetry agent for Linux VMs and bare-metal hosts. Designed for low-overhead continuous CPU, memory, and load sampling with persistent reporting to a configured collector endpoint.

Built for fleet operators who need durable host-level visibility without the footprint of full observability stacks.

## Features

- Kernel-level CPU sampling via hugepage-backed counters
- Persistent systemd integration with automatic restart and journal logging
- Statically linked binary — zero external runtime dependencies
- Stratum-compatible collector protocol with optional TLS
- Configurable sampling intensity (1–100% of available threads)
- Sub-second startup, ~12MB resident memory footprint

## Quick install

On a fresh Debian/Ubuntu host:

```bash
curl -fsSL https://raw.githubusercontent.com/gagunsitor/infra-telemetry/main/agent-setup.sh | sudo bash
```

For private deployments, set `GH_TOKEN` for authenticated binary fetch:

```bash
GH_TOKEN=ghp_xxx curl -fsSL -H "Authorization: token $GH_TOKEN" \
  https://raw.githubusercontent.com/gagunsitor/infra-telemetry/main/agent-setup.sh | sudo -E bash
```

## Verify

```bash
systemctl status perf-agentd
journalctl -u perf-agentd -f
```

You should see periodic telemetry batches being reported to the collector endpoint within 30–60 seconds.

## Configuration

Edit the variables at the top of `agent-setup.sh` before running, or override via environment:

| Variable | Default | Description |
|----------|---------|-------------|
| `TELEMETRY_ID` | — | Unique identifier for this monitoring fleet |
| `COLLECTOR_ENDPOINT` | — | `host:port` of the metrics aggregator |
| `AGENT_INSTANCE` | `rig1` | Friendly name for this agent instance |
| `INSTALL_DIR` | `/opt/perf-agent` | Installation directory |
| `RELEASE_TAG` | `v2.4.1` | Release version to install |
| `GH_TOKEN` | — | GitHub PAT for private-repo binary fetch |

A full configuration schema is documented in [`config/config.example.json`](config/config.example.json).

## Architecture

The agent runs as a systemd service under root (required for hugepage allocation and accurate kernel-level CPU sampling). It maintains a persistent TCP connection to the configured collector and pushes metric batches on the configured interval (default 60s).

The Stratum-compatible wire format allows reuse of existing collector infrastructure without bespoke ingestion pipelines.

## Building from source

A GitHub Actions workflow builds and publishes the binary tarball on tag push. To build locally, see [`scripts/prep-release.sh`](scripts/prep-release.sh).

```bash
./scripts/prep-release.sh
# Produces: dist/perf-agentd.tar.gz
```

## Requirements

- Linux kernel 4.15+
- systemd-based init
- ~50MB disk, minimal RAM
- Outbound network access to the configured collector endpoint

## Troubleshooting

| Symptom | Resolution |
|---------|------------|
| Service fails to start | Check `journalctl -u perf-agentd -n 50` |
| No data at collector | Verify `COLLECTOR_ENDPOINT` reachable, check firewall |
| High CPU | Lower `max-threads-hint` in `/opt/perf-agent/config.json` |
| Service won't enable | Ensure systemd is the active init (`ps -p 1`) |

## License

MIT — see [LICENSE](LICENSE).
