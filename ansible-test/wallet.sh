#!/bin/bash

# Exit on error
set -e

# Load environment variables
source $HOME/.bash_profile

# Set wallet name
WALLET_NAME="${WALLET_NAME:-wallet}"  # Default wallet name if not provided
echo "Creating a new wallet named: $WALLET_NAME"

# Add wallet name to the environment
echo "export CELESTIA_WALLET=$WALLET_NAME" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Create a new wallet and capture details
echo "Generating wallet and securely storing credentials..."
WALLET_DETAILS=$(celestia-appd keys add $CELESTIA_WALLET --keyring-backend os --output json)
SEED_PHRASE=$(echo "$WALLET_DETAILS" | jq -r '.mnemonic')
CELESTIA_ADDRESS=$(echo "$WALLET_DETAILS" | jq -r '.address')
PUBLIC_KEY=$(echo "$WALLET_DETAILS" | jq -r '.pubkey')
CELESTIA_VALOPER=$(celestia-appd keys show $CELESTIA_WALLET --bech val -a --keyring-backend os)

# Securely store all wallet credentials
CREDENTIALS_FILE="$HOME/celestia_wallet_credentials.json"
echo "{
  \"wallet_name\": \"$CELESTIA_WALLET\",
  \"seed_phrase\": \"$SEED_PHRASE\",
  \"celestia_address\": \"$CELESTIA_ADDRESS\",
  \"valoper_address\": \"$CELESTIA_VALOPER\",
  \"public_key\": $PUBLIC_KEY
}" > $CREDENTIALS_FILE

# Set appropriate permissions on the credentials file
chmod 600 $CREDENTIALS_FILE
echo "Credentials securely stored in $CREDENTIALS_FILE. Ensure this file is backed up and access is restricted."

echo "Wallet creation and setup complete. Ensure the credentials are securely backed up!"
