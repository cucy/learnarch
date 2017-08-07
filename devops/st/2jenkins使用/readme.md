## 练习一 Jenkins的基本配置 

### 1.用户管理

点左侧菜单栏“Manage Jenkins”，在管理页面点击“Manage Users” 

左侧的“Create User”按钮可以添加用户，右侧每个用户的齿轮图表可以修改用户配置 

点击 admin 的齿轮图标，修改此用户密码，点击保存 

### 2.安装插件

`Git plugin和Pipeline`



## 练习二 简单的可视化流水线

### 1.创建流水线项目

点击菜单栏左侧的“New Item”，在新建项目页面给新项目起名，选择类型为“Pipeline”。点击“OK”

### 2.简单的多步骤流水线 

Groovy DSL scripts

http://wilsonmar.github.io/jenkins2-pipeline/#Groovy

在“Pipeline”的部分写入流水线描述，然后点击“Save”。

```groovy
pipeline {
	agent any
	stages {
		stage('步骤一') {
			steps {
				sh 'echo "Single line step"'
			}
		}
		stage('步骤二') {
			steps {
				sh '''
				echo "Multiline shell steps"
				ls -la
				'''
			}
		}
	}
}
```

### 3.执行流水线 

在流水线页面点击“Build Now”，如果没有错误发生，每个步骤都会以绿色的方块表示出来

执行完成后，可以点击每一个步骤，查看该步骤执行日志 

### 4.稍复杂的流水线

这个流水线会自己从Git仓库拉取代码，然后在⼀个提供构建环境的Docker容器里进行代码构建。
新建一个项目，命名“parent-pom”，使用如下配置信息： 

```groovy
pipeline {
	agent {
		docker {
			reuseNode true
			image "maven:3.5.0-jdk-8-alpine"
			args "-v /opt/m2:/root/.m2"
		}
	}
	stages {
		stage('代码更新') {
			steps {
				git url: "https://github.com/microservices-kata/petstore-parent-pom.git"
			}
		}
		stage('构建代码') {
			steps {
				sh "mvn clean install"
			}
		}
	}
}
```

### 5.接近真实项目的构建流水线

如果在构建时下载依赖的速度非常慢，可将依赖源替换为国内服务器：

```xml
cat <<EOF | sudo tee /opt/m2/settings.xml
	<settings>
		<mirrors>
			<mirror>
				<id>nexus-aliyun</id>
				<mirrorOf>*</mirrorOf>
				<name>Nexus aliyun</name>
				<url>http://maven.aliyun.com/nexus/content/groups/public</url>
			</mirror>
	</mirrors>
	</settings>
EOF
```



再次新建一个流水线，命名为“account-service”。这个流水线在完成构建以后还会接着执行项目的单元测试、生成发布的包，最后执行接口测试。

在最后一步执行`契约测试`的地方会失败，因为连接不到放契约文件的服务器。观察失败时流水线的表现。  

```groovy
pipeline {
	agent {
		docker {
			reuseNode true
			image "maven:3.5.0-jdk-8-alpine"
			args "-v /opt/m2:/root/.m2"
		}
	}
	stages {
		stage('代码更新') {
			steps {
				git url: "https://github.com/microservices-kata/petstore-account-service.git" }
			}
			stage('构建代码') {
				steps {
					sh "mvn clean compile"
				}
			}
			stage('单元测试') {
				steps {
					sh "mvn test"
				}
			}
			stage('生成运行包') {
				steps {
					sh "mvn package"
				}
			}
			stage('集成测试') {
				steps {
					sh "mvn verify"
				}
			}
		}
	}
```

## 练习三 使用Jenkinsfile快速生成流水线

### 1.将Github仓库中的代码导入到私有仓库 

在`petstore-account-service`项目中已经包含了生成流水线的Jenkinsfile文件，但其中的内容有些超出了这次的课程范围，需要对这个文件进行修改。

利用在第一次课中学习的内容，
将`https://github.com/microservices-kata/petstore-account-service.git`仓库的代码复制到Gogs仓库中，以方便对其中的内容进行修改。

```shell
git clone https://github.com/microservices-kata/petstore-account-service.git
git remote add stuq http://<Gogs服务器的IP>:3000/<用户户名>/<仓库名>
git push -u stuq
```

### 2.修改Jenkinsfile并删除契约测试 

在Jenkinsfile中删除“创建镜像”和“部署Dev环境”两个步骤。 删除 `src/test/scala/com/thoughtworks/petstore/contract/VerifyPacts.scala`文件

### 3.创建使用Jenkinsfile生成的流水线

在Jenkins新创建一个Pipeline类型的项目。
将Pipeline的`Definition`属性选择“Pipeline script from SCM”，选择SCM类型为“Git”，填入Gogs仓库地
址。
执行流水线， Jenkins会自动从Git仓库获得代码以及流水线的信息，完成整个流程的自动化。

### 4.添加自动构建 

在项目的Build Triggers配置下面勾选`Poll SCM`，填写一个定时检查代码更新的Crontab时间表达式 

```shell
# 定时计划
H/5 * * * *
```

## 练习四 使用API批量创建流水线 

### 1.开启远程访问许可 

在Jenkins主⻚点击`Manage Jenkins`，选择`Configure Global Security`，找到最下面的“SSHServer”功能，开启此功能并选择固定端口： 10000

### 2.生成SSH密钥 

在Linux服务器上生成一个密钥文件，并查看公钥内容 

```shell
ssh-keygen
cat ~/.ssh/id_rsa.pub
```

### 3.添加用户公钥到Jenkins 

进入`Manage Jenkins`中的 Manage Users 页面，点击当前⽤户列的⼩⻮轮，在“SSH Public Key”配置中填入户的公钥

### 4.使用API创建流水线 

```shell
 ssh -l admin -p 10000 <Jenkins机器IP> help
```

先拿一个项目做模板 

```shell
ssh -l admin -p 10000 <Jenkins机器IP> get-job <流水线项目名称> > template.xml
```

将输出内容保存成`template.xml`文件，修改其中的项目配置，然后用这个文件批量创建流水线

```shell
ssh -l admin -p 10000 <Jenkins机器IP> create-job <新的项目名称> < template.xml
```

