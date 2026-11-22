# FFmpeg Container

A lightweight Docker container for running FFmpeg commands.

This container provides a ready-to-use FFmpeg environment for video and audio processing. FFmpeg is compiled from source with only its built-in (native) codecs and copied into a slim Debian image, keeping the image small. It is also used as a build layer by [whisper-asr-webservice](https://github.com/ahmetoner/whisper-asr-webservice).

## Usage

Pull and run the container:

```shell
docker pull onerahmet/ffmpeg
docker run --rm -v "$(pwd):/workspace" onerahmet/ffmpeg -i input.mp4 output.mp4
```

The `-v "$(pwd):/workspace"` flag mounts your current directory to `/workspace` inside the container, allowing FFmpeg to access your local files.

### Example Commands

1. Convert video format:

```shell
docker run --rm -v "$(pwd):/workspace" onerahmet/ffmpeg -i input.mp4 output.mkv
```

2. Extract audio from video:

```shell
docker run --rm -v "$(pwd):/workspace" onerahmet/ffmpeg -i input.mp4 -vn -c:a flac output.flac
```

3. Compress video:

```shell
docker run --rm -v "$(pwd):/workspace" onerahmet/ffmpeg -i input.mp4 -c:v mpeg4 -q:v 5 -c:a aac output.mp4
```

4. Create video thumbnail:

```shell
docker run --rm -v "$(pwd):/workspace" onerahmet/ffmpeg -i input.mp4 -ss 00:00:01 -vframes 1 -q:v 2 thumbnail.jpg
```

## Building the Container

The container requires specifying an FFmpeg version during build:

```shell
docker build --build-arg FFMPEG_VERSION=n9.1 -t onerahmet/ffmpeg:n9.1 .
```

Available versions can be found in [FFmpeg's release tags](https://github.com/FFmpeg/FFmpeg/tags). For example:

- n9.1
- n7.1

Note: The `FFMPEG_VERSION` build argument is required. The build will fail if not provided.

## Features

- Minimal image: a slim Debian base with just the `ffmpeg` binary
- Built-in FFmpeg codecs only (e.g. AAC, FLAC, Opus, Vorbis, MP3 decoding, MPEG-4, MJPEG); external libraries such as libx264 or libmp3lame are not included
- Simple volume mounting for file access
- Supports all standard FFmpeg commands and options

## Notes

- All commands are run from the `/workspace` directory inside the container
- Input and output files must be accessible in the mounted volume
- Use absolute paths or paths relative to the mounted directory

## License

The files in this repository (Dockerfile, workflow, docs) are licensed under the MIT License - see the LICENCE file for details.

The published image contains an FFmpeg binary, which is licensed under the [LGPL v2.1 or later](https://www.ffmpeg.org/legal.html):

- FFmpeg is configured without `--enable-gpl` and `--enable-nonfree`, so no GPL or non-free parts are included. Enabling either, or adding external libraries such as libx264, changes the license of the binary.
- The license text is included in the image at `/usr/local/share/doc/ffmpeg/`.
- The corresponding source code is the FFmpeg release tag with the same name as the image tag (e.g. [n9.1](https://github.com/FFmpeg/FFmpeg/tree/n9.1)), built with the configuration in this repository's `Dockerfile`.
- The build uses [NASM](https://www.nasm.us/) (BSD 2-Clause) as an assembler; it is not included in the published image.

## Credits

This container packages [FFmpeg](https://ffmpeg.org/), a complete, cross-platform solution to record, convert and stream audio and video. FFmpeg is licensed under the [LGPL v2.1+ License](https://www.ffmpeg.org/legal.html).

FFmpeg is a trademark of [Fabrice Bellard](http://bellard.org/), originator of the FFmpeg project.
