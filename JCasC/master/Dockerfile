FROM jenkins/jenkins:lts-jdk11
COPY plugins_extra.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# Copy Jenkins config as code
COPY ./jenkins.yaml /var/jenkins_home/jenkins.yaml

# Set java options.
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
