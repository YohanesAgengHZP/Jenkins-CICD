FROM jenkins/jenkins:lts-jdk17

# Switch to root user to install required packages
USER root

# Install Docker CLI and related dependencies in one layer
RUN apt-get update && \
    apt-get install -y lsb-release curl gnupg curl && \
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to Jenkins user
USER jenkins

# COPY plugin.txt /usr/share/jenkins/plugins.txt

# # Install Jenkins plugins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
# # RUN jenkins-plugin-cli --plugins "token-macro"
# RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt