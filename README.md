# Setting Up Stader Validator on GCP with External Consensus and Execution Clients

## Prerequisites
Before you begin, make sure you have the following prerequisites in place:

- Terraform
- Ansible
- An SSH key set up in GCP

## Getting Started
To get started with the setup, follow these steps:

- Review the `variables.tf` file.
- Run `terraform init`.
- Run `terraform apply`.
- Optionally add deired firewall rules


## Next Steps
To complete the validator setup, you'll need to manually perform steps 6-9 from [StaderLabs Ethereum Node Operator Guide](https://staderlabs.gitbook.io/ethereum/node-operator/permissionless-node-operator), including wallet initialization, wallet top-up, node registration, and the deposit of SD collateral and ETH bond. 

## Notes
Here are some important notes to keep in mind:

- To execute any `stader-cli` commands, switch to the `stader` user using: `sudo su - stader`.
- Use `stader-cli` directly for commands, rather than `~/bin/stader-cli`. This is important because an alias has been created to ensure the correct configuration.
- The commands `stader-cli service status` and `stader-cli node sync` are quite useful.

For more information, please refer to the official documentation: [StaderLabs Ethereum Node Operator Guide](https://staderlabs.gitbook.io/ethereum/node-operator/permissionless-node-operator).
