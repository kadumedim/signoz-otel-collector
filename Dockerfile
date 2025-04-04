FROM signoz/signoz-otel-collector:v0.111.37

COPY otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY otel-collector-opamp-config.yaml /etc/manager-config.yaml

ARG SIGNOZ_OPAMP_ENDPOINT
ENV SIGNOZ_OPAMP_ENDPOINT=${SIGNOZ_OPAMP_ENDPOINT}

CMD ["--config=/etc/otel-collector-config.yaml", "--manager-config=/etc/manager-config.yaml", "--copy-path=/var/tmp/collector-config.yaml", "--feature-gates=-pkg.translator.prometheus.NormalizeName"]