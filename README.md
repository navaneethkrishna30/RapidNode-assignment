# Celestia Validator Node Setup and Monitoring

This README provides comprehensive instructions to set up a Celestia validator node, including creating a wallet and setting up Grafana and Prometheus for monitoring. To correctly deploy this, ensure ports 9090 and 3000 are open on your EC2 instance.

## Prerequisites

- An EC2 instance running Ubuntu 22.04LTS.
- SSH access to the instance.
- Patience to let the consensus node sync.

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

### 2. Creating a Celestia Wallet

1. Use the `wallet.sh` script to create a new wallet for your Celestia node:
   ```bash
   chmod +x wallet.sh
   ./wallet.sh
   ```
2. The script generates a new wallet, securely storing the credentials in `celestia_wallet_credentials.json`. Ensure this file is backed up in a secure location.

### 3. Installing Prometheus and Grafana for Monitoring

1. Execute the `prometheus-grafana.sh` script to set up Prometheus and Grafana:
   ```bash
   chmod +x prometheus-grafana.sh
   ./prometheus-grafana.sh
   ```
2. This will install Prometheus and Grafana services, along with configuring Prometheus to monitor Celestia metrics and system metrics.

3. Ensure that the following ports are exposed on your EC2 instance:
   - Port 9090 for Prometheus.
   - Port 3000 for Grafana.

### 4. Access and Configure Grafana

1. Access Grafana through a browser using `http://<your-ec2-instance-ip>:3000`.
2. The default login credentials are:
   - Username: `admin`
   - Password: `admin`
3. Upon first login, update your password for security.
4. Add Prometheus as a data source in Grafana, using `http://localhost:9090` as the Prometheus URL.
5. Import dashboard to view metrics.

### Notes

- Ensure you have proper backups for your wallet credentials.
- Regularly check the node's sync status through the Celestia node logs or using:
  ```bash
  curl -s localhost:26657/status | jq .result | jq .sync_info
  ```

### Sources

- **Environment Setup**: [Celestia Environment Setup Guide](https://docs.celestia.org/how-to-guides/environment)
- **Installing Celestia-app Binary**: [Celestia-app Installation Guide](https://docs.celestia.org/how-to-guides/celestia-app)
- **Wallet Creation and Funding**: [Wallet Setup and Funding Guide](https://docs.celestia.org/how-to-guides/celestia-app-wallet)
- **Monitoring Setup**: [Celestia Monitoring with Prometheus and Grafana](https://github.com/Cumulo-pro/Celestia-monitoring)
- **Grafana Setup for Celestia**: [Grafana Setup Guide](https://github.com/Winnode/NODE_Manuals/blob/main/celestia/monitoring/README.md)
- **Grafana Dashboard**: [Node Exporter Full Dashboard on Grafana](https://grafana.com/grafana/dashboards/1860-node-exporter-full/)