# 删除二进制日志
```shell
mysql> show binary logs; # 查看

# 删除之前的日志
mysql> PURGE BINARY LOGS BEFORE '2017-06-27 1:00:00';

```
