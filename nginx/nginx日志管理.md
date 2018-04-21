```
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

   # access_log  /var/log/nginx/access.log  main;
#-----------------------------------------------
access_log /var/log/nginx/access.log.gz main gzip=6 flush=2m;
#
# flush=2m 每两分钟刷新 gzip=6 以gzip压缩，压缩等级为6
#-----------------------------------------------
```
