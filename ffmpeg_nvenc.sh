#!/bin/bash

#This script will hopefully install ffmpeg with support for nvenc un ubuntu.
#Cross your fingers.
rm -rf ~/ffmpeg_sources
#install required things from apt
installLibs(){
echo "Installing prerequosites"
sudo apt-get update
sudo apt-get -y --force-yes install mercurial git autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev \
  libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
  libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev
}

#Install nvidia SDK
installSDK(){
echo "Installing the nVidia NVENC SDK."
cd ~/ffmpeg_sources
mkdir SDK
cd SDK
wget http://developer.download.nvidia.com/assets/cuda/files/nvidia_video_sdk_6.0.1.zip -O sdk.zip
unzip sdk.zip
cd nvidia_video_sdk_6.0.1
sudo cp Samples/common/inc/* /usr/include/
}

#Compile yasm
compileYasm(){
echo "Compiling yasm"
cd ~/ffmpeg_sources
wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
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

#Compile libx265
compileLibX265(){
echo "Compiling libx265"
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
PATH="$HOME/bin:$PATH" make
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
make
make install
make distclean
}

#Compile libmp3lame
compileLibMP3Lame(){
echo "Compiling libmp3lame"
#sudo apt-get install nasm
cd ~/ffmpeg_sources
wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared
make
make install
make distclean
}

#Compile libopus
compileLibOpus(){
echo "Compiling libopus"
cd ~/ffmpeg_sources
wget http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz
tar xzvf opus-1.1.tar.gz
cd opus-1.1
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
make distclean
}

#Compile libvpx
compileLibPvx(){
echo "Compiling libvpx"
cd ~/ffmpeg_sources
wget http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-1.6.1.tar.bz2
tar xjvf libvpx-1.6.1.tar.bz2
cd libvpx-1.6.1
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples
PATH="$HOME/bin:$PATH" make
make install
make clean
}

#Compile ffmpeg
compileFfmpeg(){
echo "Compiling ffmpeg"
cd ~/ffmpeg_sources
#wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
#tar xjvf ffmpeg-snapshot.tar.bz2
#cd ffmpeg
#git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg
    ffmpeg_version="3.1.3"
    if [ ! -f  ffmpeg-${ffmpeg_version}.tar.bz2 ]; then
        wget http://ffmpeg.org/releases/ffmpeg-${ffmpeg_version}.tar.bz2
    fi
    tar xjf ffmpeg-${ffmpeg_version}.tar.bz2
    wget http://sada5.sakura.ne.jp/PAX/patch/ffmpeg/ffmpeg-modified-v2-n3.1.3.patch
    cd ffmpeg-${ffmpeg_version}
    patch -p1 < ../ffmpeg-modified-v2-n3.1.3.patch
#cd ffmpeg
#git checkout -b c917cde9cc52ad1ca89926a617f847bc9861d5a0
#git clone https://github.com/Brainiarc7/ffmpeg_libnvenc ffmpeg00
#cd ffmpeg00
#chmod 777 *
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --pkg-config-flags="--static" \
  --prefix="$HOME/ffmpeg_build" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --bindir="$HOME/sbin" \
  --enable-filter=hwupload_cuda,scale_npp,format,interp_algo \
  --enable-gpl \
  --enable-pthreads \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx265 \
  --enable-libx264 \
  --enable-nonfree \
  --enable-libnvenc \
  --enable-nvenc \
  --enable-nonfree
PATH="$HOME/bin:$PATH" make -j8
make install
make distclean
hash -r
}

#The process
cd ~
mkdir ffmpeg_sources
installLibs
installSDK
compileYasm
compileLibX264
compileLibX265
compileLibfdkcc
compileLibMP3Lame
compileLibOpus
compileLibPvx
compileFfmpeg
echo "Complete!"
