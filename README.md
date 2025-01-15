Here’s the updated README with instructions for running `snapshot.sh` and `mocha.sh` before starting the node:
# Celestia Validator Node Setup and Monitoring

**assignment**: [automate the deployment, configuration, and monitoring of a blockchain validator node](https://docs.google.com/document/d/1QqtlhH-XjljwJPl5wCuHBn9AToBjUUENax5BhKrMad4)

## Prerequisites

- An EC2 instance running Ubuntu 22.04 LTS.
- SSH access to the instance.

## Clone Repository
   ```bash
   git clone https://github.com/navaneethkrishna30/RapidNode-assignment.git
   ```

## Setup Step-by-Step

### 1. Setting Up the Celestia Validator Node

1. Update `setup-node.sh` with the appropriate Go version, your desired Celestia node name, and wallet name.
2. Run the setup script to install and configure dependencies and the Celestia node:
   ```bash
   chmod +x setup-node.sh
   ./setup-node.sh
   ```
3. Follow the prompts for specific inputs. The script will:
   - Install and configure Go.
   - Install the Celestia application binary.
   - Initialize and configure P2P networks for Celestia.
   - Set the system for enhanced network throughput.
   - Enable Prometheus metrics for Celestia.

### 2. Applying a Snapshot

Before starting the node, apply a snapshot to speed up syncing:

1. Run the `snapshot.sh` script:
   ```bash
   chmod +x snapshot.sh
   ./snapshot.sh
   ```

2. The script will:
   - Download the latest snapshot.
   - Decompress and apply it to the Celestia data directory.
   - Restart the Celestia service.

### 3. Setting Up the Mocha Testnet

If you are connecting to the Mocha testnet, configure your node using the `mocha.sh` script:

1. Run the `mocha.sh` script:
   ```bash
   chmod +x mocha.sh
   ./mocha.sh
   ```

2. Follow the prompts to initialize and configure your node.

### 4. Creating a Celestia Wallet

1. Use the `wallet.sh` script to create a new wallet for your Celestia node:
   ```bash
   chmod +x wallet.sh
   ./wallet.sh
   ```

2. The script generates a new wallet, securely storing the credentials in `celestia_wallet_credentials.json`. Ensure this file is backed up in a secure location.

### 5. Installing Prometheus and Grafana for Monitoring

1. Execute the `prometheus-grafana.sh` script to set up Prometheus and Grafana:
   ```bash
   chmod +x prometheus-grafana.sh
   ./prometheus-grafana.sh
   ```

2. This will install Prometheus and Grafana services, along with configuring Prometheus to monitor Celestia metrics and system metrics.

3. Ensure that the following ports are exposed on your EC2 instance:
   - Port 9090 for Prometheus.
   - Port 3000 for Grafana.

### 6. Starting the Validator Node

1. Once the snapshot is applied and the testnet is configured, start the node:
   ```bash
   chmod +x start-node.sh
   ./start-node.sh
   ```

### 7. Access and Configure Grafana

1. **Access Grafana**  
   Open your web browser and navigate to your Grafana instance at `http://<your_ip>:3000`.

2. **Import the Dashboard**  
   - Click on the **"+"** icon on the left sidebar.
   - Select **"Import"** from the dropdown menu.

3. **Upload the Dashboard**
   - In the "Import via panel JSON" section, enter the Dashboard UID: `22036`.
   - Click "Load" and confirm the dashboard settings.

4. **Configure the Dashboard**
   - Once the JSON is uploaded, Grafana will display the dashboard title and other details.
   - Choose the **Prometheus** data source from the dropdown menu if prompted.
   - Click **"Import"** to complete the process.

### Notes

- back up your wallet credentials securely.
- check the node's sync status through the Celestia node logs or using:
  ```bash
  curl -s localhost:26657/status | jq .result | jq .sync_info
  ```

### sources

- **environment setup**: [Celestia Environment Setup Guide](https://docs.celestia.org/how-to-guides/environment)
- **celestia-app Binary**: [Celestia-app Installation Guide](https://docs.celestia.org/how-to-guides/celestia-app)
- **snapshots**: [Snapshot Application Process](https://bwarelabs.com/snapshots/celestia)
- **wallet creation and funding**: [Wallet Setup and Funding Guide](https://docs.celestia.org/how-to-guides/celestia-app-wallet)
- **monitoring setup**: [Celestia Monitoring with Prometheus and Grafana](https://github.com/Cumulo-pro/Celestia-monitoring)
- **grafana setup for celestia**: [Grafana Setup Guide](https://github.com/Winnode/NODE_Manuals/blob/main/celestia/monitoring/README.md)