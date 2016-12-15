FROM docker:1.12.4-dind
MAINTAINER Peerapach <tum@ezylinux.com>

ENV JENKINS_HOME /home/jenkins
ENV JENKINS_REMOTNG_VERSION 3.2

ENV DOCKER_HOST tcp://0.0.0.0:2375

# Install requirements
RUN apk --update add \
    curl \
    git \
    openjdk8-jre \
    sudo

# Add jenkins user and allow jenkins user to run as root
RUN adduser -D -h $JENKINS_HOME -s /bin/sh jenkins jenkins \
    && chmod a+rwx $JENKINS_HOME \
    && echo "jenkins ALL=(ALL) NOPASSWD: /usr/local/bin/docker" > /etc/sudoers.d/10-jenkins \
    && chmod 440 /etc/sudoers.d/10-jenkins

# Install Jenkins Remoting agent
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$JENKINS_REMOTNG_VERSION/remoting-$JENKINS_REMOTNG_VERSION.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/slave.jar

COPY jenkins-slave /usr/local/bin/jenkins-slave

VOLUME $JENKINS_HOME
WORKDIR $JENKINS_HOME

USER jenkins
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
