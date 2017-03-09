FROM docker:1.12-dind
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
    && echo "jenkins ALL=(ALL) NOPASSWD: /usr/local/bin/dockerd" >> /etc/sudoers.d/10-jenkins \
    && chmod 440 /etc/sudoers.d/10-jenkins

COPY Bangkok /usr/share
COPY jenkins-slave /usr/local/bin/jenkins-slave

# Install kubectl
RUN curl -sSLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Install Jenkins Remoting agent
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$JENKINS_REMOTNG_VERSION/remoting-$JENKINS_REMOTNG_VERSION.jar \
    && chmod 755 /usr/share/jenkins /usr/local/bin/jenkins-slave\
    && chmod 644 /usr/share/jenkins/slave.jar

VOLUME $JENKINS_HOME
WORKDIR $JENKINS_HOME

USER jenkins
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
