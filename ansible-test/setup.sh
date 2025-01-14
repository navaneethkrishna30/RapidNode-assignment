#!/bin/bash

# Exit on error
set -e

# Ensure variables are passed as arguments, or use defaults
GO_VERSION=${GO_VERSION:-"1.23.0"}  # Default Go version if not provided
CELESTIA_NODENAME=${CELESTIA_NODENAME:-"node"}  # Default Celestia Node Name if not provided
CELESTIA_WALLET=${CELESTIA_WALLET:-"wallet"}  # Default Celestia Wallet Name if not provided
CELESTIA_CHAIN="mocha-4"

# Update and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget aria2 clang pkg-config libssl-dev jq build-essential git make ncdu -y

# Install Go
echo "Installing Go $GO_VERSION..."
cd $HOME
wget "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version

# Install Celestia-appd binary
echo "Installing Celestia-appd binary..."
echo "y" | bash -c "$(curl -sL https://docs.celestia.org/celestia-app.sh)"
celestia-appd version

# Set up Celestia variables
echo "Setting up Celestia variables..."
export CELESTIA_NODENAME
export CELESTIA_CHAIN

# Initialize and configure Celestia P2P networks
echo "Initializing and configuring P2P networks..."
celestia-appd init "$CELESTIA_NODENAME" --chain-id "$CELESTIA_CHAIN"
celestia-appd download-genesis "$CELESTIA_CHAIN"
SEEDS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/mocha-4/seeds.txt | tr '\n' ',')
echo "Seeds: $SEEDS"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.celestia-app/config/config.toml

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

# Check sync status
echo "Checking sync status..."
curl -s localhost:26657/status | jq .result | jq .sync_info

echo "Setup complete!"
