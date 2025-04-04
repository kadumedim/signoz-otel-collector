FROM signoz/signoz-otel-collector:v0.111.37

# Copy configs
COPY otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY otel-collector-opamp-config.yaml /etc/manager-config.yaml

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make sure the entrypoint script is executable
RUN chmod +x /entrypoint.sh

# Use the entrypoint script instead of directly running the collector
ENTRYPOINT ["/entrypoint.sh"]