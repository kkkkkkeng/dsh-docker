FROM node:24-bookworm

ARG DSH_VERSION=latest

ENV TZ=Asia/Shanghai

# Keep compilers available for native npm modules and development projects.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      python3 python3-venv python3-pip \
      build-essential cmake ninja-build \
      git curl wget jq \
      openssh-client \
      ripgrep vim tmux \
      iproute2 iputils-ping dnsutils \
      procps ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g --no-audit --no-fund \
      "@deepseek-ai/dsh@${DSH_VERSION}" \
    && npm cache clean --force

LABEL org.opencontainers.image.title="DSH development environment" \
      org.opencontainers.image.description="DeepSeek Harness with basic development tools" \
      org.opencontainers.image.version="${DSH_VERSION}"

RUN mkdir -p /workspace /root/.dsh

# Docker bridge networking needs an all-interfaces bind inside the container.
# Use the supported profile overlay instead of the CLI's restricted --host flag.
RUN mkdir -p /etc/dsh && \
    printf '%s\n' \
      '- id: webserver' \
      '  config:' \
      "    host: '0.0.0.0'" \
      '    port: 3080' \
      > /etc/dsh/network.yml

WORKDIR /workspace

EXPOSE 3080

CMD ["dsh", "web", "--patch", "/etc/dsh/network.yml", "--no-open"]
