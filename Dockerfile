# First stage - process config with envsubst
FROM debian:slim as config-processor

# Install envsubst
RUN apt-get update && apt-get install -y --no-install-recommends gettext-base && rm -rf /var/lib/apt/lists/*

# Copy config files
COPY otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY otel-collector-opamp-config.yaml /etc/manager-config.yaml

# Create a simple wrapper script that will do the variable substitution at runtime
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'envsubst < /etc/otel-collector-config.yaml > /tmp/otel-collector-config.yaml' >> /entrypoint.sh && \
    echo 'envsubst < /etc/manager-config.yaml > /tmp/manager-config.yaml' >> /entrypoint.sh && \
    echo 'exec /otelcol --config=/tmp/otel-collector-config.yaml --manager-config=/tmp/manager-config.yaml --copy-path=/var/tmp/collector-config.yaml --feature-gates=-pkg.translator.prometheus.NormalizeName' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Second stage - the actual collector
FROM signoz/signoz-otel-collector:v0.111.37

# Copy config files and entrypoint from first stage
COPY --from=config-processor /etc/otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY --from=config-processor /etc/manager-config.yaml /etc/manager-config.yaml
COPY --from=config-processor /entrypoint.sh /entrypoint.sh
COPY --from=config-processor /usr/bin/envsubst /usr/bin/envsubst

# Set entrypoint to our wrapper script
ENTRYPOINT ["/entrypoint.sh"]