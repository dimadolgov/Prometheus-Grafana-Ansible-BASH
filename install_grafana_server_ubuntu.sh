#!/bin/bash

GRAFANA_VERSION="10.4.2"
PROMETHEUS_URL="http://PROMETHEUS_IP:9090"

# Install dependencies
apt-get update
apt-get install -y apt-transport-https software-properties-common wget adduser libfontconfig1 musl

# Resolve APT configuration issue
rm /etc/apt/sources.list.d/grafana.list*
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
apt-get update

# Install Grafana
wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_amd64.deb
dpkg -i grafana_${GRAFANA_VERSION}_amd64.deb

# Configure Grafana datasource
mkdir -p /etc/grafana/provisioning/datasources/
cat <<EOF> /etc/grafana/provisioning/datasources/prometheus.yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    url: ${PROMETHEUS_URL}
EOF

# Enable and start Grafana service
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
systemctl status grafana-server
