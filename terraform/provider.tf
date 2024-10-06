terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}
provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url = "https://192.168.100.192:8006/api2/json"
}
