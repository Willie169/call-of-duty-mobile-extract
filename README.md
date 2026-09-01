# call-of-duty-mobile-extract

This project provides scripts that extract resources from the following Android apps:
- Call of Duty / Call of Duty®: Mobile by Activision Publishing, Inc. (com.activision.callofduty.shooter)
- Call of Duty / Call of Duty®: Mobile - Garena by Garena Mobile Private (com.garena.game.codm)
- 콜 오브 듀티: 모바일 / Call of Duty Mobile (KR) by Level Infinite (com.tencent.tmgp.kr.codm)
- Call of Duty / Call Of Duty: Mobile VN by VNG GROUP JSC (com.vng.codmvn)
- 使命召唤手游 by 深圳市腾讯计算机系统有限公司 (com.tencent.tmgp.cod)

## Common Prerequisites

These are needed for all provided scripts.

- Call of Duty Mobile installed in user 0 (i.e., primary/personal profile) on Android with resources you want downloaded in game. You can install them by first install [Obtainium](https://github.com/ImranR98/Obtainium) and then add the following links to it:
    * [Call of Duty / Call of Duty®: Mobile by Activision Publishing, Inc. (com.activision.callofduty.shooter)](https://apkpure.com/call-of-duty-mobile-game/com.activision.callofduty.shooter)
    * [Call of Duty / Call of Duty®: Mobile - Garena by Garena Mobile Private (com.garena.game.codm)](https://apkpure.com/call-of-duty-mobile-garena-app/com.garena.game.codm)
    * [콜 오브 듀티: 모바일 / Call of Duty Mobile (KR) by Level Infinite (com.tencent.tmgp.kr.codm)](https://apkpure.com/call-of-duty-mobile-kr/com.tencent.tmgp.kr.codm)
    * [Call of Duty / Call Of Duty: Mobile VN by VNG GROUP JSC (com.vng.codmvn)](https://apkpure.com/call-of-duty-mobile-vn-app/com.vng.codmvn)
    * [使命召唤手游 by 深圳市腾讯计算机系统有限公司 (com.tencent.tmgp.cod)](https://sj.qq.com/appdetail/com.tencent.tmgp.cod)
- Linux or Termux Bash shell. Other shells may and may not be supported. You may modify the scripts to adapt to your environment. Pull requests and issues are welcome.
- ADB shell to the Android device, either with `adb` (recommended) or using [Shizuku](https://github.com/thedjchi/Shizuku) `rish` with [Termux](https://github.com/termux/termux-app). If you are using Shizuku `rish` with Termux, put where `rish` locates to `$PATH` so that interactive ADB shell can be accessed with `rish` and grant Termux storage permission by running `termux-setup-storage`. Termux (`com.termux`) can be installed from [F-Droid](https://f-droid.org/packages/com.termux). Google Play version is not supported.

## Extact Audio

### Prerequisites

- [bnkextr](https://github.com/Willie169/bnkextr) unless you only want original files. Download binary in its release to get it.
- [vgmstream](https://github.com/vgmstream/vgmstream) unless you only want original files or `.wem` format. On Termux, you can get it by running `pkg install vgmstream -y`. On Linux, if it is not available from your package manager, you may use [Homebrew](https://brew.sh) to install it by running `brew install vgmstream`.
- [FFmpeg](https://ffmpeg.org) if you want `.flac` format, which is lossless and smaller than `.wav` format in size. You can typically get it from your package manager.

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
./extract-video.sh -h
```
and read the help message printed.

## License

This project is licensed under [MPL 2.0 License](LICENSE.md).
