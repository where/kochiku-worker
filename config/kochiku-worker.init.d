#!/bin/bash --login
WORKER_DIR=/app/kochiku-worker/current
export PIDFILE=/app/kochiku-worker/shared/pids/kochiku-worker.pid
queues=ci,developer

cd $WORKER_DIR

case "$1" in
  start)
    rm -f $PIDFILE
    echo "starting worker from $(pwd)"
    su -l stack -c 'cd '$WORKER_DIR' && QUEUES='${queues:-"*"}' VERBOSE=1 bundle exec rake resque:work </dev/null >> '$WORKER_DIR'/log/resque.log 2>&1 &'
  ;;
  stop)
    kill -s QUIT $(cat $PIDFILE) && rm -f $PIDFILE
    exit 0
  ;;
  pause)
    kill -s USR2 $(cat $PIDFILE)
    exit 0
  ;;
  cont)
    kill -s CONT $(cat $PIDFILE)
    exit 0
  ;;
  restart)
    $0 stop
    $0 start
  ;;
  status)
    ps -e -o pid,command | grep [r]esque
  ;;
  *)
    echo "Usage: $0 {start|stop|restart|pause|cont|status}"
    exit 1
esac

