#!/bin/bash

# Set <COSMOS_HOME> as an environment variable
COSMOS_HOME="$HOME/.celestia-app"
export COSMOS_HOME

# Define snapshot URL and file
SNAPSHOT_URL="https://snapshots.bwarelabs.com/celestia/testnet/celestia20250114.tar.lz4"
SNAPSHOT_FILE="celestia20250114.tar.lz4"

# Download the snapshot
echo "Downloading the snapshot..."
wget -O "$SNAPSHOT_FILE" "$SNAPSHOT_URL"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download snapshot from $SNAPSHOT_URL"
    exit 1
fi

# Stop the Celestia service if running
echo "Stopping Celestia service..."
sudo systemctl stop celestia-appd

# Backup priv_validator_state.json
if [ -f "$COSMOS_HOME/data/priv_validator_state.json" ]; then
    echo "Backing up priv_validator_state.json..."
    mv "$COSMOS_HOME/data/priv_validator_state.json" "$COSMOS_HOME/"
else
    echo "No priv_validator_state.json file found to back up."
fi

# Clean the data directory
echo "Cleaning the data directory..."
rm -rf "$COSMOS_HOME/data/"
mkdir -p "$COSMOS_HOME/data/"

# Ensure lz4 is installed
if ! command -v lz4 &> /dev/null; then
    echo "Installing lz4..."
    sudo apt-get update && sudo apt-get install -y lz4
fi

# Decompress the snapshot archive
echo "Decompressing the snapshot archive..."
lz4 -c -d "$SNAPSHOT_FILE" | tar -x -C "$COSMOS_HOME"
if [ $? -ne 0 ]; then
    echo "Error: Failed to decompress the snapshot archive."
    exit 1
fi

# Restore priv_validator_state.json
if [ -f "$COSMOS_HOME/priv_validator_state.json" ]; then
    echo "Restoring priv_validator_state.json..."
    rm "$COSMOS_HOME/data/priv_validator_state.json"
    mv "$COSMOS_HOME/priv_validator_state.json" "$COSMOS_HOME/data/"
else
    echo "No priv_validator_state.json backup found to restore."
fi

# Start the Celestia service
echo "Starting the Celestia service..."
sudo systemctl start celestia-appd
if [ $? -eq 0 ]; then
    echo "Celestia service started successfully!"
else
    echo "Error: Failed to start the Celestia service."
    exit 1
fi

echo "Snapshot application process completed successfully!"
