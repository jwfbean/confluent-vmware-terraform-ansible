provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}


data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_host" "hosts" {
  count         = length(var.vsphere_hosts)
  name          = var.vsphere_hosts[count.index]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "compute_cluster" {
  name            = var.vsphere_compute_cluster
  datacenter_id   = data.vsphere_datacenter.dc.id
}

resource "vsphere_resource_pool" "resource_pool" {
  name                    = var.vsphere_resource_pool
  parent_resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}

data "vsphere_network" "public" {
  name          = var.public_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "private" {
  name          = var.private_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "broker" {
  count            = var.kafka_broker_count
  name             = format("cp-kafka-%02d", count.index + 1)
  resource_pool_id = vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.kafka_broker_cpu
  memory   = var.kafka_broker_ram
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.public.id
  }

  network_interface {
    network_id = data.vsphere_network.private.id
  }

  disk {
    label = format("kafka-%02d-os-disk0", count.index + 1)
    size  = var.kafka_broker_os_dir_size_gb
    unit_number = 0
  }

  # To add more Kafka Log disks, copy this disk block 
  # and update the unit number and label number
  disk {
    label = format("kafka-%02d-log-disk1", count.index + 1)
    size  = var.kafka_broker_data_dir_size_gb
    unit_number = 1
  }

  disk {
    label = format("kafka-%02d-log-disk2", count.index + 1)
    size  = var.kafka_broker_data_dir_size_gb
    unit_number = 2
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = format("cp-kafka-%02d", count.index + 1)
        domain    = var.dns_domain
      }

      network_interface {
        ipv4_address = var.kafka_broker_external_ips[count.index]
        ipv4_netmask = var.kafka_broker_external_ipv4_netmask
      }

      network_interface {
        ipv4_address = var.kafka_broker_internal_ips[count.index]
        ipv4_netmask = var.kafka_broker_internal_ipv4_netmask
      }

      ipv4_gateway = var.public_vlan_gateway
      dns_server_list = var.dns_servers
      dns_suffix_list = var.dns_suffix_list
      
    }
  }
}

resource "vsphere_virtual_machine" "zookeeper" {
  count            = var.zookeeper_count
  name             = format("cp-zookeeper-%02d", count.index + 1)
  resource_pool_id = vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id


  num_cpus = var.zookeeper_cpu
  memory   = var.zookeeper_ram
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.public.id
  }

  network_interface {
    network_id = data.vsphere_network.private.id
  }

  disk {
    label = format("zookeeper-%02d-os-disk0", count.index + 1)
    size  = var.zookeeper_os_dir_size_gb
    unit_number = 0
  }

  disk {
    label = format("zookeeper-%02d-data-disk0", count.index + 1)
    size  = var.zookeeper_data_dir_size_gb
    unit_number = 1
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = format("cp-zookeeper-%02d", count.index + 1)
        domain    = var.dns_domain
      }
      
      network_interface {
        ipv4_address = var.zookeeper_ips[count.index]
        ipv4_netmask = var.zookeeper_ipv4_netmask
      }

      network_interface {
        ipv4_address = var.zookeeper_ips[count.index]
        ipv4_netmask = var.zookeeper_ipv4_netmask
      }

      ipv4_gateway = var.public_vlan_gateway
      dns_server_list = var.dns_servers
      dns_suffix_list = var.dns_suffix_list
    }

  }
}
# Control Center
resource "vsphere_virtual_machine" "control_center" {
  count            = 1
  name             = "cp-controlcenter-01"
  resource_pool_id = vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.control_center_cpu
  memory   = var.control_center_ram
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.public.id
  }

  disk {
    label = "os-disk0"
    size  = var.control_center_os_dir_size_gb
    unit_number = 0
  }

  disk {
    label = "data-disk0"
    size  = var.control_center_data_dir_size_gb
    unit_number = 1
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "cp-controlcenter-01"
        domain    = var.dns_domain
      }

      network_interface {
        ipv4_address = var.control_center_ip
        ipv4_netmask = var.control_center_ipv4_netmask
      }

      ipv4_gateway = var.public_vlan_gateway
      dns_server_list = var.dns_servers
      dns_suffix_list = var.dns_suffix_list 
    }
  }
}

resource "vsphere_virtual_machine" "kafka_connect" {
  count            = var.kafka_connect_count
  name             = format("cp-connect-%02d", count.index + 1)
  resource_pool_id = vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.kafka_connect_cpu
  memory   = var.kafka_connect_ram
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id = data.vsphere_network.public.id
  }

  disk {
    label = "os-disk0"
    size  = var.kafka_connect_os_dir_size_gb
    unit_number = 0
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = format("cp-connect-%02d", count.index + 1)
        domain    = var.dns_domain
      }

      network_interface {
        ipv4_address = var.kafka_connect_ips[count.index]
        ipv4_netmask = var.kafka_connect_ipv4_netmask
      }

      ipv4_gateway = var.public_vlan_gateway
      dns_server_list = var.dns_servers
      dns_suffix_list = var.dns_suffix_list 
    }
  }
}

# Anti-afinity rules for Brokers and Zookeepers
resource "vsphere_compute_cluster_vm_anti_affinity_rule" "kafka_broker_anti_affinity_rule" {
  name                = "kafka-broker-anti-affinity-rule"
  compute_cluster_id  = data.vsphere_compute_cluster.compute_cluster.id
  virtual_machine_ids = vsphere_virtual_machine.broker.*.id
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "zookeeper_anti_affinity_rule" {
  name                = "zookeeper-anti-affinity-rule"
  compute_cluster_id  = data.vsphere_compute_cluster.compute_cluster.id
  virtual_machine_ids = vsphere_virtual_machine.zookeeper.*.id
}

# Outputs

output "broker_public_ip" {
  value = vsphere_virtual_machine.broker.*.default_ip_address
}

output "zookeeper_public_ip" {
  value = vsphere_virtual_machine.zookeeper.*.default_ip_address
}

output "kafka_connect_public_ip" {
  value = vsphere_virtual_machine.kafka_connect.*.default_ip_address
}

output "control_center_public_ip" {
  value = vsphere_virtual_machine.control_center.*.default_ip_address
}
