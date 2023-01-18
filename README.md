# 01. OTUS. Kernel update.

## 1. Создадим файл конфигурации виртуальной машины 

```bash
aleksey@ub20-OTUS-EDU:~/edu/01-otus-kernel$ vim Vagrantfile
```
```ruby
# Описываем Виртуальные машины
MACHINES = {
  # Указываем имя ВМ "kernel update"
  :"kernel-update" => {
    #Какой vm box будем использовать
    :box_name => "centos/stream8",
    #Указываем box_version
    :box_version => "20210210.0",
    #Указываем количество ядер ВМ
    :cpus => 2,
    #Указываем количество ОЗУ в мегабайтах
    :memory => 1024,
  }
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    # Отключаем проброс общей папки в ВМ
    config.vm.synced_folder ".", "/vagrant", disabled: true
    # Увеличиваем таймаут загрузки
    config.vm.boot_timeout = 350
    # Применяем конфигруацию ВМ
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.box_version = boxconfig[:box_version]
      box.vm.host_name = boxname.to_s
      box.vm.provider "virtualbox" do |v|
        v.memory = boxconfig[:memory]
        v.cpus = boxconfig[:cpus]
      end
    end
  end
end
```

## 2. Запустим виртуальную машину и подключимся к ней по SSH

```sh
aleksey@ub20-OTUS-EDU:~/edu/01-otus-kernel$ vagrant up
Bringing machine 'kernel-update' up with 'virtualbox' provider...
==> kernel-update: Importing base box 'centos/stream8'...
==> kernel-update: Matching MAC address for NAT networking...
==> kernel-update: Checking if box 'centos/stream8' version '20210210.0' is up to date...
==> kernel-update: Setting the name of the VM: 01-otus-kernel_kernel-update_1674025525136_59045
==> kernel-update: Clearing any previously set network interfaces...
==> kernel-update: Preparing network interfaces based on configuration...
    kernel-update: Adapter 1: nat
==> kernel-update: Forwarding ports...
    kernel-update: 22 (guest) => 2222 (host) (adapter 1)
==> kernel-update: Running 'pre-boot' VM customizations...
==> kernel-update: Booting VM...
==> kernel-update: Waiting for machine to boot. This may take a few minutes...
    kernel-update: SSH address: 127.0.0.1:2222
    kernel-update: SSH username: vagrant
    kernel-update: SSH auth method: private key
    kernel-update: 
    kernel-update: Vagrant insecure key detected. Vagrant will automatically replace
    kernel-update: this with a newly generated keypair for better security.
    kernel-update: 
    kernel-update: Inserting generated public key within guest...
    kernel-update: Removing insecure key from the guest if it's present...
    kernel-update: Key inserted! Disconnecting and reconnecting using new SSH key...
==> kernel-update: Machine booted and ready!
==> kernel-update: Checking for guest additions in VM...
    kernel-update: No guest additions were detected on the base box for this VM! Guest
    kernel-update: additions are required for forwarded ports, shared folders, host only
    kernel-update: networking, and more. If SSH fails on this machine, please install
    kernel-update: the guest additions and repackage the box to continue.
    kernel-update: 
    kernel-update: This is not an error message; everything may continue to work properly,
    kernel-update: in which case you may ignore this message.
==> kernel-update: Setting hostname...
aleksey@ub20-OTUS-EDU:~/edu/01-otus-kernel$ vagrant ssh
Last login: Wed Jan 18 07:17:43 2023 from 10.0.2.2
[vagrant@kernel-update ~]$
```
