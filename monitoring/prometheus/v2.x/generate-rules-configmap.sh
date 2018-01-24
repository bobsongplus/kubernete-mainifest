#!/bin/bash
# convert many rule file into configmap
cat <<-EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-rules
  namespace: kube-system
data:
EOF

for f in /etc/prometheus_rules/*.rule.y*ml
do
  suffix=.yml
  filename=$(basename "$f")
  echo "  ${filename%$suffix}: |+"
  cat $f | sed "s/^/    /g"
done
