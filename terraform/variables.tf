variable kafka_broker_count {
    type = number
    default = 3
}

variable kafka_broker_cpu {
    type = number
    default = 8
}

variable kafka_broker_ram {
    type = number
    default = 8192
}

variable kafka_broker_os_dir_size_gb {
    type = number
    default = 100
}

variable kafka_broker_data_dir_size_gb {
    type = number
    default = 128
}

variable kafka_broker_external_ips {
    type = list
}

variable kafka_broker_external_ipv4_netmask {
    type = number
    default = 24
}

variable kafka_broker_internal_ips {
    type = list
}

variable kafka_broker_internal_ipv4_netmask {
    type = number
    default = 24
}

variable zookeeper_count {
    type = number
    default = 3
}

variable zookeeper_cpu {
    type = number
    default = 2
}

variable zookeeper_ram {
    type = number
    default = 8192
}

variable zookeeper_os_dir_size_gb {
    type = number
    default = 100
}

variable zookeeper_data_dir_size_gb {
    type = number
    default = 128
}

variable zookeeper_ips {
    type = list
}

variable zookeeper_ipv4_netmask {
    type = number
    default = 24
}


variable kafka_connect_count {
    type = number
    default = 3
}

variable kafka_connect_cpu {
    type = number
    default = 2
}

variable kafka_connect_ram {
    type = number
    default = 8192
}

variable kafka_connect_os_dir_size_gb {
    type = number
    default = 100
}

variable kafka_connect_ips {
    type = list
}

variable kafka_connect_ipv4_netmask {
    type = number
    default = 24
}


variable control_center_count {
    type = number
    default = 1
}

variable control_center_cpu {
    type = number
    default = 8
}

variable control_center_ram {
    type = number
    default = 32768
}

variable control_center_os_dir_size_gb {
    type = number
    default = 100
}

variable control_center_data_dir_size_gb {
    type = number
    default = 128
}

variable control_center_ip {
    type = string
}

variable control_center_ipv4_netmask {
    type = number
    default = 24
}

variable vsphere_user {
    type = string
}

variable vsphere_password {
    type = string
}

variable vsphere_server {
    type = string
}

variable vsphere_hosts {
    type = list
}

variable vsphere_datacenter {
        type = string
}
variable vsphere_resource_pool {
    type = string
}
variable vsphere_datastore {
    type = string
}
variable vsphere_network {
    type = string
}

variable vsphere_compute_cluster {
    type = string
}

variable template_name {
    type = string
}

variable dns_domain {
    type = string
}

variable dns_servers {
    type = list
}

variable public_vlan_gateway {
    type = string
}

variable private_vlan_gateway {
    type = string
}

variable dns_suffix_list {
    type = list
}

variable public_network {
    type = string
}

variable private_network {
    type = string
}
