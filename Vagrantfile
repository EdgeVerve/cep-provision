Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.network "private_network", type: "dhcp"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.define "node1" do |node1|
    node1.vm.hostname = "node1"
    node1.vm.provider "virtualbox" do |vb|
	  vb.name = "Swarm_node1";
	  disk = './node1secondDisk.vdi'
	  vb.memory = "1024"
	  unless File.exist?(disk)
        vb.customize ['createhd', '--filename', disk, '--variant', 'Fixed', '--size', 8 * 1024]
      end
      vb.customize ['storageattach', :id,  '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk]
    end
  end
  
  config.vm.define "node2" do |node2|
    node2.vm.hostname = "node2"
    node2.vm.provider "virtualbox" do |vb|
	  disk = './node2secondDisk.vdi'
	  vb.name = "Swarm_node2";
	  vb.memory = "1024"
	  unless File.exist?(disk)
        vb.customize ['createhd', '--filename', disk, '--variant', 'Fixed', '--size', 8 * 1024]
      end
      vb.customize ['storageattach', :id,  '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk]
    end
  end
  
  config.vm.define "node3" do |node3|
    node3.vm.hostname = "node3"
    node3.vm.provider "virtualbox" do |vb|
	  disk = './node3secondDisk.vdi'
	  vb.name = "Swarm_node3";
	  vb.memory = "1024"
	  unless File.exist?(disk)
        vb.customize ['createhd', '--filename', disk, '--variant', 'Fixed', '--size', 8 * 1024]
      end
      vb.customize ['storageattach', :id,  '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk]
    end
  end
end
