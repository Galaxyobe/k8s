# Image name from: https://kubernetes.io/docs/getting-started-guides/kubeadm/

# Image Name												Version
# gcr.io/google_containers/kube-apiserver-amd64				v1.6.0
# gcr.io/google_containers/kube-controller-manager-amd64	v1.6.0
# gcr.io/google_containers/kube-scheduler-amd64				v1.6.0
# gcr.io/google_containers/kube-proxy-amd64					v1.6.0
# gcr.io/google_containers/etcd-amd64						3.0.17
# gcr.io/google_containers/pause-amd64						3.0
# gcr.io/google_containers/k8s-dns-sidecar-amd64			1.14.1
# gcr.io/google_containers/k8s-dns-kube-dns-amd64			1.14.1
# gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64		1.14.1


# https://hub.docker.com/r/k8scn/
# https://hub.docker.com/u/ist0ne/

DownImages=(
	# kube #5
	k8scn/kube-apiserver-amd64:v1.6.0
	k8scn/kube-controller-manager-amd64:v1.6.0
	k8scn/kube-scheduler-amd64:v1.6.0
	k8scn/kube-proxy-amd64:v1.6.0
	k8scn/kubernetes-dashboard-amd64:v1.6.0
	# #4
	k8scn/kube-discovery-amd64:latest
	k8scn/kubedns-amd64:latest 
	k8scn/kube-dnsmasq-amd64:latest
	k8scn/exechealthz-amd64:latest 
	# etcd #1
	k8scn/etcd-amd64:3.0.17
	# pause #1
	k8scn/pause-amd64:latest
	# k8s-dns #3
	k8scn/k8s-dns-sidecar-amd64:1.14.1
	k8scn/k8s-dns-kube-dns-amd64:1.14.1
	k8scn/k8s-dns-dnsmasq-nanny-amd64:1.14.1
	# weave #2
	k8scn/weave-kube:latest
	k8scn/weave-npc:latest
	# flannel #1
	ouyangnb/flannel:v0.7.0-amd64
	# heapster #3
	ctagk8s/heapster-amd64:v1.3.0-beta.1
	unmask10eve/heapster-influxdb-amd64:v1.1.1
	unmask10eve/heapster-grafana-amd64:v4.0.2
	# fluentd-elasticsearch #3
	ist0ne/elasticsearch:v2.4.1-2
	ist0ne/fluentd-elasticsearch:1.22
	ist0ne/kibana:v4.6.1
)




# kubeadm 需要的 Tag
# TODO:与IMAGES对应

NeedImages=(
	# kube #5
	gcr.io/google_containers/kube-apiserver-amd64:v1.6.0
	gcr.io/google_containers/kube-controller-manager-amd64:v1.6.0
	gcr.io/google_containers/kube-scheduler-amd64:v1.6.0
	gcr.io/google_containers/kube-proxy-amd64:v1.6.0
	gcr.io/google_containers/kubernetes-dashboard-amd64:v1.6.0
	# #4
	gcr.io/google_containers/kube-discovery-amd64:1.0
	gcr.io/google_containers/kubedns-amd64:1.9
	gcr.io/google_containers/kube-dnsmasq-amd64:1.4.1
	gcr.io/google_containers/exechealthz-amd64:v1.2.0 
	# etcd #1
	gcr.io/google_containers/etcd-amd64:3.0.17
	# pause #1
	gcr.io/google_containers/pause-amd64:3.0
	# k8s-dns #3
	gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.1
	gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.1
	gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.1
	# weave #2
	weaveworks/weave-kube:1.9.4
	weaveworks/weave-npc:1.9.4
	# flannel #1
	quay.io/coreos/flannel:v0.7.0-amd64
	# heapster #3
	gcr.io/google_containers/heapster-amd64:v1.3.0-beta.1
	gcr.io/google_containers/heapster-influxdb-amd64:v1.1.1
	gcr.io/google_containers/heapster-grafana-amd64:v4.0.2
	# fluentd-elasticsearch #3
	gcr.io/google_containers/elasticsearch:v2.4.1-2
	gcr.io/google_containers/fluentd-elasticsearch:1.22
	gcr.io/google_containers/kibana:v4.6.1-1
)

for downImage in ${DownImages[@]} ; do
	echo "-------------------------------------------------------------------"
	echo "Pull ${downImage}"
	docker pull ${downImage}

	downImage_name_tag=${downImage##*/}
	_downImage_name_tag=(${downImage_name_tag//:/ })
	downImage_name=$_downImage_name_tag[0]
	# 替换Tag
	for needImage in ${NeedImages[@]} ; do
		needImage_name_tag=${needImage##*/}
		_needImage_name_tag=(${needImage_name_tag//:/ })
		needImage_name=$_needImage_name_tag[0]
		if [ "${downImage_name}" = "${needImage_name}" ] ; then
			echo "Tag ${downImage} To ${needImage}"
			docker tag ${downImage} ${needImage}
			docker rmi ${downImage}
		fi
	done
done