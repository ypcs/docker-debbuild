DOCKER ?= docker

all:

Dockerfile: Dockerfile.in
	cat "$<" |sed "s,^FROM .*,FROM ypcs/$(shell git branch --show-current |sed 's/-/:/g' |sed 's,master,debian:sid,g'),g" > $@

build:
	$(DOCKER) build --build-arg='APT_PROXY=http://10.0.2.149:3142/' -t ypcs/debbuild:latest .

run:
	$(DOCKER) run -e APT_PROXY=http://10.0.2.149:3142/ -e PACKAGE=nano ypcs/debbuild:latest

.PHONY: Dockerfile
