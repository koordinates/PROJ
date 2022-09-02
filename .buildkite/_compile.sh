#!/bin/bash
# set -eu

DEB_VER=$1

source /etc/lsb-release

apt-get update -y
apt-get install -y --no-install-recommends \
    cmake file \
    libcurl4-openssl-dev \
    libsqlite3-dev \
    libtiff-dev \
    pkg-config \
    pkg-kde-tools \
    sharutils \
    sqlite3 \
    xz-utils

if [ "$DISTRIB_CODENAME" == "bionic" ]; then
    apt-get install -y --no-install-recommends gcc-8 g++-8

    export CC=gcc-8
    export CXX=g++-8
fi

export CXXFLAGS=-O2

mkdir /tmp/build
cd /tmp/build

# configure
cmake /src \
    -DWITH_TESTS=NO \
    -DCPACK_DEBIAN_PACKAGE_MAINTAINER=peter.wilkinson@koordinates.com \
    -DCPACK_DEBIAN_PACKAGE_SHLIBDEPS=ON \
    -DCPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS=ON \
    -DCPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS_POLICY='>=' \
    -DCPACK_DEBIAN_FILE_NAME=DEB-DEFAULT

# compile
make VERBOSE=1

# build deb
cpack -G DEB -R "${DEB_VER}"

cp -v proj_*.deb /builds/
