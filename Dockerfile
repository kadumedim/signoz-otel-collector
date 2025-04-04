FROM signoz/signoz-otel-collector:v0.111.37

COPY otel-collector-config.yaml /etc/otel-collector-config.yaml
COPY minimal-opamp-config.yaml /etc/manager-config.yaml

CMD ["--config=/etc/otel-collector-config.yaml", "--manager-config=/etc/manager-config.yaml", "--copy-path=/var/tmp/collector-config.yaml", "--feature-gates=-pkg.translator.prometheus.NormalizeName"]