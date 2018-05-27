# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "karih/ol7"

  vdiskmanager = '/usr/bin/vmware-vdiskmanager'
  currentdir = File.dirname(File.expand_path(__FILE__))
  vdisk_dir = "#{currentdir}/disks"

  unless File.directory?(vdisk_dir)
    Dir.mkdir vdisk_dir
  end

  # Spin up two controllers
  (1..2).each do |i|
    config.vm.define "controller-#{i}" do |controller|
        controller.vm.hostname = "controller-#{i}"

        controller.vm.network :private_network, ip: "192.168.39.2#{i}"
        controller.vm.network :private_network, ip: "192.168.40.2#{i}"

        file_to_disk = "#{vdisk_dir}/controller-#{i}.vmdk"
        unless File.exists?(file_to_disk)
            `#{vdiskmanager} -c -s 40GB -a lsilogic -t 1 #{file_to_disk}`
        end

        controller.vm.provider :vmware_desktop do |v, override|
           v.name = "controller-#{i}"
           v.gui = true
           v.vmx["memsize"] = 4096
           v.vmx["numvcpus"] = 2
           v.vmx["scsi0:1.filename"] = file_to_disk
           v.vmx["scsi0:1.present"] = 'TRUE'
           v.vmx["scsi0:1.redo"] = ''
        end

        if i == 1
           controller.vm.provision :shell, inline: <<-SHELL
              yum -y install openstack-kollacli openstack-kolla-utils
           SHELL
        end
    end
  end

  # Spin up two compute nodes
  (1..2).each do |i|
    config.vm.define "compute-#{i}" do |compute|
        compute.vm.hostname = "compute-#{i}"

        compute.vm.network :private_network, ip: "192.168.39.3#{i}"
        compute.vm.network :private_network, ip: "192.168.40.3#{i}"

        file_to_disk = "#{vdisk_dir}/compute-#{i}.vmdk"
        unless File.exists?(file_to_disk)
            `#{vdiskmanager} -c -s 40GB -a lsilogic -t 1 #{file_to_disk}`
        end

        compute.vm.provider :vmware_desktop do |v, override|
           v.name = "compute-#{i}"
           v.gui = true
           v.vmx["memsize"] = 8192
           v.vmx["numvcpus"] = 2
           v.vmx["scsi0:1.filename"] = file_to_disk
           v.vmx["scsi0:1.present"] = 'TRUE'
           v.vmx["scsi0:1.redo"] = ''
        end

        # libvirtd is not installed
        #compute.vm.provision :shell, inline: <<-SHELL
        #    systemctl stop libvirtd.service
        #    systemctl disable libvirtd.service
        #SHELL

    end
  end

  # Spin up one network node
  config.vm.define :network do |net|
    net.vm.hostname = "network"

    net.vm.network :private_network, ip: "192.168.39.41"
    net.vm.network :private_network, ip: "192.168.40.41"

    file_to_disk = "#{vdisk_dir}/network.vmdk"
    unless File.exists?(file_to_disk)
        `#{vdiskmanager} -c -s 40GB -a lsilogic -t 1 #{file_to_disk}`
    end

    net.vm.provider :vmware_desktop do |v, override|
       v.name = "network"
       v.gui = true
       v.vmx["memsize"] = 4096
       v.vmx["numvcpus"] = 1
       v.vmx["scsi0:1.filename"] = file_to_disk
       v.vmx["scsi0:1.present"] = 'TRUE'
       v.vmx["scsi0:1.redo"] = ''
    end

  end

  config.vm.provision :shell, path: "scripts/provision.sh"

end
