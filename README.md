Simple bash script to report resque stats to statsd

# Warning

This is alpha quality software. Be aware that it might eat your pet

# What it does?

By polling resque information directly from redis it will:
- pull all defined queues and their jobs counts
- number of failed jobs

and push it to statsd. The keys will have the following format:

```
resque.$ENVIRONMENT.$QUEUE_NAME.gauge:$VALUE|g"

```

for example

```
resque.staging.log_api.gauge:30|g
```

I've tested this script with latest resque, statsd and grafana.
YMMV.

# The setup

- Create a config file:

```bash
export STATSD_HOST=statsd.test.dev
export STATSD_ENV=production
export REDIS_HOST=redis.test.dev
export REDIS_PORT=6379
export REDIS_PASSWORD=foobar
```

- Launch it:

```bash
./resque-statsd ./config.sh
```

# Deployment

Easiest way is to:

- create the config
- add the script to cron with appropriate schedule

You can also do something like this:

```bash
echo "REPORT_INTERVAL=30" >> config.sh
nohup ./resque-statsd ./config.sh > ./resque-statsd.log &
```

(it will tell the script to poll redis every 30s, launch itself into the
background and detach from current session).

This way is not really recommended.


# Licence

GPL

Łukasz Korecki, 2015
