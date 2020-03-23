# docker-debbuild
Build .debs using Docker

This box allow easy building of .debs from either Debian/Ubuntu source packages or unpacked sources you mount to the container.

Automated scripts install build dependencies described in `debian/control` and run the actual build.

If you mount your host directory to `/artifacts`, .debs will be copied there after the build succeeds.
