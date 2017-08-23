

### 7

`站点`CentOS 7 http://elrepo.org/tiki/kernel-ml

- 1.Import the public key:
```shell
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
```
-  2.To install ELRepo for RHEL-7, SL-7 or CentOS-7:
```shell
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
```

- 3.To install kernel-ml you will need elrepo-release-7.0-1.el7.elrepo (or newer). Run:

```shell
yum --enablerepo=elrepo-kernel install kernel-ml.x86_64     kernel-ml-devel.x86_64
```
- 4. 修改启动顺序
```shell
grub2-set-default 0
# 重启
reboot
```

###  5/6

`站点`CentOS5/6 http://elrepo.org/tiki/kernel-lt 