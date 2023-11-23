FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

ENV CONFIG_PATH=/config
ENV DATA_PATH=/data

ENV REG_CONFIG_PATH="${CONFIG_PATH}/registry"
ENV REG_DATA_PATH="${DATA_PATH}/registry"
ENV AUTH_CONFIG_PATH="${CONFIG_PATH}/auth"
RUN mkdir -p ${REG_CONFIG_PATH} ${REG_DATA_PATH} ${AUTH_CONFIG_PATH} && \
    chown abc:abc ${REG_CONFIG_PATH} ${REG_DATA_PATH} ${AUTH_CONFIG_PATH}

RUN apt update && \
    apt install -y cron apache2-utils

ENV REG_VERSION=2.8.3
ENV REG_ARCH=amd64
RUN curl -Ljo registry.tar.gz "https://github.com/distribution/distribution/releases/download/v${REG_VERSION}/registry_${REG_VERSION}_linux_${REG_ARCH}.tar.gz" && \
    tar -xzvf registry.tar.gz --directory /bin/ registry && \
    rm registry.tar.gz && \
    registry --version

ENV AUTH_USER=admin
ENV AUTH_PASS=changeme

ENV TZ="Asia/Shanghai"
ENV PUID=1000
ENV PGID=1000
ENV UMASK=002
COPY root/ /
VOLUME [ "/config", "/data" ]
EXPOSE 5000
ENTRYPOINT [ "/entrypoints.sh" ]
CMD [ "/init" ]
