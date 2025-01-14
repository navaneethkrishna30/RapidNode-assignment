#!/bin/bash

# Exit on error
set -e

echo "Starting monitoring setup..."

# Prometheus Setup
echo "Setting up Prometheus..."
sudo useradd -m -s /bin/bash prometheus || true
sudo groupadd --system prometheus || true
sudo usermod -aG prometheus prometheus || true

sudo mkdir -p /var/lib/prometheus
for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i}; done
mkdir -p /tmp/prometheus && cd /tmp/prometheus

PROM_URL=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4)
wget -q "$PROM_URL"
tar xvf prometheus*.tar.gz
cd prometheus*/
sudo mv prometheus promtool /usr/local/bin/

# Move prometheus.yml to the correct location
sudo mv prometheus.yml /etc/prometheus/prometheus.yml

prometheus --version
promtool --version

sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries \
--web.listen-address=0.0.0.0:9090 \
--web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

for i in rules rules.d files_sd; do sudo chown -R prometheus:prometheus /etc/prometheus/${i}; done
for i in rules rules.d files_sd; do sudo chmod -R 775 /etc/prometheus/${i}; done
sudo chown -R prometheus:prometheus /var/lib/prometheus/

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Node Exporter Setup
echo "Setting up Node Exporter..."
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz"
wget -q "$NODE_EXPORTER_URL"
tar xvfz node_exporter-*.*-amd64.tar.gz
cd node_exporter-*.*-amd64
sudo mv node_exporter /usr/local/bin/

sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/node_exporter
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo useradd --no-create-home --shell /bin/false prometheus || true
sudo chown prometheus:prometheus /usr/local/bin/node_exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Configure Prometheus Targets
echo "Configuring Prometheus targets..."
sudo sed -i '/^scrape_configs:/a \ \ - job_name: "celestia_metrics"\n    static_configs:\n      - targets: ["localhost:26660"]' /etc/prometheus/prometheus.yml
sudo sed -i '/^scrape_configs:/a \ \ - job_name: "instance_metrics"\n    static_configs:\n      - targets: ["localhost:9100"]' /etc/prometheus/prometheus.yml

sudo systemctl restart prometheus

# Grafana Setup
echo "Setting up Grafana..."
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana -y

sudo systemctl enable grafana-server
sudo systemctl start grafana-server

echo "Monitoring setup complete!"