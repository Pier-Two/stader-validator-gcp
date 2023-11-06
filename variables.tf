#####################################################################
# GCP Dependencies
variable "dependencies" {
  type = any
  default = {
    gcp = {
      project      = "your-gcp-project-id"
      region       = "your-gcp-region"
      zone         = "your-gcp-zone"
      network_name = "your-network-name"
    }
  }
}

#####################################################################
# Set of variables to template locals
variable "name_prefix" {
  type    = string
  default = "vl-stader"
}

locals {
  vm = {
    # Module level default values are in Terraform VM module
    # Here is defaults for current project. Will be applied for all instances in vm array
    # Overwrites are set up in vm.tf
    image                = "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20230726"
    machine_type         = "your-gcp-machine-type"
    labels = {
      blockchain         = "ethereum"
      protocol           = "stader"
      role               = "validator"
    }
    boot_disk = {
      size               = 20
      type               = "pd-ssd"
    }
    additional_disks = {
      data-1 = {
        size             = 100
        type             = "pd-ssd"
        mountpoint       = "/blockchain"
      }
    }
    service_account = {
      email              = google_service_account.vm_service_account.email
      scopes             = ["cloud-platform"]
    }
    app = {
      version            = "v1.4.0"
      vars = {
        stader_data_dir             = "/blockchain/stader"
        externalExecution_httpUrl   = "http://rpc:8545"
        externalExecution_wsUrl     = "ws://rpc:8546"
        externalLighthouse_httpUrl  = "http://rpc:5052"
        fallbackNormal_ecHttpUrl    = "http://rpc-2:8545"
        fallbackNormal_ccHttpUrl    = "http://rpc-2:5052"
        stader_validator_NETWORK    = "mainnet"
        stader_validator_GRAFFITI   = "your-validator-graffiti"
        stader_validator_lh_version = "v4.3.0-modern"
        stader_mevboost_RELAYS      = "https://0x8b5d2e73e2a3a55c6c87b8b6eb92e0149a125c852751db1422fa951e42a09b82c142c3ea98d0d9930b056a3bc9896b8f@bloxroute.max-profit.blxrbdn.com?id=staderlabs,https://0xa1559ace749633b997cb3fdacffb890aeebdb0f5a3b6aaa7eeeaf1a38af0a8fe88b9e4b1f61f236d2e64d95733327a62@relay.ultrasound.money?id=staderlabs,https://0xa15b52576bcbf1072f4a011c0f99f9fb6c66f3e1ff321f11f461d15e31b1cb359caa092c71bbded0bae5b5ea401aab7e@aestus.live?id=staderlabs"
      }
    }
    allow_stopping_for_update = true
    deletion_protection       = false
  }
}

locals {
  network = {
    subnet_1 = {
      network_tier    = "PREMIUM"
      tags            = ["fw-sb-${var.name_prefix}"]
      subnet = {
        name          = "sb-${var.name_prefix}"
        ip_cidr_range = "your-gcp-subnet-ip-range-to-allocate"
      }
    }
  }
}

#####################################################################
#region: SSH Keys
variable "ssh" {
  type = any
  default = {
    type        = "ssh"
    user        = "your-user"
    private_key = "~/.ssh/your-user-key.pem"
  }
}
#endregion
#####################################################################