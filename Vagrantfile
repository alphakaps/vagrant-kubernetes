# Auth: Alphakaps
# Date: 11/17/2025

Vagrant.configure("2") do |config|
  config.vm.define "controlplane" do | cp |
    cp.vm.box = "bento/ubuntu-24.04"
    cp.vm.hostname = "controlplane"
    cp.vm.provision "docker"
    cp.vm.network "private_network", ip: "192.168.2.16"

    cp.vm.provision "ansible" do | ansible |
      ansible.playbook = "kubernetes/ansible/kubernetes-playbook.yml"
      ansible.compatibility_mode = "2.0"
      # Adding node01 and node02 ip address and hostname in variables
      ansible.extra_vars = {
        cp_ip: "192.168.2.16",
        kn01_ip: "192.168.2.17",
        kn01_hostname: "node01",
        kn02_ip: "192.168.2.18",
        kn02_hostname: "node02"
      }
    end

    cp.vm.provider "virtualbox" do |vm|
      vm.customize ["modifyvm", :id, "--name", "controlplane"]
      vm.customize ["modifyvm", :id, "--memory", "2048"]
      vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vm.customize ["modifyvm", :id, "--cpus", "2"]
    end

  end

  config.vm.define "node01" do | kn01 |
    kn01.vm.box = "bento/ubuntu-24.04"
    kn01.vm.hostname = "node01"
    kn01.vm.provision "docker"
    kn01.vm.network "private_network", ip: "192.168.2.17"
    
    kn01.vm.provision "ansible" do | ansible |
      ansible.playbook = "kubernetes/ansible/kubernetes-playbook.yml"
      ansible.compatibility_mode = "2.0"
      # Adding controlplane ip address and hostname in variables
      ansible.extra_vars = {
        kn01_ip: "192.168.2.17",
        cp_ip: "192.168.2.16",
        cp_hostname: "controlplane"
      }
    end

    kn01.vm.provider "virtualbox" do | vm |
      vm.customize ["modifyvm", :id, "--name", "node01"]
      vm.customize ["modifyvm", :id, "--memory", "2048"]
      vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vm.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end

  config.vm.define "node02" do | kn02 |
    kn02.vm.box = "bento/ubuntu-24.04"
    kn02.vm.hostname = "node02"
    kn02.vm.provision "docker"
    kn02.vm.network "private_network", ip: "192.168.2.18"

    kn02.vm.provision "ansible" do | ansible |
      ansible.playbook = "kubernetes/ansible/kubernetes-playbook.yml"
      ansible.compatibility_mode = "2.0"
      ansible.extra_vars = {
        kn02_ip: "192.168.2.18",
        cp_ip: "192.168.2.16",
        cp_hostname: "controlplane"
      }
    end

    kn02.vm.provider "virtualbox" do | vm |
      vm.customize ["modifyvm", :id, "--name", "node02"]
      vm.customize ["modifyvm", :id, "--memory", "2048"]
      vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vm.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end

end
