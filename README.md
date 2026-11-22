# FFmpeg Container

A minimal, LGPL-licensed FFmpeg build packaged as a Docker image.

## Goals

- **Small and focused**: a slim Debian image containing only the `ffmpeg` binary, without compilers or build tools.
- **Built from source**: FFmpeg is compiled from an official release tag, so each image maps to an exact upstream version.
- **Redistributable**: only FFmpeg's built-in components are enabled, keeping the binary under the LGPL v2.1+ and free of GPL or non-free parts.
- **Reusable build layer**: designed to be copied into other images, for example [whisper-asr-webservice](https://github.com/ahmetoner/whisper-asr-webservice).

## Usage

Run FFmpeg on files in the current directory:

```shell
docker run --rm -v "$(pwd):/workspace" onerahmet/ffmpeg:n9.1 -i input.mp4 -vn -c:a flac output.flac
```

Use it as a build layer in another image:

```dockerfile
FROM onerahmet/ffmpeg:n9.1 AS ffmpeg

FROM debian:bookworm-slim
COPY --from=ffmpeg /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/share/doc/ffmpeg /usr/local/share/doc/ffmpeg
```

The binary is built on Debian bookworm and runs on any glibc-based image with glibc 2.35 or newer.

## What Is Included

| | |
|---|---|
| Platforms | `linux/amd64`, `linux/arm64` |
| Programs | `ffmpeg` (no `ffprobe` or `ffplay`) |
| Input/output | Local files and pipes; network protocols are disabled |
| Audio decoding | AAC, MP3, FLAC, Opus, Vorbis, ALAC, PCM |
| Video decoding | H.264, HEVC, VP9, MPEG-4, MJPEG |
| Encoding | AAC, FLAC, MP2, PCM, MPEG-4, MJPEG, FFV1 |

External libraries such as libx264, libmp3lame or libdav1d are not included.

## Tags

Image tags follow FFmpeg release tags, for example `n9.1` or `n7.1`. `latest` points to the most recent release. Per-architecture tags such as `n9.1-amd64` and `n9.1-arm64` are also published; they are used to assemble the multi-platform tags.

## Building

```shell
docker build --build-arg FFMPEG_VERSION=n9.1 -t onerahmet/ffmpeg:n9.1 .
```

`FFMPEG_VERSION` is required and must be an [FFmpeg release tag](https://github.com/FFmpeg/FFmpeg/tags).

## Releasing

Pushing a git tag named after an FFmpeg release (for example `n9.1`) builds the image natively on amd64 and arm64 runners, publishes it to Docker Hub as that tag and `latest`, and then creates a GitHub release.

## License

The files in this repository are licensed under the MIT License, see [LICENCE](LICENCE).

The published image contains FFmpeg, licensed under the [LGPL v2.1 or later](https://www.ffmpeg.org/legal.html):

- FFmpeg is configured without `--enable-gpl` and `--enable-nonfree`. Enabling either, or adding external libraries, changes the license of the binary.
- The license text is included in the image at `/usr/local/share/doc/ffmpeg/`.
- The corresponding source code is the FFmpeg release tag matching the image tag, built with the configuration in this repository's [Dockerfile](Dockerfile).
- [NASM](https://www.nasm.us/) (BSD 2-Clause) is used to build FFmpeg and is not included in the image.

FFmpeg is a trademark of [Fabrice Bellard](http://bellard.org/), originator of the FFmpeg project.
