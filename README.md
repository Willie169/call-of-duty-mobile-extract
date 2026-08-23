# call-of-duty-mobile-extract

This project provides scripts that extract audio files from Call of Duty Mobile Android app.

## Common Prerequisites

- Call of Duty Mobile installed in user 0 (i.e., primary/personal profile) in Android with resources you want downloaded in game.
- Linux or Termux Bash shell. Other shells may and may not be supported. You may modify the scripts to adapt to your environment. Pull requests and issues are welcome.
- ADB shell to the Android device, either with `adb` (recommended) or using [Shizuku](https://github.com/thedjchi/Shizuku) `rish` with [Termux](https://github.com/termux/termux-app). If you are using Shizuku `rish` with Termux, put where `rish` locates to `$PATH` so that interactive ADB shell can be accessed with `rish` and grant Termux storage permission by running `termux-setup-storage`. Termux (`com.termux`) can be installed from [F-Droid](https://f-droid.org/packages/com.termux). Google Play version is not supported.

## Extact Audio

### Prerequisites

- [bnkextr](https://github.com/Willie169/bnkextr) unless you only want original files. Download binary in its release to get it.
- [vgmstream](https://github.com/vgmstream/vgmstream) unless you only want original files or `.wem` format. On Termux, you can get it by running `pkg install vgmstream -y`. On Linux, if it is not available from your package manager, you may use [Homebrew](https://brew.sh) to install it by running `brew install vgmstream`.
- [FFmpeg](https://ffmpeg.org) if you want `.flac` format. You can typically get it from your package manager.

### Usage

Execute
```
git clone https://github.com/Willie169/call-of-duty-mobile-extract.git
cd call-of-duty-mobile-extract
./extract-audio.sh -h
```
and read the help message printed.

### Other formats

You may use [FFmpeg](https://ffmpeg.org) to convert `.wav` files to other formats you want, such as `.flac`:
```
ffmpeg -i file.wav -c:a flac file.flac
```
and `.opus`:
```
ffmpeg -i file.wav -c:a libopus -b:a <bit_rate_in_bit/s_e.g._192k> file.opus
```
For `.opus`, if you encounter `Error parsing Opus packet header.` error, upgrade FFmpeg to version >=8.1. On Termux, the version has been new enough as of the time writing this. On Linux, you may use [Homebrew](https://brew.sh) to install a newer version by running `brew install ffmpeg` or `brew install ffmpeg-full` if the version from your package manager is too old. Refer to [FFmpeg issue 20954](https://code.ffmpeg.org/FFmpeg/FFmpeg/issues/20954) for more information.

## Extract Video

### Usage

Execute
```
git clone https://github.com/Willie169/call-of-duty-mobile-extract.git
cd call-of-duty-mobile-extract
./extract-vedio.sh -h
```
and read the help message printed.

## License

This project is licensed under [MPL 2.0 License](LICENSE.md).
