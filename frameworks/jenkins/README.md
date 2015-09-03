
    # checkout a version that matches our mesos slaves
    # (see group_vars/mesos)
    brew install mesos

    git clone https://github.com/jenkinsci/mesos-plugin.git 
    cd mesos-plugin
    # check the  <mesos.version> stanza in pom.xml
    mvn hpi:run

Once it downloads the internet, it'll
spin up a jenkins on http://localhost:8080/jenkins/

# add a git plugin

although we won't be checking out code to the master,
we want to be able to build a git project.

open http://localhost:8080/jenkins/pluginManager/

click 'available' tag and type 'git' into the filter.
You want the one called just 'Git Plugin'.

install and bounce jenkins.

# prep a docker image

Since the slaves have no maven/git/jdk, we'll use a docker
container to run builds.

I'm also too lazy to run a registry so let's just build the 
image on each slave. See Dockerfile :

    #------------------8<------------------
    FROM mesosphere/spark:1.4.1-hdfs
    
    RUN apt-get update
    RUN apt-get install -y git maven
    
    #------------------8<------------------

copy this to each slave, then build with:

    docker build -t janky .

# set up mesos plugin

go to http://localhost:8080/jenkins/configure , and at the 
bottom you'll see 'add a new cloud' dropdown. choose 'Mesos Cloud'.

    Mesos native library path :
        /usr/local/Cellar/mesos/0.22.1/lib/libmesos.dylib
        ( C++ shared lib for jenkins to talk to mesos)
    Mesos master :
        zk://master1:2181/mesos 
        ( find master via zookeeper )
    Description :
        test mesos cluster
    Framework principal :
        blank it out
    Jenkins URL:
        http://10.0.0.1:8080/jenkins
        (a URL the slave can reach on its subnet):

save/apply now (the jenkins ui is pretty hideous and renders
badly, save as you go). you should see a zookeeper connection
happening in the console you launched jenkins from.

Click 'Advanced' (directly under the Jenkins URL box):

    Checkpointing:
        yes
    On-demand framework registration
        yes

That's it for the actual mesos connectivity settings.

# slaves

There are multiple 'slave' (mesos task) configs for this 'cloud' 
(mesos cluster). That lets you run different builds in different
environments by giving each task config a label and then tagging
builds as requiring that label.

Jenkins has created you a slave info subconfig, let's tweak that.

    Label String:
        maven-jvm-git
    Usage:
        Leave this node for tied jobs only
    Additional Jenkins Slave Agent JNLP arguments
        -noReconnect

Click 'Advanced' (the one under the JNLP arguments box. told
you jenkins UI was a bit wonky - these are advanced options for this
particular slave task)

    Use Docker Containerizer:
        tick
    Docker Image:
        janky
    Networking:
        host

## create job

fork 'https://github.com/wakaleo/game-of-life' -> your account on github.

main page -> new item

call it 'game-of-life', 'freestyle software project' -> ok.

    Restrict where this project can be run:
       tick
    Label expression:
       maven-jvm-git
    (these two ensure the build only runs on our mesos slave task)
    Source Code Management:
       git
    Repository URL:
        https://github.com/rasputnik/game-of-life.git
        (don't use 'git://' urls, proxies tend to not like them)


    Build Triggers:
       Select 'poll SCM'
    Schedule: 
       * * * * *

    Add build step:
       'invoke top-level maven targets'
    Goals:
       clean package

    Post-build actions -> 'add post-build action':
        'publish junit test result report'
    Test Report XMLS:
        **/target/surefire-reports/*.xml
    Post-build actions -> 'add post-build action':
        'archive the artifacsts'
    Files to archive:
        **/target/*.jar

'save'

twiddle thumbs for a minute.
the build should go through like any other.

# under the hood

* jenkins sees this job needs the 'maven-jvm-git' slave
* jenkins connects into mesos and registers as a framework
* mesos task launches in a docker container
* the mesos task downloads the slave.jar (via jenkins url we set)
* build runs as normal
* test results, build output etc. gets uploaded to master
* jenkins will keep the slave around a while in case other builds
  need it
* jenkins kills off its mesos task
* jenkins unregisters from mesos

# different strokes for different folks

if you want a different docker/mesos task setup, just go back to
http://localhost:8080/jenkins/configure. 

cloud -> mesos cloud -> 'advanced' -> 'add slave info' 

set whatever options you like, save it with a different label
and you can assign builds to it as before. 



