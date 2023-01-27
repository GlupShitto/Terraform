terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = ">= 2.2"
    }
  }
}

# Credentials
provider "vsphere" {
    user                 = "administrator@vsphere.local"
    password             = "Passw0rt!"
    vsphere_server       = "192.168.179.85"
    allow_unverified_ssl = true
}

# main.tf

# Data source for vCenter Datacenter
data "vsphere_datacenter" "datacenter" {
    name = "Datacenter"
}

# Data source for vCenter Datastore
data "vsphere_datastore" "datastore" {
    name          = "Kubernetes"
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "cluster-01"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
    name          = "VM Network"
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = "Oracle_8_Template01"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm01" {
  name             = "master01"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 2
  memory           = 2048
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "master"
        domain    = "node"
      }
      network_interface {
        ipv4_address = ""
        ipv4_netmask = 24
        dns_server_list = ["1.1.1.1", "8.8.8.8"]
        
      }
      ipv4_gateway = "192.168.179.1"
      
    }
  }
}


resource "vsphere_virtual_machine" "vm02" {
  name             = "worker01"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 2
  memory           = 2048
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "worker"
        domain    = "node"
      }
      network_interface {
        ipv4_address = ""
        ipv4_netmask = 24
        dns_server_list = ["1.1.1.1", "8.8.8.8"]
        
      }
      ipv4_gateway = "192.168.179.1"
      
    }
  }
}
