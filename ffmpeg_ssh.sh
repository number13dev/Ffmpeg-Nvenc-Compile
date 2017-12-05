#!/bin/bash

#This script will hopefully install ffmpeg with support for nvenc un ubuntu.
#Cross your fingers.
rm -rf ~/ffmpeg_sources
#install required things from apt
installLibs(){
echo "Installing prerequosites"
sudo apt-get update
sudo apt-get -y --force-yes install curl libssh-dev libssl-dev unzip cmake mercurial git autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev \
  libtheora-dev libtool libvorbis-dev pkg-config texi2html zlib1g-dev yasm nasm
}

compileNasm(){
cd ~/ffmpeg_sources
wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-2.13.01.tar.bz2
tar xjvf nasm-2.13.01.tar.bz2
cd nasm-2.13.01
./autogen.sh
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make -j 16
make install
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

compileLibX264(){
echo "Compiling libx264"
cd ~/ffmpeg_sources
wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
tar xjvf last_x264.tar.bz2
cd x264-snapshot*
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
PATH="$HOME/bin:$PATH" make -j 16
make install
make distclean
}

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

installSDK(){
echo "Installing the nVidia NVENC SDK."
cd ~/ffmpeg_sources
mkdir SDK
cd SDK
wget https://raw.githubusercontent.com/Elrondo46/nvidia-sdk-manjaro/master/Video_Codec_SDK_7.1.9.zip -O sdk.zip
unzip sdk.zip
cd Video_Codec_SDK_7.1.9
sudo cp Samples/common/inc/* /usr/include/
}


Compile LibSSL
compileLibSSL(){
echo "Compiling LibSSL"
cd ~/ffmpeg_sources
wget https://openssl.org/source/openssl-1.0.2k.tar.gz
tar xzvf openssl-1.0.2k.tar.gz
cd openssl-1.0.2k
./Configure gcc -fPIC --openssldir="$HOME/etc/ssl" --libdir="lib" shared
make -j
make install
make distclean
}

Compile libssh
compileLibSSH(){
echo "Compiling LibSSH"
cd ~/ffmpeg_sources
wget https://red.libssh.org/attachments/download/195/libssh-0.7.3.tar.xz
tar xf libssh-0.7.3.tar.xz
cd libssh*
mkdir build
cd build
pwd
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DOPENSSL_ROOT_DIR="/root/etc/ssl" -DOPENSSL_LIBRARIES="/root/etc/ssl/lib" -DOPENSSL_INCLUDE_DIR="/root/etc/ssl/include" -DWITH_STATIC_LIB=on ..
PATH="$HOME/bin:$PATH" make -j
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
    ffmpeg_version="3.1.9"
    if [ ! -f  ffmpeg-${ffmpeg_version}.tar.bz2 ]; then
        wget http://ffmpeg.org/releases/ffmpeg-${ffmpeg_version}.tar.bz2
    fi
    tar xjf ffmpeg-${ffmpeg_version}.tar.bz2
    cd ffmpeg-${ffmpeg_version}
    #cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --pkg-config-flags="--static" \
  --prefix="$HOME/ffmpeg_build" \
  --extra-cflags="-I$HOME/ffmpeg_build/include -march=skylake" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib -march=skylake" \
  --bindir="/ffmpeg" \
  --enable-static \
  --enable-gpl \
  --enable-libssh \
  --enable-libfdk-aac \
  --enable-libx265 \
  --enable-libx264 \
  --enable-nvenc \
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
compileLibX264
compileLibfdkcc
installSDK
compileLibX265
compileFfmpeg
echo "Complete!"
