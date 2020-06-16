# vsphere 
vsphere_user                            = ""
vsphere_password                        = ""
vsphere_server                          = ""
vsphere_hosts                           = []
vsphere_datacenter                      = ""
vsphere_resource_pool                   = ""
vsphere_compute_cluster                 = ""
vsphere_datastore                       = ""
vsphere_network                         = ""
template_name                           = "confluent-kafka-template-new"
dns_domain                              = ""
dns_suffix_list                         = [""]
dns_servers                             = []
public_vlan_gateway                     = ""
public_network                          = ""
private_vlan_gateway                    = ""
private_network                         = ""
# Kafka Brokers
kafka_broker_count                      = 4
kafka_broker_cpu                        = 4
kafka_broker_ram                        = 65536
kafka_broker_os_dir_size_gb             = 100
kafka_broker_data_dir_size_gb           = 512
# make sure there are as many IP addresses as kafka_broker_count
kafka_broker_external_ips               = []
kafka_broker_external_ipv4_netmask      = 24
kafka_broker_internal_ips               = []
kafka_broker_internal_ipv4_netmask      = 24
# Zookeepers
zookeeper_count                         = 3
zookeeper_cpu                           = 2
zookeeper_ram                           = 16384
zookeeper_os_dir_size_gb                = 100
zookeeper_data_dir_size_gb              = 128
# make sure there are as many IP addresses as zookeeper_count
zookeeper_ips                           = []
zookeeper_ipv4_netmask                  = 24
# Kafka Connect
kafka_connect_count                     = 2
kafka_connect_cpu                       = 2
kafka_connect_ram                       = 8192
kafka_connect_os_dir_size_gb            = 100
# make sure there are as many IP addresses as kafka_connect_count
kafka_connect_ips                       = []
kafka_connect_ipv4_netmask              = 24
# Control Center
control_center_cpu                      = 8
control_center_ram                      = 65536
control_center_os_dir_size_gb           = 100
control_center_ip                       = ""
control_center_ipv4_netmask             = 24
