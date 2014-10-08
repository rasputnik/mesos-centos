Wire a local marathon instance into a mesos stack
(e.g. mesos-centos7).
saves cluttering the stack with frameworks.

# OSX instructions

    brew install mesos (for libmesos.dylib)

get your tarball:

    curl -s http://downloads.mesosphere.io/marathon/v0.7.3/marathon-0.7.3.tgz | tar zxv

    export LIBPROCESS_IP=10.0.0.1 ## mac IP on the host network
    ./marathon-0.7.3/bin/start --zk zk://master1:2181/marathon --master zk://master1:2181/mesos --ha --event_subscriber http_callback

ui is at:

     open http://localhost:8080/

basic date loop in a busybox image:

    curl -X POST -H "Content-Type: application/json" http://localhost:8080/v2/apps -d@bbdate.json

try a docker image with networking:

    curl -X POST -H "Content-Type: application/json" http://localhost:8080/v2/apps -d@redis.json

check we can run 'vanilla' executors (i.e. not dockerized)

    curl -X POST -H "Content-Type: application/json" http://localhost:8080/v2/apps -d@pythons.json



## Docker notes:

first off, "uri" is empty. docker will pull the image for us
and we don't need anything else.

These settings tell Docker to map the container redis port
to a random host port on the slave:

      "network": "BRIDGE",
      "portMappings": [
        { "containerPort": 6379, "hostPort": 0, "protocol": "tcp"}
      ]


then we map that host port to a global app port with the usual:

      port: [0] 

## scaling

curl -XPUT http://localhost:8080/v2/apps/redis -d '{ "instances": "3" }' -H "Content-type: application/json"

# healthchecks

This sample app responds to the configured healthcheck with a 200. A 'GET /toggle' will flip it between
passing and failing). Click the app to get little traffic lights showing health or otherwise.

    curl -X POST -H "Content-Type: application/json" http://localhost:8080/v2/apps -d@http-health.json

