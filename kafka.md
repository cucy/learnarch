## 基本安装
```
kafka安装
1、启动zookeeper
kafka依赖zookeeper，首先需要安装zookeeper
$ sudo bash /opt/zookeeper-3.4.6/bin/zkServer.sh start
 
 
版本
kafka_2.10-0.8.2.2
2、安装 kafka
$ sudo tar xf kafka_2.10-0.8.2.2.tgz -C /opt/
$ cd /opt/kafka_2.10-0.8.2.2/
$ sudo mkdir logs
3、修改日志路径
$sudo vim config/server.properties
log.dirs=/opt/kafka_2.10-0.8.2.2/logs
4、启动服务
$sudo /opt/kafka_2.10-0.8.2.2/bin/kafka-server-start.sh /opt/kafka_2.10-0.8.2.2/config/server.properties &
 
5、创建topic
sudo bin/kafka-topics.sh --create --zookeeper 192.168.1.51:2181 --replication-factor 1 --partitions 1 --topic room-internet-3
sudo bin/kafka-topics.sh --create --zookeeper 192.168.1.52:2181 --replication-factor 1 --partitions 1 --topic room-internet-3
sudo bin/kafka-topics.sh --create --zookeeper 192.168.1.53:2181 --replication-factor 1 --partitions 1 --topic room-internet-3
 
sudo bin/kafka-topics.sh --create --zookeeper 192.168.1.51:2181 --replication-factor 1 --partitions 1 --topic session-internet-3
sudo bin/kafka-topics.sh --create --zookeeper 192.168.1.52:2181 --replication-factor 1 --partitions 1 --topic session-internet-3
sudo bin/kafka-topics.sh --create --zookeeper 192.168.1.53:2181 --replication-factor 1 --partitions 1 --topic session-internet-3
 
sudo bin/kafka-topics.sh --create --zookeeper 192.168.1.51:2181 --replication-factor 1 --partitions 1 --topic user-internet-3
sudo bin/kafka-topics.sh --create --zookeeper 192.168.1.52:2181 --replication-factor 1 --partitions 1 --topic user-internet-3
sudo bin/kafka-topics.sh --create --zookeeper 192.168.1.53:2181 --replication-factor 1 --partitions 1 --topic user-internet-3
 
6、删除topic
sudo bin/kafka-topics.sh --delete --zookeeper 192.168.1.51:2181 --replication-factor 1 --partitions 1 --topic room-internet-3

```

## 一些参数

```
消息队列
	1.一对一
	2.一对多
	3.发布/订阅
	4.集群

producers 生产者
broker 中间形式
queue 队列 (一对一)   topic 主题（一对多，组内的消费者都可以消费消息）   消费者组


topic主题
容错 leader forlower 领袖跟班
 zookeep
producers
消费者
    标签，消费组 的名称
轮训方式
分区超出单机大小

安装甲骨文jdk

下载
http://apache.opencas.org/kafka/0.9.0.1/kafka_2.11-0.9.0.1.tgz

安装
tar xf kafka_2.11-0.9.0.1.tgz
ln -sv kafka_2.11-0.9.0.1 kafka
启动zookeeper
bin/zookeeper-server-start.sh config/zookeeper.properties

[root@master config]# egrep -v "^#|^$" zookeeper.properties 
dataDir=/tmp/zookeeper
clientPort=2181
maxClientCnxns=0   最大连接数不限制


kafka配置文件
[root@master config]# egrep -v "^#|^$" server.properties 
broker.id=0  
listeners=PLAINTEXT://:9092    #监听端口
num.network.threads=3        #网络的线程数
num.io.threads=8             # IO线程数量      
socket.send.buffer.bytes=102400  #发送套接字缓存大小
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/tmp/kafka-logs
num.partitions=1
num.recovery.threads.per.data.dir=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=6000
```

## 参考站点

```
http://blog.csdn.net/lizhitao/article/details/39499283



http://blog.csdn.net/suifeng3051/article/details/48053965


安装基本介绍
http://blog.csdn.net/hmsiwtv/article/details/46960053

http://www.jakubkorab.net/

```
