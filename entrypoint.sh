#!/bin/sh
set -e
#
# Helper for building .debs from sources
#
# - fetch source code when necessary
# - install build dependencies based on debian/control
# - build the actual package
#
# and, if you've mounted $your_volume to /artifacts,
# copy build results from container to a directory
# on your host.
#
# And, do only necessary parts as root (uid=0),
# eg. actual build will be done as non-privileged
# user
#
# Author: Ville Korhonen <ville@xd.fi>
#

COMMAND="$1"

[ -z "${COMMAND}" ] && echo "Usage: $0 <command>" && exit 1
shift

# FIXME: bump version
# FIXME: build package
# FIXME: allow forcing package version

if [ \( -n "${SOURCE_DIR}" \) -a \( "${SOURCE_DIR}" != "/dev/null" \) ]
then
    BUILD_TYPE="source_dir"
elif [ \( -n "${PACKAGE}" \) -a \( "${PACKAGE}" != "" \) ]
then
    BUILD_TYPE="package"
else
    echo "You must define \$SOURCE_DIR or \$PACKAGE!"
    exit 1
fi


# FIXME: if SOURCE_DIR AND not /dev/null AND SOURCE_DIR/debian exists, build it
# FIXME: if SOURCE_DIR not defined, read PACKAGE and apt-get source it

case "${COMMAND}"
in
    collect-artifacts)
    	# FIXME: collect artifacts to /artifacts or something
	echo "FIXME: collect artifacts"
	# FIXME: check if /artifacts/.directory-not-mounted or something exists (and provide that by default)
    ;;
    install-deps)
        echo "Installing build dependencies..."
        mk-build-deps --build-dep --install --remove --tool "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y"
    ;;
    get-source)
	if [ -z "${PACKAGE}" ]
	then
	    echo "Package not set!"
            exit 1
	fi
	cat /etc/apt/sources.list
	sed -i 's/^#deb-src/deb-src/g' /etc/apt/sources.list
	apt-get update
	# FIXME: W: Download is performed unsandboxed as root as file 'nano_4.8-1.dsc' couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)
	apt-get source "${PACKAGE}"
	# FIXME: how to deduce path from $PACKAGE ?
	# or dgit or debcheckout?
    ;;
    build)
    	# FIXME: unless using version forced by user, bump version
	case "${BUILD_TYPE}"
	in
	    package)
	        echo "Building from package sources '${PACKAGE}'..."
                $0 get-source
		cd $PACKAGE-*
       	    ;;
            source_dir)
                echo "Building from source directory '${SOURCE_DIR}'..."
		cd "${SOURCE_DIR}"
	    ;;
            *)
	    	echo "Invalid build type: '${BUILD_TYPE}'!"
		exit 1
	    ;;
	esac
	echo "Install build dependencies..."
	$0 install-deps
	chown user ..
	chown -R user .
	ls -lha
	ls -lha ..
    	gosu user dpkg-buildpackage -us -uc
	gosu user sha256sum ../*.*
    ;;
    *)
    	echo "Unknown command: '${COMMAND}'." && exit 1
    ;;
esac
