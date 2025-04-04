# First stage - process config with envsubst
FROM debian:buster-slim as config-processor

# Install envsubst
RUN apt-get update && apt-get install -y --no-install-recommends gettext-base && rm -rf /var/lib/apt/lists/*

# Create entrypoint script 
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Process configs with envsubst' >> /entrypoint.sh && \
    echo 'envsubst < /etc/otel-collector-config.yaml > /tmp/otel-collector-config.yaml' >> /entrypoint.sh && \
    echo 'envsubst < /etc/manager-config.yaml > /tmp/manager-config.yaml' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Execute original command with processed configs' >> /entrypoint.sh && \
    echo 'exec /otelcol-contrib --config=/tmp/otel-collector-config.yaml --manager-config=/tmp/manager-config.yaml --copy-path=/var/tmp/collector-config.yaml --feature-gates=-pkg.translator.prometheus.NormalizeName' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Second stage - the actual collector
FROM signoz/signoz-otel-collector:v0.111.37

# Copy config files
COPY otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY otel-collector-opamp-config.yaml /etc/manager-config.yaml

# Copy envsubst and entrypoint from first stage
COPY --from=config-processor /usr/bin/envsubst /usr/bin/envsubst
COPY --from=config-processor /entrypoint.sh /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]