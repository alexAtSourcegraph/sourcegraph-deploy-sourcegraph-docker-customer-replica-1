#!/usr/bin/env bash
set -e
source ./replicas.sh

# Description: Handles repository metadata (not Git data) lookups and updates from external code hosts and other similar services.
#
# Disk: 128GB / non-persistent SSD
# Network: 100mbps
# Liveness probe: n/a
# Ports exposed to other Sourcegraph services: 3182/TCP 6060/TCP
# Ports exposed to the public internet: none
#
VOLUME="$HOME/sourcegraph-docker/repo-updater-disk"
./ensure-volume.sh $VOLUME 100
docker run --detach \
    --name=repo-updater \
    --network=sourcegraph \
    --restart=always \
    --cpus=4 \
    --memory=4g \
    -e GOMAXPROCS=1 \
    -e SRC_FRONTEND_INTERNAL=sourcegraph-frontend-internal:3090 \
    -e 'OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317' \
    -e GITHUB_BASE_URL=http://github-proxy:3180 \
    -v $VOLUME:/mnt/cache \
    index.docker.io/sourcegraph/repo-updater:5.1.2@sha256:f11f162dc68c48b9ae82018772645a043db63b6e9e3cd3655e6fe84e5ce4cb9e

echo "Deployed repo-updater service"
