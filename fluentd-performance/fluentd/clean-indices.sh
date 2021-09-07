PASSWORD=$(kubectl get secret -n kube-system es-certs-es -oyaml |grep password  | awk '{print $2}' |base64 -d)
echo $PASSWORD
curl -XDELETE -uadmin:$PASSWORD -k https://10.110.229.254:9200/*-logstash-*
echo "indices:"
curl -uadmin:$PASSWORD -k https://10.110.229.254:9200/_cat/indices

