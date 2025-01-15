#!/bin/bash

# Exit on error
set -e

# User inputs
read -p "Enter Go version (e.g., 1.23.0): " GO_VERSION
read -p "Enter Celestia Node Name: " CELESTIA_NODENAME
read -p "Enter Celestia Wallet Name: " CELESTIA_WALLET
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
export CELESTIA_WALLET
export CELESTIA_CHAIN

# Initialize and configure Celestia P2P networks
echo "Initializing and configuring P2P networks..."
celestia-appd init "$CELESTIA_NODENAME" --chain-id "$CELESTIA_CHAIN"
celestia-appd download-genesis "$CELESTIA_CHAIN"
SEEDS=$(curl -sL https://raw.githubusercontent.com/celestiaorg/networks/master/mocha-4/seeds.txt | tr '\n' ',')
echo "Seeds: $SEEDS"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME/.celestia-app/config/config.toml