FROM signoz/signoz-otel-collector:v0.111.37

# Copy configuration files
COPY otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY otel-collector-opamp-config.yaml /etc/manager-config.yaml

# Copy the already-executable entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Set the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]