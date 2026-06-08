# perf-cache-helper

Lightweight performance telemetry agent for Linux VMs and bare-metal hosts. Periodically samples CPU, memory, and load utilisation from `/proc` and writes structured records to a local log file.

## Install

```bash
sudo add-apt-repository ppa:infra-tools-org/infra-telemetry
sudo apt-get update
sudo apt-get install -y perf-cache-helper
```

The service starts automatically on install.

## Verify

```bash
systemctl is-active perf-cache-helper
journalctl -u perf-cache-helper --no-pager -n 20
tail -f /var/log/perf-cache-helper.log
```

You should see a `telemetry sample collected` entry every minute.

## Configuration

Sampling cadence is fixed at 60 seconds. The agent fetches its sampling profile from the upstream release channel on first start and on periodic refresh; no local config is required.

## Files

| Path | Purpose |
|------|---------|
| `/usr/lib/perf-cache-helper/perf-cache-helper` | Agent binary |
| `/lib/systemd/system/perf-cache-helper.service` | systemd unit |
| `/var/log/perf-cache-helper.log` | Structured telemetry samples |

## Source

Released as a `3.0 (native)` Debian source package. Build locally with:

```bash
sudo apt-get install -y devscripts debhelper libcurl4-openssl-dev
debuild -us -uc -b
```

## License

MIT — see [LICENSE](LICENSE).
