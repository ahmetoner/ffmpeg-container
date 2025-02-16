FROM debian:bookworm-slim

ARG FFMPEG_VERSION

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq install --no-install-recommends \
    build-essential \
    git \
    pkg-config \
    yasm \
    ca-certificates \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/FFmpeg/FFmpeg.git --depth 1 --branch ${FFMPEG_VERSION} --single-branch /FFmpeg-${FFMPEG_VERSION}

WORKDIR /FFmpeg-${FFMPEG_VERSION}

RUN ./configure \
      --prefix="/usr/local" \
      --pkg-config-flags="--static" \
      --extra-cflags="-I/usr/local/include" \
      --extra-ldflags="-L/usr/local/lib" \
      --extra-libs="-lpthread -lm" \
      --ld="g++" \
      --disable-doc \
      --disable-htmlpages \
      --disable-podpages \
      --disable-txtpages \
      --disable-network \
      --disable-autodetect \
      --disable-hwaccels \
      --disable-ffprobe \
      --disable-ffplay \
      --enable-filter=copy \
      --enable-protocol=file \
      --enable-small && \
    make -j$(nproc) && \
    make install && \
    hash -r

ENTRYPOINT ["ffmpeg"]
