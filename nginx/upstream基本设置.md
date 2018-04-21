```
# 基本反向代理
upstream tomcat8080 {
	# ip_hash;
	# server 172.16.100.103:8080 weight=1 max_fails=2;
	server 10.76.249.128:8080 weight=1 max_fails=1 fail_timeout=1s;
	server 10.76.249.129:8080 weight=1 max_fails=1 fail_timeout=1s;
}


server
{
	listen 80;
	server_name 192.168.1.164;
	location / {
	# proxy_next_upstream http_502 http_504 error timeout invalid_header;
	proxy_pass http://tomcat8080;
	proxy_set_header Host 192.168.1.164;
	proxy_set_header X-Forwarded-For $remote_addr;
	}
	access_log /www/logs/tomcat.access.log;
}
```
