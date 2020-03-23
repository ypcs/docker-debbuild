# docker-debbuild
Build .debs using Docker

This box allow easy building of .debs from either Debian/Ubuntu source packages or unpacked sources you mount to the container.

Automated scripts install build dependencies described in `debian/control` and run the actual build.

If you mount your host directory to `/artifacts`, .debs will be copied there after the build succeeds.

## Usage:
Build package 'nano' from it's upstream sources for Debian sid

    docker run --volume $(pwd)/artifacts:/articats:rw -e PACKAGE=nano ypcs/debbuild:debian-sid

Build package 'vim' from it's upstream sources for Ubuntu bionic

    docker run --volume $(pwd)/artifacts:/articats:rw -e PACKAGE=vim ypcs/debbuild:ubuntu-bionic

Build "random" package using sources we just cloned from the web. Requirement: must have working `debian/` build configuration. Use Debian buster as build environment.

    git clone https://github.com/SOMETHING/somewhere.git mysources

    docker run --volume $(pwd)/artifacts:/artifacts:rw --volume ./mysources:/usr/src/mysources:rw -e SOURCE_DIR=/usr/src/mysources ypcs/debbuild:debian-buster



## Development
Development is done in master branch. Changes should be synced to version-specific branches, and then Dockerfile should be updated using Makefile magic.

Example:

    # Ensure we have latest master
    git checkout master
    git pull

    # Let's create branch for next Debian release
    git checkout -b debian-bullseye
    make Dockerfile
    git add Dockerfile
    git commit -m "Add new release: Debian bullseye"

Then, someone has modified master, eg. added new feature. We want to refresh configuration for some release, let's say for Ubuntu bionic.

    git checkout ubuntu-bionic
    git rebase origin/master

To update all branches you could also run something like

    for branch in $(git br |grep -v master |xargs) ; do git checkout "${branch}" ; git rebase master ; make Dockerfile ; git add Dockerfile ; git commit -m "Update to latest Dockerfile" ; git rebase "origin/${branch}" ; git push ; done
