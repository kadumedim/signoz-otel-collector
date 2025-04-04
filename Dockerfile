FROM signoz/signoz-otel-collector:v0.111.37

# Install gettext package for envsubst
USER root
RUN apt-get update && apt-get install -y gettext-base && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the template config files
COPY otel-collector-config.yaml /etc/otel-collector-config.template.yaml
COPY otel-collector-opamp-config.yaml /etc/manager-config.template.yaml

# Create a startup script
COPY <<EOF /entrypoint.sh
#!/bin/sh
set -e

# Substitute environment variables in configuration files
envsubst < /etc/otel-collector-config.template.yaml > /etc/otel-collector-config.yaml
envsubst < /etc/manager-config.template.yaml > /etc/manager-config.yaml

# Print environment variables and configs for debugging
echo "Using SIGNOZ_OPAMP_ENDPOINT: \$SIGNOZ_OPAMP_ENDPOINT"

# Use the default container ENTRYPOINT with our arguments
exec /docker-otelcol --config=/etc/otel-collector-config.yaml --manager-config=/etc/manager-config.yaml --copy-path=/var/tmp/collector-config.yaml --feature-gates=-pkg.translator.prometheus.NormalizeName
EOF

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]