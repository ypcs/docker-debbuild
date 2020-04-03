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

gosrcdir() {
    case "${BUILD_TYPE}"
    in
        package)
	    cd /usr/src/"${PACKAGE}"-*
	;;
        source_dir)
	    cd "${SOURCE_DIR}"
	;;
        *)
	    echo "Invalid build type: '${BUILD_TYPE}'!"
	    exit 1
    esac
}

case "${COMMAND}"
in
    collect-artifacts)
    	# FIXME: collect artifacts to /artifacts or something
	gosrcdir
	cd ..
	if [ -e "/artifacts/.directory-not-mounted" ]
	then
            echo "Found flag file, it seems that /artifacts isn't a volume. Skip copying artifacts."
	    exit 0
	fi
	cp *.deb *.dsc *.changes *.buildinfo *.xz *.gz *.bz2 /artifacts/
    ;;
    install-deps)
        echo "Installing build dependencies..."
	gosrcdir
	/usr/lib/docker-helpers/apt-setup
        mk-build-deps --build-dep --install --remove --tool "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y"
	/usr/lib/docker-helpers/apt-cleanup
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
	# or dgit or debcheckout?
	# FIXME: how to deduce path from $PACKAGE ?
    ;;
    build)
    	# FIXME: unless using version forced by user, bump version
	# FIXME: this should probably expect that src dir is already prepared, no need to get sources anymore...
	gosrcdir
	case "${BUILD_TYPE}"
	in
	    package)
	        echo "Building from package sources '${PACKAGE}'..."
                $0 get-source
       	    ;;
            source_dir)
                echo "Building from source directory '${SOURCE_DIR}'..."
	    ;;
            *)
	    	echo "Invalid build type: '${BUILD_TYPE}'!"
		exit 1
	    ;;
	esac
	chown user .. ../*
	chown -R user .
	ls -lha
	ls -lha ..
    	gosu user dpkg-buildpackage -us -uc
	find ../ -maxdepth 1 -type f -exec sha256sum "{}" \;
    ;;
    default)
	if [ -n "${PACKAGE}" ]
	then
            $0 get-source
	fi
	$0 install-deps
	$0 build
	$0 collect-artifacts
    ;;
    *)
    	echo "Unknown command: '${COMMAND}'." && exit 1
    ;;
esac
