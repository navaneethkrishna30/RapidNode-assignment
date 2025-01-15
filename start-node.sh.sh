#!/bin/bash

# Exit on error
set -e

# Enable BBR
echo "Enabling BBR..."
sudo sh -c 'printf "\nnet.core.default_qdisc=fq\nnet.ipv4.tcp_congestion_control=bbr\n" >> /etc/sysctl.conf'
if ! sudo sysctl -p; then
    echo "Warning: sysctl -p failed. Applying settings manually."
    sudo sysctl -w net.core.default_qdisc=fq
    sudo sysctl -w net.ipv4.tcp_congestion_control=bbr
fi

# Create systemd service for Celestia-appd
echo "Setting up systemd service for Celestia-appd..."
sudo tee /etc/systemd/system/celestia-appd.service > /dev/null <<EOF
[Unit]
Description=celestia-appd Cosmos daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which celestia-appd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Enable Prometheus metrics
echo "Enabling Prometheus metrics..."
sed -i 's/^prometheus *=.*/prometheus = true/' $HOME/.celestia-app/config/config.toml
sed -i 's/^namespace *=.*/namespace = "celestia"/' $HOME/.celestia-app/config/config.toml

# Start Celestia-appd service
echo "Starting Celestia-appd service..."
sudo systemctl enable celestia-appd
sudo systemctl start celestia-appd

# Display Celestia-appd status
echo "Displaying Celestia-appd status..."
sleep 3
sudo systemctl status celestia-appd