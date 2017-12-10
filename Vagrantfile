#Version 1.0.2

# Plugin dependencies
required_plugins = %w( vagrant-vbguest )
required_plugins.each do |plugin|
    system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/xenial64"
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
        file_to_disk = 'connection.vdi'
        unless File.exist?(file_to_disk)
            vb.customize ['createhd', '--filename', file_to_disk, '--size', 20 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
    end

    # Create extra disk partition
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
         chown -R :ubuntu /data
         chmod -R g+rw /data
     SHELL

    # Ssh keys
    config.vm.provision "file",
        source: "~/.ssh/id_rsa",
        destination: "~/.ssh/id_rsa",
        run: "always"
    config.vm.provision "file",
        source: "~/.ssh/id_rsa.pub",
        destination: "~/.ssh/id_rsa.pub",
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
            cowsay \
            exuberant-ctags \
            figlet \
            fortune \
            git \
            git-core \
            lolcat \
            moreutils \
            pkg-config \
            python-setuptools \
            silversearcher-ag \
            subversion \
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
            sudo apt-get install -y oracle-java8-installer maven
        )

        # Node
        (
            sudo apt-get purge nodejs npm
            curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
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

        # my-env
        (
            grep github.com ~/.ssh/config || \
                echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

            [ ! -d my-env ] && git clone --recursive git@github.com:iamFIREcracker/my-env.git
            cd my-env
            bash install.sh \
                --force \
                --disable-b1 \
                --disable-nativefied-apps \
                --enable-vim \
                --enable-tmux
        )

        mkdir -p ~/workspace
        ln -s /vagrant/public ~/public

        sudo apt-get autoremove -y
    SHELL
end
