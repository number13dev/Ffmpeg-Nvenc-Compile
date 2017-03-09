#!/bin/bash

#This script will hopefully install ffmpeg with support for nvenc un ubuntu.
#Cross your fingers.
rm -rf ~/ffmpeg_sources
#install required things from apt
installLibs(){
echo "Installing prerequosites"
sudo apt-get update
sudo apt-get -y --force-yes install curl libssh-dev libssl-dev unzip cmake mercurial git autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev \
  libtheora-dev libtool libvorbis-dev pkg-config texi2html zlib1g-dev
}

compileLibNuma() {
echo "Compiling libnuma"
cd ~/ffmpeg_sources
   NUMA_LIB="numactl-2.0.11.tar.gz"
   NUMA_PATH=$(basename ${NUMA_LIB} .tar.gz)
wget -O ${NUMA_LIB} "ftp://oss.sgi.com/www/projects/libnuma/download/${NUMA_LIB}"   cd ${SOURCE_PREFIX}
tar xfzv ${NUMA_LIB}
cd ${NUMA_PATH}
./configure --prefix="$HOME/ffmpeg_build"
make
make install
}

compileLibX265(){
echo "Compiling libx265"
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" ../../source
PATH="$HOME/bin:$PATH" make
make install
make distclean
}

#Compile ffmpeg
compileFfmpeg(){
echo "Compiling ffmpeg"
cd ~/ffmpeg_sources
#wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
#tar xjvf ffmpeg-snapshot.tar.bz2
#cd ffmpeg
#git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg
    ffmpeg_version="snapshot"
    if [ ! -f  ffmpeg-${ffmpeg_version}.tar.bz2 ]; then
        wget http://ffmpeg.org/releases/ffmpeg-${ffmpeg_version}.tar.bz2
    fi
    tar xjf ffmpeg-${ffmpeg_version}.tar.bz2
#    cd ffmpeg-${ffmpeg_version}
    cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --pkg-config-flags="--static" \
  --prefix="$HOME/ffmpeg_build" \
  --extra-cflags="-I$HOME/ffmpeg_build/include -march=skylake" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib -march=skylake" \
  --bindir="/ffmpeg" \
  --enable-static \
  --enable-gpl \
  --enable-libx265 \
  --disable-yasm \
  --disable-ffplay --disable-ffprobe --disable-ffserver \
  --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages \
  --enable-pthreads \
  --enable-nonfree
PATH="$HOME/bin:$PATH" make -j 8
make install
make distclean
hash -r
}

#The process
cd ~
mkdir ffmpeg_sources
installLibs
compileLibNuma
compileLibX265
compileFfmpeg
echo "Complete!"
