# ffmpeg-git

Available on Docker Hub at https://hub.docker.com/r/five82/ffmpeg-git/

```docker pull five82/ffmpeg-git```

FFmpeg container compiled with the following configuration:

```--disable-static --enable-shared --disable-debug --disable-doc --disable-ffplay --enable-ffprobe --enable-gpl --enable-libfreetype --enable-version3 --enable-libvmaf --enable-libzimg --enable-libopus --enable-libx264 --enable-libx265 --enable-libsvthevc --enable-libsvtvp9```

The script will build ffmpeg and ffprobe binaries. libx265 has 8,10 and 12 bit multilib support. libvmaf is intentionally versioned to maintain testing consistency.

Run ffmpeg commands using the example below:

    docker run \
    --name ffmpeg-git \
    -v <path/to/input/dir>:/input \
    -v <path/to/output/dir>:/output \
    five82/ffmpeg-git \
    ffmpeg -i /input/input.mkv -c:v libx264 -preset medium -crf 20 -c:a aac -b:a 384k /output/output.mkv

Versions:

ffmpeg     - git master HEAD
libvmaf    - 2.1.1
libzimg    - git master HEAD
libopus    - git master HEAD
libx264    - git master HEAD
libx265    - git master HEAD
libsvthevc - git master HEAD
libsvtvp9  - git master HEAD
