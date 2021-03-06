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

#Install nvidia SDK
installSDK(){
echo "Installing the nVidia NVENC SDK."
cd ~/ffmpeg_sources
mkdir SDK
cd SDK
wget https://raw.githubusercontent.com/Elrondo46/nvidia-sdk-manjaro/master/Video_Codec_SDK_7.1.9.zip -O sdk.zip
unzip sdk.zip
.cd nvidia_video_sdk_7.1.9
sudo cp Samples/common/inc/* /usr/include/
}

#Compile opus

compileOpus(){
echo "Compile opus"
cd ~/ffmpeg_sources
git clone git://git.opus-codec.org/opus.git
cd opus
./autogen.sh
./configure --enable-static --enable-shared
make
make install
ldconfig
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
curl http://sourceforge.mirrorservice.org/l/la/lame/lame/3.99/lame-3.99.5.tar.gz --retry 50 -O -L
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
wget http://downloads.xiph.org/releases/opus/opus-1.1.4.tar.gz
tar xzvf opus-1.1.4.tar.gz
cd opus-1.1.4
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
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libopus \
  --enable-libvpx \
  --enable-libx265 \
  --enable-libx264 \
  --enable-nvenc \
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
installSDK
compileYasm
compileOpus
compileLibX264
compileLibX265
compileLibfdkcc
compileLibMP3Lame
compileLibOpus
compileLibPvx
compileFfmpeg
echo "Complete!"
