#Version 1.0.2

EXTRA_DRIVE_NAME = ENV['DABOX_EXTRA_DRIVE_NAME'] || 'drive.vdi'
CREATE_EXTRA_DRIVE = !File.exist?(EXTRA_DRIVE_NAME)
FDISK_EXTRA_DRIVE = CREATE_EXTRA_DRIVE || ENV['DABOX_FDISK_EXTRA_DRIVE'] == "1"

# Plugin dependencies
required_plugins = %w( vagrant-vbguest )
required_plugins.each do |plugin|
    system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

Vagrant.configure(2) do |config|
    config.vm.box = "hashicorp/bionic64"
    config.vm.hostname = "dabox"
    config.vm.box_check_update = false
    config.vm.network 'private_network', ip: "33.33.33.10"
    config.ssh.forward_agent = true

    ## Synced folders
    config.vm.synced_folder ".", "/vagrant"
    config.vm.synced_folder "public", "/public"

    config.vm.provider :virtualbox do |vb|
        # vb.gui = true
        # vb.customize ["modifyvm", :id, "--memory", "6144"] XXX re-enable
        vb.customize ["modifyvm", :id, "--memory", "2048"]
        # vb.customize ["modifyvm", :id, "--cpus", "4"] XXX re-enable
        vb.customize ["modifyvm", :id, "--cpus", "2"]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

        # Extra disk
        if CREATE_EXTRA_DRIVE
            vb.customize ['createhd', '--filename', EXTRA_DRIVE_NAME, '--size', 20 * 1024]
        end
        vb.customize [
          'storageattach', :id,
          '--storagectl', 'SATA Controller',
          '--port', 1,
          '--device', 0,
          '--type', 'hdd',
          '--medium', EXTRA_DRIVE_NAME,
        ]
    end

    # Create extra disk partition
    if FDISK_EXTRA_DRIVE
      config.vm.provision "shell", privileged: true, inline: <<-SHELL
        # Feed commands to fdisk:
        # n - new partition
        # p - primary partition
        # 1 - partition number
        #   - default first sector
        #   - default last sector
        # w - write changes
        fdisk -u /dev/sdb <<EOF
n
p
1


w
EOF
         mkfs.ext4 /dev/sdb1
         echo "/dev/sdb1	/data	ext4	defaults	0 0 " >> /etc/fstab
         mkdir -p /data
         mount -a
         chown -R :vagrant /data
         chmod -R g+rw /data
      SHELL
    end

    # Ssh keys
    config.vm.provision "file",
        source: "~/.ssh/config",
        destination: "~/.ssh/config",
        run: "always"
    config.vm.provision "file",
        source: "~/.ssh/id_github",
        destination: "~/.ssh/id_github",
        run: "always"
    config.vm.provision "file",
        source: "~/.ssh/id_github.pub",
        destination: "~/.ssh/id_github.pub",
        run: "always"
    config.vm.provision "file",
        source: "~/.ssh/id_gitlab",
        destination: "~/.ssh/id_gitlab",
        run: "always"
    config.vm.provision "file",
        source: "~/.ssh/id_gitlab.pub",
        destination: "~/.ssh/id_gitlab.pub",
        run: "always"

    # Timezone
    config.vm.provision "shell", privileged: false, inline: <<-SHELL
        sudo ln -s /usr/share/zoneinfo/Etc/GMT-1 /etc/localtime -f
        sudo dpkg-reconfigure --frontend noninteractive tzdata
    SHELL

    # Shell provisioning
    config.vm.provision "shell", privileged: false, inline: <<-SHELL
        sudo apt-add-repository multiverse

        sudo apt-get update

        sudo apt-get remove --purge node

        sudo apt-get install -y \
            automake \
            ack-grep \
            bash-completion \
            docker.io \
            cmake \
            exuberant-ctags \
            fortune \
            git \
            git-core \
            moreutils \
            pkg-config \
            python-setuptools \
            sbcl \
            silversearcher-ag \
            tmuxinator \
            tree \
            unzip

        sudo usermod -aG docker $(whoami)

        sudo -H easy_install \
            pip

        sudo -H pip install --upgrade \
            virtualenv

        # Java
        (
            sudo add-apt-repository -y ppa:webupd8team/java
            sudo apt-get update
            sudo apt-get install -y \
              maven \
              oracle-java8-installer 
        )

        # Node
        (
            sudo apt-get purge nodejs npm
            curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
            sudo apt-get install -y nodejs
        )

        # Tmux
        sudo apt-get install -y \
            libncurses5-dev \
            libevent-dev

        # Vim
        sudo apt-get install -y \
            python-dev \
            libperl-dev \
            ruby-dev

        sudo apt-get autoremove -y
    SHELL
end
