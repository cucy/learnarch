# 配置软件源
```
vi /etc/apk/repositories
https://mirrors.aliyun.com/alpine/v3.4/community
https://mirrors.aliyun.com/alpine/v3.4/main

```
- 更新软件缓存
```
apk update  
```

- 软件包搜索
```
$ apk search                    #查找所以可用软件包
$ apk search -v                 #查找所以可用软件包及其描述内容
$ apk search -v 'acf*'          #通过软件包名称查找软件包
$ apk search -v -d 'docker'     #通过描述文件查找特定的软件包
```
- 安装软件包
```
apk add gcc
apk add linux-headers   # python
apk add musl-dev
```

- 查找软件包信息
```
$ apk info              #列出所有已安装的软件包
$ apk info -a zlib       #显示完整的软件包信息
$ apk info --who-owns /sbin/lbu #显示指定文件属于的包
```
