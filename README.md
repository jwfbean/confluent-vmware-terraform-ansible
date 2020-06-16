# vmware-lab-work

This project encompasses a terraform and ansible environment to set up Kafka and monitoring tools. 

Based on the fantastic work done by Chris Matta (@cjmatta)

## Prerequisites
* Python 3
* Ansible 
* [Terraform](https://www.terraform.io/downloads.html)

### Prerequisit Setup

Ensure that the template has 

1. clone: `git clone ...`
2. Create Python virtual environment:
    ```
    python3 -m venv $HOME/.python3-venv
    ```

    Add venv to login shell:
    ```
    echo "source $HOME/.python3-venv/bin/activate" >> $HOME/.bashrc
    ```

    Either log out and log in, or enable .venv:
    ```
    source $HOME/.python3-venv/bin/activate
    ```

3. Install python requirements:
    ```
    pip install -r python-requirements.txt
    ```

4. Install Terraform according to the [instructions here](https://www.terraform.io/downloads.html)

## Terraform
The terraform folder contains a few files:

* `main.tf`: this is the main definition of the environment
* `variables.tf`: this is the variables definition file
* `teraform.tfvars`: this is the file where environment specific settings are made

Alter `terraform.tfvars` to include specific information about the vsphere environment, and the Confluent Platform environment you'd like to build. 

Once everything is set, run `terraform init`, then run `terraform plan` to ensure everything looks good. If everything looks right, then run `terraform apply` to apply the configuration.

After everything is built, there will be outputs of the various components IP addresses. Note this for the Ansible section.

## Ansible
Edit `hosts.yml` and set the ansible user, and private key file for access to the target machines, be to include the ip addresses for each service output by the terraform apply. 

Ensure that wherever you run ansible from can ssh to each of the hosts, it's easiest to test this with the Ansible ping module:

```
ansible -i hosts.yml -m ping all
```


### Preflight
There's a playbook called `preflight-playbook.yml` which does the follwoing:
 
 * opens up the SELinux ports to allow traffic between services
 * formats the disks and then mounts them (you'll want to make sure that the devices specified in the volumes /dev/sdb1 etc.. are correct for the VMs)

 Edit the `preflight-playbook.yml` file and make sure that the Broker and Zookeeper drives are correct (/dev/sdb, /dev/sdc etc...)
 
 Run it like this:

```
ansible-playbook -i hosts.yml preflight-playbook.yml
```

### Core services
Make sure that the Kafka brokers section has the correct properties set for the environment: `broker.rack`, `default.replication.factor`, and `log.dirs` property is set in `hosts.yml`:

```
172.20.10.11:
      kafka_broker:
        properties:
          broker.rack: isvlab
          default.replication.factor: 3
          log.dirs: /var/lib/kafka/data0,/var/lib/kafka/data1
```

To install the core Kafka, Zookeeper, Connect and Control Center services run the all.yml playbook like this:

```
ansible-playbook -i hosts.yml all.yml
```

### Tools host
The `tools-provisioning.yml` playbook installs the following services

* Installs Prometheus on the tools host specified in `hosts.yml`
* Installs [Prometheus node exporter](https://github.com/prometheus/node_exporter) on all hosts
* Installs core kafka commands needed for performance tests on tools host
* Installs Grafana on the tools host
* Installs filebeats on all hosts, which collect from:
    * /var/log/*.log
    * /var/kafka/*.log
    * /var/kafka/*.current
    * /var/zookeeper/*.log
    * /var/zookeeper/*.current
* Installs Kibana, Elasticsearch, and Logstash on the tools host

Install Ansible Galaxy roles:

```
ansible-galaxy install -r ansible-requirements.yml
```


Install tools:

```
ansible-playbook -i hosts.yml tools-provisioning.yml
```

#### Grafana Configuration
After the `tools-provisioning.yml` playbook runs a Grafana instance will be running on port 3000 of the tools host:

user/pass - confluent/confluent

**Add Prometheus Data Source**
Add a data source in Grafana under the `configuration -> data sources` menu. Set the URL to `http://<tools host>:9090` and set it to default.

**Import Kafka and Host Dashboards**
(Import JSON dashboards)[https://grafana.com/docs/grafana/latest/reference/export_import/#importing-a-dashboard] from the `grafana-dashboards` directory in this repository. 
