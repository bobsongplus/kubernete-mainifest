kubectl run myip --image=192.168.1.55/tenx_containers/whats-my-ip:latest --namespace=song --replicas=3 --port=8080
kubectl expose deployment myip --port=8080 --target-port=8080 --type=NodePort --namespace=song
