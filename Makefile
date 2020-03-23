NAMESPACE ?= ypcs/debian
DOCKER ?= docker

all:

Dockerfile: Dockerfile.in
	cp $< $@

build:
	$(DOCKER) build --build-arg='APT_PROXY=http://10.0.2.149:3142/' -t ypcs/debbuild:latest .

run:
	$(DOCKER) run -e APT_PROXY=http://10.0.2.149:3142/ -e PACKAGE=nano ypcs/debbuild:latest

.PHONY: Dockerfile
