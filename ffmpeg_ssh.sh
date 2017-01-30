#!/bin/bash

#This script will hopefully install ffmpeg with support for nvenc un ubuntu.
#Cross your fingers.
rm -rf ~/ffmpeg_sources
#install required things from apt
installLibs(){
echo "Installing prerequosites"
sudo apt-get update
sudo apt-get -y --force-yes install curl unzip cmake mercurial git autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev \
  libtheora-dev libtool libvorbis-dev pkg-config texi2html zlib1g-dev
}





Compile LibSSL
compileLibSSL(){
echo "Compiling LibSSL"
cd ~/ffmpeg_sources
wget https://openssl.org/source/openssl-1.0.2k.tar.gz
tar xzvf openssl-1.0.2k.tar.gz
cd openssl-1.0.2k
./Configure gcc --openssldir="$HOME/etc/ssl" --libdir="$HOME/lib/ssl" no-shared
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
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DOPENSSL_LIBRARIES="$HOME/lib/ssl" -DWITH_STATIC_LIB=on ..
PATH="$HOME/bin:$PATH" make -j
make install
make distclean
}

#Compile yasm
#compileYasm(){
#echo "Compiling yasm"
#cd ~/ffmpeg_sources
#wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
#tar xzvf yasm-1.3.0.tar.gz
#cd yasm-1.3.0
#./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
#make
#make install
#make distclean
#}

#Compile libx264
#compileLibX264(){
#echo "Compiling libx264"
#cd ~/ffmpeg_sources
#wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
#tar xjvf last_x264.tar.bz2
#cd x264-snapshot*
#PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --disable-shared
#PATH="$HOME/bin:$PATH" make
#make install
#make distclean
#}

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
  --enable-libssh \
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
compileLibSSL
compileLibSSH
#compileYasm
#compileLibX264
compileFfmpeg
echo "Complete!"
