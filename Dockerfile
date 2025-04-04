FROM alpine:latest as config-processor

# Create entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Write processed config files with variable substitutions' >> /entrypoint.sh && \
    echo 'sed "s|\${CLICKHOUSE_DSN}|$CLICKHOUSE_DSN|g; s|\${env:LOW_CARDINAL_EXCEPTION_GROUPING}|$LOW_CARDINAL_EXCEPTION_GROUPING|g" /etc/otel-collector-config.yaml > /tmp/otel-collector-config.yaml' >> /entrypoint.sh && \
    echo 'sed "s|\${SIGNOZ_OPAMP_ENDPOINT}|$SIGNOZ_OPAMP_ENDPOINT|g" /etc/manager-config.yaml > /tmp/manager-config.yaml' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Execute with processed configs' >> /entrypoint.sh && \
    echo 'exec /otelcol-contrib --config=/tmp/otel-collector-config.yaml --manager-config=/tmp/manager-config.yaml --copy-path=/var/tmp/collector-config.yaml --feature-gates=-pkg.translator.prometheus.NormalizeName' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Final stage
FROM signoz/signoz-otel-collector:v0.111.37

# Copy the original config files
COPY otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY otel-collector-opamp-config.yaml /etc/manager-config.yaml

# Copy the entrypoint script from the helper stage
COPY --from=config-processor /entrypoint.sh /entrypoint.sh

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]