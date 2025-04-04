# Stage 1: Use a base image with shell utilities to perform the substitution
FROM alpine:latest as config

# Install gettext for envsubst utility
RUN apk add --no-cache gettext

# Copy the config files
COPY otel-collector-config.yaml /tmp/otel-collector-config.yaml
COPY otel-collector-opamp-config.yaml /tmp/otel-collector-opamp-config.yaml

# Perform environment variable substitution
RUN envsubst < /tmp/otel-collector-config.yaml > /tmp/otel-collector-config-processed.yaml && \
    envsubst < /tmp/otel-collector-opamp-config.yaml > /tmp/otel-collector-opamp-config-processed.yaml

# Stage 2: Final image
FROM signoz/signoz-otel-collector:v0.111.37

# Copy the processed config files from the first stage
COPY --from=config /tmp/otel-collector-config-processed.yaml /etc/otel-collector-config.yaml
COPY --from=config /tmp/otel-collector-opamp-config-processed.yaml /etc/manager-config.yaml

CMD ["--config=/etc/otel-collector-config.yaml", "--manager-config=/etc/manager-config.yaml", "--copy-path=/var/tmp/collector-config.yaml", "--feature-gates=-pkg.translator.prometheus.NormalizeName"]