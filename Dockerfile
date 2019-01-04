# Use Debian as a base image
FROM debian:stable-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

#--------------------------------
# Update and install dependencies
#--------------------------------
RUN \
export MAKEFLAGS="-j4" && \
apt-get update && \
apt-get install -y \
  curl \
  autoconf \
  automake \
  build-essential \
  libass-dev \
  libfreetype6-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  pkg-config \
  texinfo \
  zlib1g-dev \
  git-core \
  cmake \
  mercurial \
  libnuma-dev \
  yasm && \
#------------------
# Setup directories
#------------------
mkdir -p /input /output /ffmpeg/ffmpeg_sources /ffmpeg/bin && \
# Compile and install ffmpeg and ffprobe
# Download source
cd /ffmpeg/ffmpeg_sources && \
curl -O https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2 && \
tar xjf nasm-2.13.03.tar.bz2 && \
git clone --depth 1 https://github.com/xiph/opus.git && \
git clone --depth 1 https://git.videolan.org/git/x264 && \
hg clone https://bitbucket.org/multicoreware/x265 && \
curl -O https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
tar xjf ffmpeg-snapshot.tar.bz2 && \
#-------------
# Compile nasm
#-------------
cd /ffmpeg/ffmpeg_sources/nasm-2.13.03 && \
./autogen.sh && \
PATH="/ffmpeg/bin:$PATH" ./configure \
--prefix="/ffmpeg/ffmpeg_build" \
--bindir="/ffmpeg/bin" && \
PATH="/ffmpeg/bin:$PATH" make && \
make install && \
#----------------
# Compile libopus
#----------------
cd /ffmpeg/ffmpeg_sources/opus && \
./autogen.sh && \
./configure \
--prefix="/ffmpeg/ffmpeg_build" \
--disable-shared && \
PATH="/ffmpeg/bin:$PATH" make && \
make install && \
#-------------
# Compile x264
#-------------
cd /ffmpeg/ffmpeg_sources/x264 && \
PATH="/ffmpeg/bin:$PATH" \
PKG_CONFIG_PATH="/ffmpeg/ffmpeg_build/lib/pkgconfig" \
./configure --prefix="/ffmpeg/ffmpeg_build" \
--bindir="$HOME/bin" \
--enable-static \
--enable-pic && \
PATH="/ffmpeg/bin:$PATH" make && \
make install && \
#-------------
# Compile x265
#-------------
cd /ffmpeg/ffmpeg_sources/x265/build/linux && \
PATH="/ffmpeg/bin:$PATH" \
cmake -G "Unix Makefiles" \
-DCMAKE_INSTALL_PREFIX="/ffmpeg/ffmpeg_build" \
-DENABLE_SHARED=off \
# Enable 10 bit x265
-DHIGH_BIT_DEPTH=on \
../../source && \
PATH="/ffmpeg/bin:$PATH" make && \
make install && \
#---------------
# Compile ffmpeg
#---------------
cd /ffmpeg/ffmpeg_sources/ffmpeg && \
PATH="/ffmpeg/bin:$PATH" \
PKG_CONFIG_PATH="/ffmpeg/ffmpeg_build/lib/pkgconfig" \
./configure \
--pkg-config-flags="--static" \
--prefix="/ffmpeg/ffmpeg_build" \
--extra-cflags="-I/ffmpeg/ffmpeg_build/include -static" \
--extra-ldflags="-L/ffmpeg/ffmpeg_build/lib -static" \
--extra-libs="-lpthread -lm" \
--bindir="/ffmpeg/bin" \
--enable-static \
--disable-shared \
--disable-debug \
--disable-doc \
--disable-ffplay \
--enable-ffprobe \
--enable-gpl \
--enable-libfreetype \
--enable-libopus \
--enable-libx264 \
--enable-libx265 && \
PATH="/ffmpeg/bin:$PATH" make && \
make install && \
hash -r && \
#-----------------------------------------
# Copy ffmpeg and ffprobe to app directory
#-----------------------------------------
cp /ffmpeg/bin/ff* /app/ && \
#----------------------------------------------------
# Clean up directories and packages after compilation
#----------------------------------------------------
rm -rf /ffmpeg && \
apt-get remove -y \
  autoconf \
  automake \
  build-essential \
  libass-dev \
  libfreetype6-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  pkg-config \
  texinfo \
  zlib1g-dev \
  git-core \
  cmake \
  mercurial \
  libnuma-dev \
  yasm && \
apt-get -y autoremove && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*
#---------------------------------------
# Run ffmpeg when the container launches
#---------------------------------------
CMD ["/app/ffmpeg"]
