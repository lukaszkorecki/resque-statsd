#!/usr/bin/env bash

set -e

redisComand() {
  local host="$1"
  shift
  local port="$1"
  shift
  local password="$1"

  if [[ "$password" != '' ]] ; then
    local password_opt="-a $password"
  fi


  redis-cli -h $host $password_opt -p $port $*
}

redis() {
  redisComand "$REDIS_HOST" "$REDIS_PORT" "$REDIS_PASSWORD" $*
}

getQueues() {
  redis SMEMBERS resque:queues | awk '{ print $1 }' | sort

}

getQueueSize() {
  redis LLEN resque:queue:$1 | awk '{ print $1 }'
}

getFailedCount() {
  redis LLEN resque:failed | awk '{ print $1 }'

}

reportToStasd() {
  local host="$1"
  shift
  local env="$1"
  shift
  local queue="$1"
  shift
  local value="$1"

  if [[ "$queue$value" != "" ]] ; then
    local payload="resque.${env}.${queue}:$value|c"
    echo $payload | nc -w -u $host 8125
  fi
}

toStasd() {
  reportToStasd "$STATSD_HOST" "$STATSD_ENV" $1 $2
}

main() {
  for queue in $(getQueues) ; do
    local val=$(getQueueSize $queue)
    echo "$queue -> $val"
    toStatsd "$queue" "$val"
  done


  redis LLEN resque:failed
  getFailedCount
  echo getFailedCount
  echo "Failed -> ${getFailedCount}"

}

readonly configPath=$1
test "$configPath" != "" && test -e $configPath && source $configPath

echo $STATSD_HOST
echo $REDIS_HOST

main
