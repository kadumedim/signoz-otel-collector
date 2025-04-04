#!/bin/sh
set -e

# Create temporary files with env vars replaced
envsubst < /etc/otel-collector-config.yaml > /etc/otel-collector-config-processed.yaml
envsubst < /etc/manager-config.yaml > /etc/manager-config-processed.yaml

# Execute the original command with the processed config files
exec /otelcol-contrib --config=/etc/otel-collector-config-processed.yaml --manager-config=/etc/manager-config-processed.yaml --copy-path=/var/tmp/collector-config.yaml --feature-gates=-pkg.translator.prometheus.NormalizeName