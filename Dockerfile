FROM signoz/signoz-otel-collector:v0.111.37

# Install envsubst
RUN apt-get update && apt-get install -y --no-install-recommends gettext-base && rm -rf /var/lib/apt/lists/*

COPY otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY otel-collector-opamp-config.yaml /etc/manager-config.yaml
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Use the entrypoint script instead of directly running the collector
ENTRYPOINT ["/entrypoint.sh"]