# /docker/build-environment/Dockerfile
FROM alpine:3.21

# Install build essentials and tools
RUN apk add --no-cache \
    bash \
    curl \
    git \
    docker \
    docker-cli \
    make \
    gcc \
    g++ \
    python3 \
    py3-pip \
    nodejs \
    npm \
    sudo \
    jq \
    yq \
    openssl

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
    mv kustomize /usr/local/bin/

WORKDIR /workspace

CMD ["/bin/bash"]