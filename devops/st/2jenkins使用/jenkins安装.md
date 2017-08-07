## Jenkins服务端部署 

### 1.准备预装Linux系统环境 

```shell
`CentOS 7.0 或 Ubuntu 16.04 及以上版本 `
```

### 2.安装Docker容器 

```shell
yum -y install docker
sed -ri "s@(OPTIONS=.*[a-z])'@\1 --registry-mirror=https://fz5yth0r.mirror.aliyuncs.com'@g" /etc/sysconfig/docker
`Version:      1.12.6`
```

### 3.导入离线镜像

```shell
- gogs/gogs
- jenkins/jenkins:2.72
- maven:3.5.0-jdk-8-alpine
```

### 4.通过Docker部署Gogs 

```shell
docker run -dt --name=gogs-p 10022:22  -p 3000:3000  -v /tmp/gogs_data:/data gogs/gogs
```

### 5.通过Docker部署Jenkins

- CentOS 安装git2
  ```shell
  yum -y remove git 
  cat > /etc/yum.repos.d/sclo.repo <<EOF
  [sclo]
  name=sclo
  baseurl=https://mirrors.aliyun.com/centos/7/sclo/x86_64/sclo
  gpgcheck=0
  EOF
  yum -y install sclo-git212
  scl enable sclo-git212 bash
  curl -ssL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > ~/.git-completion.bash
  source  ~/.git-completion.bash
  ```
- maven加速
  ```shell
  mkdir -p Maven
  cd Maven
  cat > Dockerfile <<EOF
  FROM maven:3.5.0-jdk-8-alpine
  RUN sed -i '/<mirrors>/a<mirror>\n<id>nexus-aliyun</id>\n<mirrorOf>*</mirrorOf>\n<name>Nexus aliyun</name>\n<url>http://maven.aliyun.com/nexus/content/groups/public</url>\n</mirror>' /usr/share/maven/conf/settings.xml
  EOF
  docker build -t maven:3.5.0-jdk-8-alpine .
  ```


若为`Ubuntu`或`Debian`系统，使用以下命令:
```shell
docker run -d --name jenkins \
-p 8000:8080 \
-p 10000:10000 \
-p 50000:50000 \
-v /opt/jenkins_data:/var/jenkins_home \
-v /usr/bin/docker:/usr/bin/docker \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/lib/x86_64-linux-gnu/libltdl.so.7:/usr/lib/x86_64-linux-gnu/libltdl.so.7 \
--user root \
jenkins/jenkins:2.72
```
`RHEL`或` CentOS `系统，使用以下命令:
```shell
docker run -d --name jenkins \
-p 8000:8080 \
-p 10000:10000 \
-p 50000:50000 \
-v /opt/jenkins_data:/var/jenkins_home \
-v /usr/bin/docker:/usr/bin/docker \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/lib64/libltdl.so.7:/usr/lib/x86_64-linux-gnu/libltdl.so.7 \
--user root \
jenkins/jenkins:2.72
```

### 6.解锁Jenkins 

`sed -i 's@http://www.google.com/@http://www.baidu.com/@g' /data/jenkins_home/updates/default.json`

在浏览器打开`http://<Linux机器IP>:8000`会打开`Jenkins`的操作页面并进入`Unlock Jenkins`画面

根据提示在容器中找到密钥文件内容： 

```shell
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

将密钥内容输入到界面上，完成解锁 .

### 7.插件初始化

解锁后进入`Customize Jenkins `页面

`````shell
Git 和 Pipeline  选择这两个插件
`````

