#!/bin/bash

install_prefix=${install_prefix:-/opt/opencv}
branch=${branch:-2.4}
build_dir=${build_dir:-/tmp/opencv_build."$(date +%Y%m%d%H%M%S)".$$}
source_dir="${source_dir:-$build_dir/opencv-$branch}"
cpu_count=$(egrep -c '^processor\s*:' /proc/cpuinfo)
cpu_count=$((1<$cpu_count?$cpu_count:1))

packages=(git cmake gcc-c++ libjpeg-turbo-devel libpng-devel libtiff-devel openmpi-devel tbb-devel)
if ! rpm -q "${packages[@]}" >/dev/null 2>&1; then
  sudo yum -y install "${packages[@]}"
fi

mkdir -p "$build_dir" && cd "$build_dir" || exit 1

git clone -b "$branch" https://github.com/Itseez/opencv.git "$source_dir"
( cd "$source_dir" && git checkout "$branch" && git pull )
rm -rf release && mkdir -p release && cd release || exit 1
cmake \
  -D BUILD_EXAMPLES=ON \
  -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX="$install_prefix" \
  -D WITH_1394=OFF \
  -D WITH_OPENMP=ON \
  -D WITH_TBB=ON \
  $source_dir

make -j $cpu_count || exit 1
if [[ -w "$install_prefix" ]]; then
  make install
else
  sudo make install
fi

# ユーザ単位なら環境変数 LD_LIBRARY_PATH に追加して使えばよいが、
# システム全体で共有ライブラリのパスが通るようにする。
echo "$install_prefix/lib" | sudo tee /etc/ld.so.conf.d/opencv.conf >/dev/null
sudo ldconfig

# pkg-configでコンパイルオプションが取得できるようpkgconfigへのパスを通す。
echo 'export PKG_CONFIG_PATH="${PKG_CONFIG_PATH:+$PKG_CONFIG_PATH:}_PREFIX_/lib/pkgconfig"' |
ruby -e 'STDIN.each{|s|puts s.gsub(ARGV[0],ARGV[1])}' _PREFIX_ "$install_prefix" |
sudo tee /etc/profile.d/opencv.sh >/dev/null
