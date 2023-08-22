#!/bin/bash

# Compile and install ffmpeg.
# Environment setup and packages dependencies are handled by the Dockerfile.

#----------------
# Download source
#----------------
cd /ffmpeg/ffmpeg_sources || exit
git clone https://github.com/sekrit-twc/zimg.git
git clone --branch v2.3.1 https://github.com/Netflix/vmaf.git
git clone --depth 1 https://github.com/xiph/opus.git
git clone --depth 1 https://code.videolan.org/videolan/x264.git
git clone https://github.com/videolan/x265.git
git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git
git clone https://aomedia.googlesource.com/aom
git clone https://github.com/FFmpeg/FFmpeg ffmpeg

#-------------------
# Compile z.lib/zimg
#-------------------
cd /ffmpeg/ffmpeg_sources/zimg || exit
./autogen.sh
./configure
make -j "$(nproc)"
make install

#----------------
# Compile libvmaf
#----------------
cd /ffmpeg/ffmpeg_sources/vmaf/libvmaf || exit
meson build --buildtype release
ninja -vC build
ninja -vC build install
mkdir -p /usr/local/share/model/
cp -r /ffmpeg/ffmpeg_sources/vmaf/model/* /usr/local/share/model/

#----------------
# Compile libopus
#----------------
cd /ffmpeg/ffmpeg_sources/opus || exit
./autogen.sh
./configure
make -j "$(nproc)"
make install

#------------------
# Compile libsvtav1
#------------------
cd /ffmpeg/ffmpeg_sources/SVT-AV1/Build || exit
cmake .. -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
make -j "$(nproc)"
make install

#----------------
# Compile libx264
#----------------
cd /ffmpeg/ffmpeg_sources/x264 || exit
./configure \
  --enable-static \
  --enable-pic
make -j "$(nproc)"
make install

#----------------
# Compile libx265
#----------------
cd /ffmpeg/ffmpeg_sources/x265/build/linux || exit
cmake -G "Unix Makefiles" \
  -DHIGH_BIT_DEPTH=on \
  -DENABLE_CLI=OFF \
  ../../source
make install
make clean

#---------------
# Compile libaom
#---------------
cd /ffmpeg/ffmpeg_sources/aom || exit
mkdir -p ../aom_build
cd ../aom_build || exit
cmake /ffmpeg/ffmpeg_sources/aom -DBUILD_SHARED_LIBS=1
make -j "$(nproc)"
make install

#---------------
# Compile ffmpeg
#---------------
cd /ffmpeg/ffmpeg_sources/ffmpeg || exit
./configure \
  --disable-static \
  --enable-shared \
  --disable-debug \
  --disable-doc \
  --disable-ffplay \
  --enable-ffprobe \
  --enable-gpl \
  --enable-libfreetype \
  --enable-version3 \
  --enable-libvmaf \
  --enable-libzimg \
  --enable-libopus \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libsvtav1 \
  --enable-libaom
make -j "$(nproc)"
make install
hash -r
