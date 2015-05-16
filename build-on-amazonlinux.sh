#!/bin/bash

install_prefix=${install_prefix:-/opt/opencv}
branch=${branch:-2.4}
build_dir=${build_dir:-/tmp/opencv_build."$(date +%Y%m%d%H%M%S)".$$}

mkdir -p "$build_dir"
cd "$build_dir" || exit 1

git clone -b "$branch" https://github.com/Itseez/opencv.git opencv
(cd opencv && git pull)

rm -rf release
mkdir -p release
cd release

sudo yum -y install cmake gcc-c++ libjpeg-turbo-devel libpng-devel libtiff-devel openmpi-devel tbb-devel
cmake \
  -D BUILD_EXAMPLES=ON \
  -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX="$install_prefix" \
  -D WITH_1394=OFF \
  -D WITH_OPENMP=ON \
  -D WITH_TBB=ON \
  ../opencv

make && make && make install
