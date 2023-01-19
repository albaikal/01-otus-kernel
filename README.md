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

## 2. Запустим виртуальную машину.

```sh
aleksey@ub20-OTUS-EDU:~/edu/01-otus-kernel$ vagrant up
Bringing machine 'kernel-update' up with 'virtualbox' provider...
==> kernel-update: Importing base box 'centos/stream8'...
...
==> kernel-update: Booting VM...
...
==> kernel-update: Machine booted and ready!
...
==> kernel-update: Setting hostname...
```

## 3. Установка дополнительных ядер.

### 3.1 Подключимся к виртуальной машине по SSH посвредством vagrant.

```sh 
aleksey@ub20-OTUS-EDU:~/edu/01-otus-kernel$ vagrant ssh
Last login: Wed Jan 18 07:17:43 2023 from 10.0.2.2
[vagrant@kernel-update ~]$
```

### 3.2 Проверим текущую версию ядра, посмотрим установленные пакеты ядер, проверим доступные меню загрузчика.

```sh
[vagrant@kernel-update ~]$ uname -r
4.18.0-277.el8.x86_64


[vagrant@kernel-update ~]$ dnf list installed kernel kernel-\*
Failed to set locale, defaulting to C.UTF-8
Installed Packages
kernel.x86_64                                                                    4.18.0-277.el8                                                              @anaconda     
kernel-core.x86_64                                                               4.18.0-277.el8                                                              @anaconda     
kernel-headers.x86_64                                                            4.18.0-408.el8                                                              @baseos       
kernel-modules.x86_64                                                            4.18.0-277.el8                                                              @anaconda     
kernel-tools.x86_64                                                              4.18.0-277.el8                                                              @anaconda     
kernel-tools-libs.x86_64                                                         4.18.0-277.el8                                                              @anaconda     

[vagrant@kernel-update ~]$ sudo grubby --info=ALL
index=0
kernel="/boot/vmlinuz-4.18.0-277.el8.x86_64"
args="ro no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop $tuned_params"
root="UUID=ea09066e-02dd-46ad-bac9-700172bc3bca"
initrd="/boot/initramfs-4.18.0-277.el8.x86_64.img $tuned_initrd"
title="CentOS Stream (4.18.0-277.el8.x86_64) 8"
id="ee0aa2a41ed04a14ad5aac77ad6b5e06-4.18.0-277.el8.x86_64"
[vagrant@kernel-update ~]$ sudo grubby --default-index
0
```
### 3.3 Подключим репозиторий с ядрамиЁ установим наиболее свежее доступное ядро линейки MainLine(ml).

```sh
[vagrant@kernel-update ~]$ sudo yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
...
Dependencies resolved.
===========================================================================================================================================================================
 Package                                    Architecture                       Version                                      Repository                                Size
===========================================================================================================================================================================
Installing:
 elrepo-release                             noarch                             8.3-1.el8.elrepo                             @commandline                              13 k

Transaction Summary
===========================================================================================================================================================================
Install  1 Package
...
Installed:
  elrepo-release-8.3-1.el8.elrepo.noarch                                                                                                                                   

Complete!

[vagrant@kernel-update ~]$ sudo yum --enablerepo elrepo-kernel list available kernel kernel-ml kernel-lt
...
Available Packages
kernel.x86_64                                                                4.18.0-408.el8                                                                   baseos       
kernel-lt.x86_64                                                             5.4.228-1.el8.elrepo                                                             elrepo-kernel
kernel-ml.x86_64                                                             6.1.6-1.el8.elrepo                                                               elrepo-kernel

[vagrant@kernel-update ~]$ sudo yum -y --enablerepo elrepo-kernel install kernel-ml
...
Dependencies resolved.
===========================================================================================================================================================================
 Package                                     Architecture                     Version                                        Repository                               Size
===========================================================================================================================================================================
Installing:
 kernel-ml                                   x86_64                           6.1.6-1.el8.elrepo                             elrepo-kernel                            98 k
Installing dependencies:
 kernel-ml-core                              x86_64                           6.1.6-1.el8.elrepo                             elrepo-kernel                            34 M
 kernel-ml-modules                           x86_64                           6.1.6-1.el8.elrepo                             elrepo-kernel                            30 M

Transaction Summary
===========================================================================================================================================================================
Install  3 Packages
...

Installed:
  kernel-ml-6.1.6-1.el8.elrepo.x86_64                 kernel-ml-core-6.1.6-1.el8.elrepo.x86_64                 kernel-ml-modules-6.1.6-1.el8.elrepo.x86_64                

Complete!
```

[vagrant@kernel-update ~]$ sudo grubby --info=ALL
index=0
kernel="/boot/vmlinuz-6.1.6-1.el8.elrepo.x86_64"
args="ro no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop $tuned_params"
root="UUID=ea09066e-02dd-46ad-bac9-700172bc3bca"
initrd="/boot/initramfs-6.1.6-1.el8.elrepo.x86_64.img $tuned_initrd"
title="Enterprise Linux (6.1.6-1.el8.elrepo.x86_64) 8.7"
id="4b648c14661340e6a0b1d4efa9a4aee7-6.1.6-1.el8.elrepo.x86_64"
index=1
kernel="/boot/vmlinuz-4.18.0-277.el8.x86_64"
args="ro no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop $tuned_params"
root="UUID=ea09066e-02dd-46ad-bac9-700172bc3bca"
initrd="/boot/initramfs-4.18.0-277.el8.x86_64.img $tuned_initrd"
title="CentOS Stream (4.18.0-277.el8.x86_64) 8"
id="ee0aa2a41ed04a14ad5aac77ad6b5e06-4.18.0-277.el8.x86_64"
[vagrant@kernel-update ~]$ sudo grubby --default index
grubby-bls: option '--default' is ambiguous; possibilities: '--default-kernel' '--default-index' '--default-title'
[vagrant@kernel-update ~]$ sudo grubby --default-index
0
[vagrant@kernel-update ~]$ sudo grubby --default-kernel
/boot/vmlinuz-6.1.6-1.el8.elrepo.x86_64
[vagrant@kernel-update ~]$
[vagrant@kernel-update ~]$ sudo init 6
Connection to 127.0.0.1 closed by remote host.
Connection to 127.0.0.1 closed.
aleksey@ub20-OTUS-EDU:~/edu/01-otus-kernel$ vagrant ssh
Last login: Wed Jan 18 08:33:01 2023 from 10.0.2.2
[vagrant@kernel-update ~]$ uname -r
6.1.6-1.el8.elrepo.x86_64
[vagrant@kernel-update ~]$


[vagrant@kernel-update ~]$ cd /usr/src/kernels/
[vagrant@kernel-update kernels]$ ls -la
total 0
drwxr-xr-x. 2 root root  6 May 18  2020 .
drwxr-xr-x. 4 root root 34 Feb 10  2021 ..
[vagrant@kernel-update kernels]$ wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.86.tar.xz
-bash: wget: command not found
[vagrant@kernel-update kernels]$ curl -o linux-5.15.86.tar.xz https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.86.tar.xz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:02 --:--:--     0Warning: Failed to create the file linux-5.15.86.tar.xz: Permission denied
  0  120M    0  1306    0     0    427      0 82:17:30  0:00:03 82:17:27   428
curl: (23) Failed writing body (0 != 1306)
[vagrant@kernel-update kernels]$ sudo curl -o linux-5.15.86.tar.xz https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.86.tar.xz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  120M  100  120M    0     0  1197k      0  0:01:43  0:01:43 --:--:-- 1330k
[vagrant@kernel-update kernels]$ ls -la
total 123536
drwxr-xr-x. 2 root root        34 Jan 18 09:08 .
drwxr-xr-x. 4 root root        34 Feb 10  2021 ..
-rw-r--r--. 1 root root 126498884 Jan 18 09:10 linux-5.15.86.tar.xz
[vagrant@kernel-update kernels]$ sudo tar xf linux-5.15.86.tar.xz









