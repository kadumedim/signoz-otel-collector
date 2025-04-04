#!/bin/sh
set -e

# Process config files with environment variable substitution
sed "s|\${CLICKHOUSE_DSN}|$CLICKHOUSE_DSN|g; s|\${env:LOW_CARDINAL_EXCEPTION_GROUPING}|$LOW_CARDINAL_EXCEPTION_GROUPING|g" /etc/otel-collector-config.yaml > /tmp/otel-collector-config.yaml
sed "s|\${SIGNOZ_OPAMP_ENDPOINT}|$SIGNOZ_OPAMP_ENDPOINT|g" /etc/manager-config.yaml > /tmp/manager-config.yaml

# Execute the original command with the processed config files
# We use exec "$0" "$@" to maintain the executable name and arguments from the base image
exec "$0" "$@" --config=/tmp/otel-collector-config.yaml --manager-config=/tmp/manager-config.yaml --copy-path=/var/tmp/collector-config.yaml --feature-gates=-pkg.translator.prometheus.NormalizeName