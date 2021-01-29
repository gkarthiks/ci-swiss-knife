FROM centos:8

# Labels
LABEL maintainer="github.gkarthiks@gmail.com"

# Update Certs
RUN yum -y update && yum -y install ca-certificates make
RUN update-ca-trust

# Install cURL, openssl, git, wget
RUN yum install -y openssl curl wget git

# Install yq
RUN export VERSION=$(curl --silent "https://api.github.com/repos/mikefarah/yq/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
        wget https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_linux_amd64 -O /usr/bin/yq && \
        chmod +x /usr/bin/yq

# Install Helm v3
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh && rm get_helm.sh

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
        chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

# Install oc
RUN curl -LO https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz && \
        gunzip openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz && \
        tar -xvf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar && \
        cd openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit && \
        chmod +x ./oc && mv ./oc /usr/local/bin/oc && \
        cd .. && rm -rf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.*

# Install trivy
RUN export VERSION=$(curl --silent "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') && \
        curl -LO https://github.com/aquasecurity/trivy/releases/download/v${VERSION}/trivy_${VERSION}_Linux-64bit.tar.gz && \
        tar zxvf trivy_${VERSION}_Linux-64bit.tar.gz && \
        chmod +x ./trivy && mv ./trivy /usr/local/bin/trivy && \
        rm -rf LICENSE contrib trivy trivy_0.12.0_Linux-64bit.tar.gz README.md

# Install semver cli
RUN export VERSION=$(curl --silent "https://api.github.com/repos/gkarthiks/semver/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
        curl -LO https://github.com/gkarthiks/semver/releases/download/${VERSION}/semver-linux-amd64 && \
        chmod +x ./semver-linux-amd64 && mv ./semver-linux-amd64 /usr/local/bin/semver

# Install nodeJS
RUN curl –sL https://rpm.nodesource.com/setup_10.x | bash - && \
        yum install -y nodejs gcc-c++ make

# Install Yarn
RUN curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
        yum install -y yarn

#Install Azure CLI & add devops extension
RUN yum install -y python3-devel gcc
RUN pip3 install azure-cli && az extension add --name azure-devops
