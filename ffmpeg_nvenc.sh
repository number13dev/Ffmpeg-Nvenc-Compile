#!/bin/bash

#This script will hopefully install ffmpeg with support for nvenc un ubuntu.
#Cross your fingers.
rm -rf ~/ffmpeg_sources
#install required things from apt
installLibs(){
echo "Installing prerequosites"
sudo apt-get update
sudo apt-get -y --force-yes install curl unzip cmake mercurial git autoconf automake build-essential libass-dev libfreetype6-dev libgpac-dev \
  libsdl1.2-dev libtool libva-dev libvdpau-dev libxcb1-dev libxcb-shm0-dev \
  libxcb-xfixes0-dev pkg-config texi2html zlib1g-dev yasm
}

#Install nvidia SDK
installSDK(){
echo "Installing the nVidia NVENC SDK."
cd ~/ffmpeg_sources
mkdir SDK
cd SDK
wget https://raw.githubusercontent.com/Elrondo46/nvidia-sdk-manjaro/master/Video_Codec_SDK_7.1.9 -O sdk.zip
unzip sdk.zip
cd nvidia_video_sdk_7.1.9
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
make -j 16
make install
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
    cd ffmpeg-${ffmpeg_version}
#    cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --pkg-config-flags="--static" \
  --prefix="$HOME/ffmpeg_build" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --bindir="/ffmpeg" \
  --enable-static \
  --enable-gpl \
  --enable-pthreads \
  --enable-libfdk-aac \
  --enable-nvenc \
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
installSDK
#compileYasm
compileLibfdkcc
compileFfmpeg
echo "Complete!"
