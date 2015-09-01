Run a mac Spark on the VM Mesos cluster.

# get a spark distro onto your Mac

    # ideally same as cluster version (see group_vars/mesos)
    brew install mesos

    export VER=1.4.1

    # no need for HDFS on this stack, but hadoop libs are needed
    # for some basic operations
    curl -s http://d3kbcqa49mib13.cloudfront.net/spark-${VER}-bin-hadoop2.6.tgz | tar xzv -

# dockerizinng executors

We'll need a JVM on each slave, plus the spark distro. That can be downloaded on the fly,
but that will need to happen each time you launch Spark.

To use Docker, you need to add a 'spark.mesos.executor.docker.image' field to spark-defaults.conf
(see sparkconf/ folder).

Best version for our purposes is "mesosphere/spark:1.4.1-hdfs" 

- actively maintained releases are tagged too
- has the mesos lib in there which docs refer to as needed here and there
- too lazy to make my own image
- don't have to bother running a registry
- faster task launching (once the slaves have it) vs. pulling the executor down
- right versions (java 7 and spark 1.4.1)

Mesos will trigger a 'docker pull' when spark specifies the image, but this
can take a few minutes (and cause spark to blacklist the slaves due to slow
responses).

Simplest fix is to pull the image before we start the spark shell:

    ansible slaves -i ../../vagrant/ -s -a 'docker pull mesosphere/spark:1.4.1-hdfs'

Once that comes back green (a good few minutes), we can actually launch a spark job.

    # we've overridden some defaults in 'sparkconf'
    # - see files there for details, they may need tweaking depending on your
    # spark version
    export SPARK_CONF_DIR=./sparkconf/

    # fire up a shell to check it connects to cluster
    ./spark-${VER}-bin-hadoop2.6/bin/spark-shell

# test out spark

We don't have HDFS setup yet so things won't be fully functional, but 
we can at least verify things can be shipped out. 
This example calculates pi by the 'throw darts and see what is within a circle' method.
Dial up NUM_SAMPLES for more accuracy (and longer run times, NUM_SAMPLES == a billion takes
around 30 seconds for me):

    var NUM_SAMPLES = 100
    
    var count = sc.parallelize(1 to NUM_SAMPLES).map{i =>
      val x = Math.random()
      val y = Math.random()
      if (x*x + y*y < 1) 1 else 0
    }.reduce(_ + _)
    println("Pi is roughly " + 4.0 * count / NUM_SAMPLES)
