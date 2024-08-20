FROM ghcr.io/ngc7331/docker-baseimage-alpine:3.20
ARG TARGETARCH

ENV CONFIG_PATH=/config
ENV DATA_PATH=/data

RUN apk add --no-cache \
        apache2-utils

# registry
ARG REG_VERSION=2.8.3
ENV REG_CONFIG_PATH="${CONFIG_PATH}/registry"
ENV REG_DATA_PATH="${DATA_PATH}/registry"
RUN curl -Ljo registry.tar.gz "https://github.com/distribution/distribution/releases/download/v${REG_VERSION}/registry_${REG_VERSION}_linux_${TARGETARCH}.tar.gz" && \
    tar -xzvf registry.tar.gz --directory /bin/ registry && \
    rm registry.tar.gz && \
    registry --version

# registry auth
ENV AUTH_CONFIG_PATH="${CONFIG_PATH}/auth"
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
