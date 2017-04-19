# Ubuntu 16.04 使用kubeadm部署kubernetes

* [kubernetes](https://github.com/kubernetes/kubernetes)
* [kubeadm reference](https://kubernetes.io/docs/admin/kubeadm/)
* [Installing Kubernetes on Linux with kubeadm](https://kubernetes.io/docs/getting-started-guides/kubeadm/)
* [kubeadm 搭建 kubernetes 集群](https://mritd.me/2016/10/29/set-up-kubernetes-cluster-by-kubeadm/)
* [使用Kubeadm安装Kubernetes](http://www.tuicool.com/articles/rYRzY3q)
* [Cluster add-ons](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons)

## 下载kubernetes

### 利用docker编译

#### 下载 Kubernetes 编译的各种发行版安装包来源于 Github 上的另一个叫 [release](https://github.com/kubernetes/release) 的项目

### 直接安装 需要翻墙

#### Ubuntu 16.04

```
    $ sudo apt-get update && apt-get install -y apt-transport-https
    $ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
    deb http://apt.kubernetes.io/ kubernetes-xenial main
    EOF
    $ sudo apt-get update
    $ apt-get install -y kubelet kubeadm kubectl kubernetes-cni
```

## 下载kubernetes相关镜像

> $ ./install_images.sh

### 利用docker hub的自动构建功能

* [相关镜像](https://kubernetes.io/docs/getting-started-guides/kubeadm/)
* [k8scn docker hub](https://hub.docker.com/u/k8scn/)
* [ist0ne docker hub](https://hub.docker.com/u/ist0ne/)
* [k8scn github](https://github.com/k8scn/k8s-cluster-deps)

| Image Name												| Version |
| --------------------------------------------------------- | ------- |
| gcr.io/google_containers/kube-apiserver-amd64				| v1.6.0  |
| gcr.io/google_containers/kube-controller-manager-amd64	| v1.6.0  |
| gcr.io/google_containers/kube-scheduler-amd64				| v1.6.0  |
| gcr.io/google_containers/kube-proxy-amd64					| v1.6.0  |
| gcr.io/google_containers/etcd-amd64						| 3.0.17  |
| gcr.io/google_containers/pause-amd64						| 3.0     |
| gcr.io/google_containers/k8s-dns-sidecar-amd64			| 1.14.1  |
| gcr.io/google_containers/k8s-dns-kube-dns-amd64			| 1.14.1  |
| gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64		| 1.14.1  |
| weaveworks/weave-kube		                                | 1.9.4   |
| weaveworks/weave-npc		                                | 1.9.4   |


## 首次安装

> $ sudo apt-get install ebtables

> $ sudo kubeadm init

## 清除环境

### 注意：可能会停止所有在运行的容器

#### 使用命令 [推荐]

> $ sudo kubeadm reset

#### 使用脚本

> $ sudo systemctl stop kubelet;

> $ docker rm -f $(docker ps -q); mount | grep "/var/lib/kubelet/*" | awk '{print $3}' | xargs umount 1>/dev/null 2>/dev/null;

> $ sudo rm -rf /var/lib/kubelet /etc/kubernetes /var/lib/etcd /etc/cni;


## 再次安装
	
选择flannel作为Pod网络插件可指定CIDR

> $ sudo kubeadm init --pod-network-cidr=10.244.0.0/16

```
    $ sudo kubeadm init
    [kubeadm] WARNING: kubeadm is in beta, please do not use it for production clusters.
    [init] Using Kubernetes version: v1.6.0
    [init] Using Authorization mode: RBAC
    [preflight] Running pre-flight checks
    [preflight] Starting the kubelet service
    [certificates] Generated CA certificate and key.
    [certificates] Generated API server certificate and key.
    [certificates] API Server serving cert is signed for DNS names [obe-ubuntu kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.31.69]
    [certificates] Generated API server kubelet client certificate and key.
    [certificates] Generated service account token signing key and public key.
    [certificates] Generated front-proxy CA certificate and key.
    [certificates] Generated front-proxy client certificate and key.
    [certificates] Valid certificates and keys now exist in "/etc/kubernetes/pki"
    [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
    [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"
    [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/controller-manager.conf"
    [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/scheduler.conf"
    [apiclient] Created API client, waiting for the control plane to become ready
    [apiclient] All control plane components are healthy after 16.646022 seconds
    [apiclient] Waiting for at least one node to register
    [apiclient] First node has registered after 4.030960 seconds
    [token] Using token: 2cd2d3.fe69190aee6dbdf9
    [apiconfig] Created RBAC rules
    [addons] Created essential addon: kube-proxy
    [addons] Created essential addon: kube-dns

    Your Kubernetes master has initialized successfully!

    To start using your cluster, you need to run (as a regular user):

    sudo cp /etc/kubernetes/admin.conf $HOME/
    sudo chown $(id -u):$(id -g) $HOME/admin.conf
    export KUBECONFIG=$HOME/admin.conf

    You should now deploy a pod network to the cluster.
    Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    http://kubernetes.io/docs/admin/addons/

    You can now join any number of machines by running the following on each node
    as root:

    kubeadm join --token ebde0b.8b52fdf14818bc7b 192.168.31.69:6443
```

## 建立admin配置文件

> $ ./enable_master_kubectl.sh    

```
    $ mkdir ~/.kube
    $ sudo cp /etc/kubernetes/admin.conf $HOME/.kube/
    $ sudo chown $(id -u):$(id -g) $HOME/.kube/admin.conf
    $ export KUBECONFIG=$HOME/.kube/admin.conf
    $ echo -e "\nexport KUBECONFIG=$HOME/.kube/admin.conf" >> ~/.bashrc
```

## 安装Pod Network


### 部署 flannel 网络

#### 下载 flannel的yaml文件

> $ wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml

> $ wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#### 建立 flannel 网络

> $ kubectl create -f kube-flannel-rbac.yml

> $ kubectl apply -f  kube-flannel.yml

#### 如果Node有多个网卡的话，需要在kube-flannel.yml中使用--iface参数指定集群主机内网网卡的名称，否则可能会出现dns无法解析，flanneld启动参数加上--iface=<iface-name>



### 部署 weave 网络

#### 下载 weave-kube.yaml

> $ wget https://git.io/weave-kube -O weave-kube.yaml


#### 建立 weave 网络

> $ kubectl create -f weave-kube.yaml





## 部署 dashboard

#### 下载 wkubernetes-dashboard.yaml

> $ wget https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml -O kubernetes-dashboard.yaml

#### 编辑 yaml 改一下 imagePullPolicy，把 Always 改成 IfNotPresent(本地没有再去拉取) 或者 Never(从不去拉取) 即可

#### 建立 dashboard

> $ kubectl create -f kubernetes-dashboard.yaml

> $ kubectl create -f kubernetes-dashboard-rbac.yaml


#### 访问 dashboard 

[参考](https://www.kubernetes.org.cn/1870.html)

* kubernetes-dashboard 服务暴露了 NodePort，可以使用 http://NodeIP:nodePort 地址访问 dashboard

> $ kubectl get services kubernetes-dashboard -n kube-system

* 通过 kube-apiserver 访问 dashboard（https 6443端口和http 8080端口方式）

需要提前导入证书到你的计算机中

> $ openssl pkcs12 -export -in admin.pem  -out admin.p12 -inkey admin-key.pem

* 通过 kubectl proxy 访问 dashboard

> $ kubectl proxy --address='172.20.0.113' --port=8086 --accept-hosts='^*$'


## 安装 addons

[官方Add-ons](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons)

### 命令

> $ kubectl apply -f <add-on.yaml>


### 安装 heapster

参考[Kubernetes Dashboard集成Heapster](http://www.tuicool.com/articles/ry2Azqy)

下载[heapster源码](https://github.com/kubernetes/heapster/releases)

> $ kubectl create -f deploy/kube-config/influxdb/


## 加入节点

```shell
    $ sudo kubeadm reset
    [preflight] Running pre-flight checks
    [reset] Stopping the kubelet service
    [reset] Unmounting mounted directories in "/var/lib/kubelet"
    [reset] Removing kubernetes-managed containers
    [reset] No etcd manifest found in "/etc/kubernetes/manifests/etcd.yaml", assuming external etcd.
    [reset] Deleting contents of stateful directories: [/var/lib/kubelet /etc/cni/net.d]
    [reset] Deleting contents of config directories: [/etc/kubernetes/manifests /etc/kubernetes/pki]
    [reset] Deleting files: [/etc/kubernetes/admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf]
    obe@obe-ubuntu:~$ sudo kubeadm join --token 761c22.9f998f804e906643 192.168.1.13:6443
    [kubeadm] WARNING: kubeadm is in beta, please do not use it for production clusters.
    [preflight] Running pre-flight checks
    [preflight] Starting the kubelet service
    [discovery] Trying to connect to API Server "192.168.1.13:6443"
    [discovery] Created cluster-info discovery client, requesting info from "https://192.168.1.13:6443"
    [discovery] Cluster info signature and contents are valid, will use API Server "https://192.168.1.13:6443"
    [discovery] Successfully established connection with API Server "192.168.1.13:6443"
    [bootstrap] Detected server version: v1.6.0
    [bootstrap] The server supports the Certificates API (certificates.k8s.io/v1beta1)
    [csr] Created API client to obtain unique certificate for this node, generating keys and certificate signing request
    [csr] Received signed certificate from the API server, generating KubeConfig...
    [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"

    Node join complete:
    * Certificate signing request sent to master and response
    received.
    * Kubelet informed of new secure connection details.

    Run 'kubectl get nodes' on the master to see this machine join.
```

### 建立admin配置文件

> $ ./enable_node_kubectl.sh

## 命令

### 获取集群服务地址列表

> $ kubectl cluster-info

### 使Master Node参与工作负载

> $ kubectl taint nodes --all  node-role.kubernetes.io/master-

### 加入你的节点

> $ kubeadm join --token <token> <master-ip>:<master-port>


### 从master以外的机器控制集群

> $ sudo scp root@<master ip>:/etc/kubernetes/admin.conf .

> $ sudo kubectl --kubeconfig ./admin.conf get nodes


### 查看服务

> $ kubectl get services -n kube-system


### 连接到API服务器

> $ sudo scp root@<master ip>:/etc/kubernetes/admin.conf .

> $ sudo kubectl --kubeconfig ./admin.conf proxy

### 查看集群中的节点

> $ kubectl get nodes


### 删除节点

> $ kubectl drain <node name> --delete-local-data --force --ignore-daemonsets

> $ kubectl delete node <node name>

### 查看POD状态

> $ kubectl get pod --all-namespaces

> $ kubectl get pod -n kube-system

### 诊断POD

> $ kubectl describe -n kube-system po {YOUR_POD_NAME}

### 查看分配的 NodePort

> $ kubectl get services kubernetes-dashboard -n kube-system

### 检查 controller

> $ kubectl get deployment kubernetes-dashboard  -n kube-system

### 使用 describe 命令 查看NodePoint

#### 我们可以查看其暴露出的 NodePoint，可局域网可访问

> $ kubectl describe svc kubernetes-dashboard -n kube-system
