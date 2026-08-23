#!/usr/bin/env bash

msg="$0 [-h|--help] [-r|--rish] [-a|--adb] [-o|--original] [-m|--wem] [-w|--wav] [-f|--flac] [-- adb_args]
-h|--help: Print this help message.
-r|--rish: Assume interactive ADB shell is available with rish.
-a|--adb: Assume ADB is connected. (default)
adb_args: arguments that will be passed to rish or adb.
-o|--original, -m|--wem, -w|--wav, -f|--flac: formats you want. You may supply multiple formats. Intemediate formats that are not wanted will be deleted automatically.
-o|--original: Only rish or ADB is needed.
-m|--wem: bnkextr is also needed.
-w|--wav: vgmstream is also needed.
-f|--flac: ffmpeg is also needed."
path='/storage/emulated/0/Android/data/com.garena.game.codm/files/PufferQts/Audio/GeneratedSoundBanks'
rish=0
args=()
formats=()
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help)
      echo "$msg"
      shift
      ;;
    -r | --rish)
      rish=1
      shift
      ;;
    -a | --adb)
      rish=0
      shift
      ;;
    -o | --original)
      formats+=('bnk')
      shift
      ;;
    -m | --wem)
      formats+=('wem')
      shift
      ;;
    -w | --wav)
      formats+=('wav')
      shift
      ;;
    -f | --flac)
      formats+=('flac')
      shift
      ;;
    --)
      shift
      args="$@"
      break
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      echo "$msg" >&2
      exit 1
      ;;
  esac
done
if [ "${#formats[@]}" -eq 0 ]; then
  echo 'Error: no format wanted' >&2
  echo "$msg" >&2
  exit 1
fi
if [ "$rish" -eq 0 ]; then
  adb "${args[@]}" pull "$path"
else
  command -v uuidgen >/dev/null 2>&1 || pkg install uuid-utils -y
  uuid=$(uuidgen)
  mkdir "/storage/emulated/0/$uuid"
  echo "cp -r /storage/emulated/0/Android/data/com.garena.game.codm/files/PufferQts/Audio/GeneratedSoundBanks /storage/emulated/0/$uuid/ && exit" | rish
  cp -r "/storage/emulated/0/$uuid/GeneratedSoundBanks" .
  rm -r "/storage/emulated/0/$uuid"
fi

