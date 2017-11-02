#!/bin/sh

template=$(cat <<EOF
[supervisord]
# run in foreground
nodaemon = true
pidfile = /tmp/supervisord.pid
logfile = /tmp/supervisord.log

[program:fluentd]
command=fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT

startretries=99999

stdout_logfile_maxbytes=10MB
stdout_logfile_backups=5

stderr_logfile_maxbytes=10MB
stderr_logfile_backups=5


[program:assist]
command=/assist $@
startretries=99999

stdout_logfile_maxbytes=10MB
stdout_logfile_backups=5

stderr_logfile_maxbytes=10MB
stderr_logfile_backups=5
EOF
  )

echo "${template}" > supervisord.conf

echo "Starting tenxcloud fluentd agent...."

supervisord -c supervisord.conf

