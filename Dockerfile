FROM ubuntu:16.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        git \
        iputils-ping \
        libcurl3 \
        libicu55 \
        libunwind8 \
        netcat \
        wget

# Install AZ CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
RUN echo "AZURE_EXTENSION_DIR=/usr/local/lib/azureExtensionDir" | tee -a /etc/environment \
    && mkdir -p /usr/local/lib/azureExtensionDir

# Install Powershell Core
RUN wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb \
        && dpkg -i packages-microsoft-prod.deb \
        && apt-get update \
        && apt-get install -y powershell

# Install unzip
RUN apt-get --assume-yes install unzip

# Install Terraform
ARG TERRAFORM_URL="https://releases.hashicorp.com/terraform/0.12.17/terraform_0.12.17_linux_amd64.zip"
RUN echo "Installing Terraform..."
RUN curl -sfLo terraform_linux_amd64.zip ${TERRAFORM_URL} \
  && unzip -o -q terraform_linux_amd64.zip -d /usr/local/bin \
  && rm terraform_linux_amd64.zip && terraform --version

WORKDIR /azp

RUN mkdir ./patches
COPY ./patches/AgentService.js ./patches/
COPY ./start.sh .
COPY ./start-once.sh .
RUN chmod +x start.sh
RUN chmod +x start-once.sh

CMD ["./start-once.sh"]