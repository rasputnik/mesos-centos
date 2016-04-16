This readme assumes you already have the Vagrant mesos stack VMs running on your Mac.

# install Jenkins on your Mac

    # checkout a version that matches your mesos VMs
    # (see inventory)
    brew install mesos

    git clone https://github.com/jenkinsci/mesos-plugin.git 
    cd mesos-plugin
    # check the  <mesos.version> stanza in pom.xml
    mvn hpi:run

Once it downloads the internet, it'll
spin up a jenkins locally

    open http://localhost:8080/jenkins/

# add git plugin to master

although we won't be checking out code to the master,
we want to be able to build a git project.

open http://localhost:8080/jenkins/pluginManager/

click 'available' tag and type 'git' into the filter.
You want the one called just 'Git Plugin'.

install the plugin and bounce jenkins.

# prep a docker image

The slaves have no JDK, git or maven installation.

Since our builds are running in a docker container that's not a problem.

We'll just craft an image with our requirements in it. To save time I've 
put one up as 'rasputnik/mvn3:v1' _(Dockerfiles are in this folder_).

# set up mesos plugin

    open http://localhost:8080/jenkins/configure

at the bottom you'll see 'add a new cloud' dropdown. choose 'Mesos Cloud'.

    Mesos native library path :
        /usr/local/Cellar/mesos/0.28.0/lib/libmesos.dylib
        ( C++ shared lib for jenkins to talk to mesos)
    Mesos master :
        zk://master1:2181/mesos 
        ( find master via zookeeper )
    Description :
        test mesos cluster
    Slave username :
        root
        ( what user to run the mesos tasks as )
    Jenkins URL:
        http://10.0.0.1:8080/jenkins
        (URL should be reachable from the slaves i.e. in the host-only subnets)

save/apply now (the jenkins ui is pretty hideous and renders
badly, save as you go). you should see a zookeeper connection
happening in the console you launched jenkins from.

Click 'Advanced' (directly under the Jenkins URL box):

    Checkpointing:
        yes
    (mesos frameworks should always checkpoint)
    On-demand framework registration
        yes
    (this only connects to mesos when there's work to do. 
     It means you won't see jenkins in the mesos ui when it's not building,
     but makes it play nicer with other frameworks if its running 'hungry' jobs)

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
particular slave task). The important part is 'Docker Image' which tells Jenkins which image to run builds in.

    Use Docker Containerizer:
        tick
    Docker Image:
        'rasputnik/mvn3:v1'
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
        https://github.com/{your-github}/game-of-life.git
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

Check the sandbox stdout/stderr if you hit any issues.

# different strokes for different folks

if you want a different docker/mesos task setup, just go back to
http://localhost:8080/jenkins/configure. 

cloud -> mesos cloud -> 'advanced' -> 'add slave info' 

set whatever options you like, save it with a different label
and you can assign builds to it as before. 
