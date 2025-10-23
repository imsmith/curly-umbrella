# curly-umbrella

curly-umbrella packages a lightweight file-indexing workflow that surfaces filesystem changes via RSS feeds. It is intentionally pragmatic—a workaround for imperfect indexing tools that nonetheless produces timely notifications of file changes.

## Container Image & Runtime

The provided Dockerfile builds a custom Caddy binary, installs supporting tools (Bash, rsync, curl, jq), and copies configuration plus helper scripts into the image. The container's entrypoint is a Bash orchestrator that runs inside `/app`.

## Orchestration Script

`scripts/run.sh` prepares directories for feeds, logs, and cache; iterates through every share defined in `config/shares.list`; and, for each share, launches `indexer.sh`, logs duration, emits OpenTelemetry metrics via `otel-cli`, and finally hands control to the bundled Caddy server for serving generated feeds.

## Indexing & Feed Generation

`scripts/indexer.sh` maintains per-share cache directories, uses `rsync` in dry-run mode to list files, compares the latest snapshot to the previous baseline to detect changes, and then invokes `generate_rss.sh` to render an RSS feed for modified items.

`scripts/generate_rss.sh` streams an RSS 2.0 feed to stdout, turning each changed file into an `<item>` with metadata such as a SHA-256 GUID, file URL, and timestamped publication date.

## HTTP Delivery

Caddy is configured to serve everything under `/app/feeds` on port 80, apply gzip compression, and disable caching so clients always receive the freshest feed content.
