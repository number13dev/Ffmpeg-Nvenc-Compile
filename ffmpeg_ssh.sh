#!/bin/bash

#This script will hopefully install ffmpeg with support for nvenc un ubuntu.
#Cross your fingers.
rm -rf ~/ffmpeg_sources
#install required things from apt
installLibs(){
echo "Installing prerequosites"
sudo apt-get update
sudo apt-get -y --force-yes install curl unzip cmake mercurial git autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev \
  libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
  libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev
}

#Compile libssh
compileLibSSH(){
echo "Compiling LibSSH"
cd ~/ffmpeg_sources
wget https://red.libssh.org/attachments/download/195/libssh-0.7.3.tar.xz
tar xjvf libssh-0.7.3.tar.xz
cd libssh*
mkdir build
cd build
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../src
PATH="$HOME/bin:$PATH" make
make install
make distclean
}

#Compile libx264
compileLibX264(){
echo "Compiling libx264"
cd ~/ffmpeg_sources
wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
tar xjvf last_x264.tar.bz2
cd x264-snapshot*
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
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
  --enable-gpl \
  --enable-pthreads \
  --enable-libssh \
  --enable-libx264
  --enable-nonfree
PATH="$HOME/bin:$PATH" make -j
make install
make distclean
hash -r
}

#The process
cd ~
mkdir ffmpeg_sources
installLibs
compileLibX264
compileFfmpeg
echo "Complete!"