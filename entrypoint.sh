#!/bin/sh
set -e

# Create temporary file for the main config
cat /etc/otel-collector-config.yaml | \
  sed "s|\${CLICKHOUSE_DSN}|$CLICKHOUSE_DSN|g" | \
  sed "s|\${env:LOW_CARDINAL_EXCEPTION_GROUPING}|$LOW_CARDINAL_EXCEPTION_GROUPING|g" \
  > /etc/otel-collector-config-processed.yaml

# Create temporary file for the opamp config
cat /etc/manager-config.yaml | \
  sed "s|\${SIGNOZ_OPAMP_ENDPOINT}|$SIGNOZ_OPAMP_ENDPOINT|g" \
  > /etc/manager-config-processed.yaml

# Execute the original command with the processed config files
exec /otelcol-contrib \
  --config=/etc/otel-collector-config-processed.yaml \
  --manager-config=/etc/manager-config-processed.yaml \
  --copy-path=/var/tmp/collector-config.yaml \
  --feature-gates=-pkg.translator.prometheus.NormalizeName