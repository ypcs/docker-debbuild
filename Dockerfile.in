FROM ypcs/debian:sid

ARG APT_PROXY

RUN /usr/lib/docker-helpers/apt-setup && \
    /usr/lib/docker-helpers/apt-upgrade && \
    apt-get --assume-yes install \
        build-essential \
        devscripts \
        gosu && \
    /usr/lib/docker-helpers/apt-cleanup

RUN adduser --disabled-password --gecos "user,,," user

WORKDIR /usr/src

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["build"]

ENV SOURCE_DIR ""
ENV PACKAGE ""
