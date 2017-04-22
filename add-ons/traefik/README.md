# 部署Traefik做Ingress Control

## 配置Traefik服务

文件：traefik-service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: traefik-service
  namespace: kube-system
spec:
  selector:
    k8s-app: traefik-ingress-lb
  type: NodePort
  ports:
  - name: web
    port: 80
    targetPort: 80
    nodePort: 30081
```

把traefik部署成一个kubernetes服务，traefik部署不使用hostPort

targetPort:80       Traefik的均衡负载服务端口
nodePort:30081      在节点映射端口30081

## 主节点配置nginx

主节点使用反向代理，解析二级子域名的请求到traefik服务端口，配置文件：datacenter.conf
放在/etc/nginx/conf.d/目录下，解析域名为：*.datacenter.io

```shell
server
{
    listen 80;
    server_name *.datacenter.io;
    location / {
        proxy_redirect off;
        proxy_set_header host $host;
        proxy_set_header x-real-ip $remote_addr;
        proxy_set_header x-forwarded-for $proxy_add_x_forwarded_for;
        proxy_pass http://127.0.0.1:30081;
    }
    access_log /var/log/nginx/access-datacenter.log;
    error_log /var/log/nginx/error-datacenter.log;
}
```

## 使用实例

traefik Web UI的Service和Ingress如下：traefik-ui.yaml

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: traefik-dashboard
  namespace: kube-system
spec:
  selector:
    k8s-app: traefik-ingress-lb
  ports:
  - name: web
    port: 80
    targetPort: 8081
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: traefik-dashboard
  namespace: kube-system
spec:
  rules:
  - host: traefik.datacenter.io
    http:
      paths:
      - path: /
        backend:
          serviceName: traefik-dashboard
          servicePort: web
```
增加一条hosts记录

> $ sudo kubectl -f traefik-ui.yaml

> $ sudo vim /etc/hosts

> 192.168.1.13 traefik.datacenter.io

安装到kubernetes以后，traefik的dashboard可以访问：traefik.datacenter.io

## 配置DNS解析域名

安装DNS服务器

> $ sudo apt-get install bind9

### 配置外部解析

文件：named.conf.options


```shell
options {
	directory "/var/cache/bind";

	// If there is a firewall between you and nameservers you want
	// to talk to, you may need to fix the firewall to allow multiple
	// ports to talk.  See http://www.kb.cert.org/vuls/id/800113

	// If your ISP provided one or more IP addresses for stable 
	// nameservers, you probably want to use them as forwarders.  
	// Uncomment the following block, and insert the addresses replacing 
	// the all-0's placeholder.

	 forwarders {
	  202.96.134.133;
	  202.96.128.68;
	  223.5.5.5;
	  223.6.6.6;
	  114.114.114.114;
	 };

	//========================================================================
	// If BIND logs error messages about the root key being expired,
	// you will need to update your keys.  See https://www.isc.org/bind-keys
	//========================================================================
	dnssec-validation auto;

	auth-nxdomain no;    # conform to RFC1035
	listen-on-v6 { any; };
};
```
### 配置局域网解析

文件：named.conf.local

```shell
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include "/etc/bind/zones.rfc1918";
zone "datacenter.io" {
type master;
file "/etc/bind/db.datacenter.io";
};

zone "1.168.192.in-addr.arpa" {
type master;
file "/etc/bind/db.192.168.1";
};
```

### 配置正向解析

文件：db.datacenter.io

```shell
;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	datacenter.io. root.datacenter.io. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	datacenter.io.
@	IN	A	192.168.1.13
www	IN	A	192.168.1.13
git	IN	A	192.168.1.13
k8s	IN	A	192.168.1.13
jenkins	IN	A	192.168.1.13
traefik	IN	A	192.168.1.13
```

### 配置反向解析

文件：db.192.168.1

```shell
;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	datacenter.io. root.datacenter.io. (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	datacenter.io.
13	IN	PTR	datacenter.io.
```
### 使用局域网DNS服务器

> $ sudo service bind9 restart

修改计算机的DNS地址：192.168.1.13

这样就可以通过DNS来访问nginx的反向代理，不需要增加hosts记录
