# 删除二进制日志
```shell
mysql> show binary logs; # 查看

# 删除之前的日志
mysql> PURGE BINARY LOGS BEFORE '2017-06-27 1:00:00';

```

# 正确安全清空在线慢查询日志slowlog的流程

- 1, see the slow log status;

mysql> show variables like 'slow_query_log_file';
+---------------------+---------------------------------------------------+
| Variable_name       | Value                                             |
+---------------------+---------------------------------------------------+
| slow_query_log_file | /var/lib/mysql/bukatest01-office-stg-192-slow.log |
+---------------------+---------------------------------------------------+
1 row in set (0.00 sec)



- 2, stop the slow log server.

mysql> set global slow_query_log=0;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like '%slow%';  -- check slow log status
+---------------------------+---------------------------------------------------+
| Variable_name             | Value                                             |
+---------------------------+---------------------------------------------------+
| log_slow_admin_statements | OFF                                               |
| log_slow_slave_statements | OFF                                               |
| slow_launch_time          | 2                                                 |
| slow_query_log            | OFF                                               |
| slow_query_log_file       | /var/lib/mysql/bukatest01-office-stg-192-slow.log |
+---------------------------+---------------------------------------------------+

- 3, reset the new path of slow log
mysql> set global slow_query_log_file='/tmp/slow_queries_3306_new.log';
Query OK, 0 rows affected (0.03 sec)

- 4, start the slow log server

mysql> set global slow_query_log=1;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like '%slow%';
+---------------------------+--------------------------------+
| Variable_name             | Value                          |
+---------------------------+--------------------------------+
| log_slow_admin_statements | OFF                            |
| log_slow_slave_statements | OFF                            |
| slow_launch_time          | 2                              |
| slow_query_log            | ON                             |
| slow_query_log_file       | /tmp/slow_queries_3306_new.log |


- 5, check the slow sql in the new slow log file.
mysql> select sleep(10) as a, 1 as b;
+---+---+
| a | b |
+---+---+
| 0 | 1 |
+---+---+
1 row in set (10.00 sec)

sudo more /tmp/slow_queries_3306_new.log 
/usr/sbin/mysqld, Version: 5.7.12-log (MySQL Community Server (GPL)). started with:
Tcp port: 3306  Unix socket: /var/lib/mysql/mysql.sock
Time                 Id Command    Argument
# Time: 2018-04-21T10:31:32.682386Z
# User@Host: root[root] @ localhost []  Id:  9399
# Query_time: 10.000248  Lock_time: 0.000000 Rows_sent: 1  Rows_examined: 0
use test;
SET timestamp=1524306692;
select sleep(10) as a, 1 as b;

- 6, backup the old big slow log file to other directory.
mv /mysqllog/slow_log/slow_queries_3306.log /mysqlbackup/slow_log/slow_queries_3306.log.bak.20180421







