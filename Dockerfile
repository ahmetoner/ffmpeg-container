FROM debian:bookworm-slim AS build

ARG FFMPEG_VERSION

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
    build-essential \
    git \
    pkg-config \
    nasm \
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

# The published image only contains the ffmpeg binary, without the build toolchain
FROM debian:bookworm-slim

ARG FFMPEG_VERSION

LABEL org.opencontainers.image.source="https://github.com/ahmetoner/ffmpeg-container" \
      org.opencontainers.image.version="${FFMPEG_VERSION}" \
      org.opencontainers.image.licenses="LGPL-2.1-or-later"

COPY --from=build /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
# FFmpeg is built without --enable-gpl and --enable-nonfree, so the LGPL v2.1+ applies to the binary
COPY --from=build /FFmpeg-${FFMPEG_VERSION}/LICENSE.md /FFmpeg-${FFMPEG_VERSION}/COPYING.LGPLv2.1 /usr/local/share/doc/ffmpeg/

WORKDIR /workspace

ENTRYPOINT ["ffmpeg"]
