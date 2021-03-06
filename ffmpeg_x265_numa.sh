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
wget -O ${NUMA_LIB} "ftp://oss.sgi.com/www/projects/libnuma/download/${NUMA_LIB}"
tar xfzv ${NUMA_LIB}
cd ${NUMA_PATH}
make clean
./configure
make -j 16
make install
}

compileYasm(){
echo "Compiling yasm"
cd ~/ffmpeg_sources
wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make -j 16
make install
make distclean
}

#Compile libfdk-acc
compileLibfdkcc(){
echo "Compiling libfdk-cc"
#sudo apt-get install unzip
cd ~/ffmpeg_sources
git clone https://github.com/mstorsjo/fdk-aac.git
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make -j 16
make install
make distclean
}

compileLibX265version(){
echo "Compiling libx265"
X265VERSION="1.9"
cd ~/ffmpeg_sources
wget https://bitbucket.org/multicoreware/x265/downloads/x265_${X265VERSION}.tar.gz
tar xzvf x265_${X265VERSION}.tar.gz
cd x265_${X265VERSION}
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ./source
PATH="$HOME/bin:$PATH" make -j 16
make install
make distclean
}

compileLibX265(){
echo "Compiling libx265"
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
PATH="$HOME/bin:$PATH" make -j 16
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
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --bindir="/ffmpeg" \
  --enable-static \
  --enable-gpl \
  --enable-libx265 \
  --enable-libfdk-aac \
  --enable-pthreads \
  --disable-ffplay --disable-ffprobe --disable-ffserver \
  --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages \
  --enable-nonfree
PATH="$HOME/bin:$PATH" make -j 16
make install
make distclean
hash -r
}

#The process
cd ~
mkdir ffmpeg_sources
installLibs
compileLibNuma
compileYasm
compileLibfdkcc
compileLibX265version
compileFfmpeg
echo "Complete!"
