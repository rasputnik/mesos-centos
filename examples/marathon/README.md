Wire a local marathon instance into a mesos stack
(e.g. mesos-centos7).

saves cluttering the stack with frameworks.

    brew install mesos (for libmesos.dylib)

get your tarball:

    curl -s http://downloads.mesosphere.io/marathon/v0.7.0/marathon-0.7.0.tgz | tar zxv

export LIBPROCESS_IP=10.0.0.1 ## mac IP on the host network
./marathon-0.7.0/bin/start --zk zk://master1:2181/marathon --master zk://master1:2181/mesos --ha --event_subscriber http_callback

now open http://localhost:8080/ and you'll get the UI.

does a generic image work too?

curl -X POST -H "Content-Type: application/json" http://localhost:8080/v2/apps -d@bbdate.json
