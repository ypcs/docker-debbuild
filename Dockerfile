FROM ypcs/ubuntu:bionic

ARG APT_PROXY

RUN sed -i 's/main$/main universe/g' /etc/apt/sources.list && \
    /usr/lib/docker-helpers/apt-setup && \
    /usr/lib/docker-helpers/apt-upgrade && \
    apt-get --assume-yes install \
        build-essential \
        devscripts \
        gosu && \
    /usr/lib/docker-helpers/apt-cleanup

RUN adduser --disabled-password --gecos "user,,," user && \
    mkdir -p /artifacts && \
    touch /artifacts/.directory-not-mounted

WORKDIR /usr/src

COPY entrypoint.sh /usr/local/bin/debbuild

RUN ln -s /usr/local/bin/debbuild /entrypoint.sh

ENTRYPOINT ["/usr/local/bin/debbuild"]
CMD ["default"]

# Path to package sources. Should be below /usr/src, as I don't intent
# to test this tool with anything else.
ENV SOURCE_DIR ""

# Package to be built using sources from base image's source repository,
# eg. Debian or Ubuntu release
ENV PACKAGE ""
