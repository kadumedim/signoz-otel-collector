FROM signoz/signoz-otel-collector:v0.111.37

# Install gettext package for envsubst and other debugging tools
USER root
RUN apt-get update && apt-get install -y gettext-base curl iputils-ping dnsutils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the template config files
COPY otel-collector-config.yaml /etc/otel-collector-config.template.yaml
COPY otel-collector-opamp-config.yaml /etc/manager-config.template.yaml

# Create an enhanced startup script with debugging
COPY <<EOF /entrypoint.sh
#!/bin/sh
set -e

# Print environment variables for debugging (redacting sensitive information)
echo "Environment variables:"
env | grep -v PASSWORD | grep -v KEY | grep -v SECRET | grep -v TOKEN

# Check if we can resolve the domain
echo "Checking DNS resolution for signoz.railway.internal:"
getent hosts signoz.railway.internal || echo "DNS resolution failed"

# Substitute environment variables in configuration files
echo "Substituting environment variables in config files..."
envsubst < /etc/otel-collector-config.template.yaml > /etc/otel-collector-config.yaml
envsubst < /etc/manager-config.template.yaml > /etc/manager-config.yaml

# Print the processed configuration files for debugging
echo "Processed otel-collector-config.yaml:"
cat /etc/otel-collector-config.yaml
echo "Processed manager-config.yaml:"
cat /etc/manager-config.yaml

# Try to check if the endpoint is reachable
echo "Checking if the SIGNOZ_OPAMP_ENDPOINT is reachable:"
ENDPOINT=\$(echo \$SIGNOZ_OPAMP_ENDPOINT | sed 's|^wss://|https://|')
curl -k -I \$ENDPOINT || echo "Endpoint not reachable or not responding to HTTP requests"

echo "Starting collector..."
# Execute the original command
exec /otelcol-contrib --config=/etc/otel-collector-config.yaml --manager-config=/etc/manager-config.yaml --copy-path=/var/tmp/collector-config.yaml --feature-gates=-pkg.translator.prometheus.NormalizeName
EOF

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]