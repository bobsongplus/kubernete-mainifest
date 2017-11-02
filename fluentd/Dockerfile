FROM 192.168.1.52/tenx_containers/fluentd-elasticsearch:v0.12
RUN apk add --no-cache supervisor
COPY ./td-agent.conf /fluentd/etc/fluent.conf
COPY ./assist /assist
COPY ./start.sh /start.sh
ENTRYPOINT ["/start.sh" "--logtostderr -v=2"]
