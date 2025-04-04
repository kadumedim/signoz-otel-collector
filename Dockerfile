FROM signoz/signoz-otel-collector:v0.111.37

COPY otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY otel-collector-opamp-config.yaml /etc/manager-config.yaml

ENV CLICKHOUSE_DSN="tcp://clickhouse:9000"
ENV LOW_CARDINAL_EXCEPTION_GROUPING="false"

CMD ["--config=/etc/otel-collector-config.yaml", "--manager-config=/etc/manager-config.yaml", "--copy-path=/var/tmp/collector-config.yaml", "--feature-gates=-pkg.translator.prometheus.NormalizeName"]