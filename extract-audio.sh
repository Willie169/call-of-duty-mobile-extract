#!/usr/bin/env bash

# shellcheck disable=2001

msg="$0 [-h|--help] [-r|--rish] [-a|--adb] [-o|--original] [-m|--wem] [-w|--wav] [-f|--flac] [-d|--dir working_dir] [-- adb_args]
-h|--help: Print this help message.
-r|--rish: Assume interactive ADB shell is available with rish.
-a|--adb (default): Assume ADB is connected.
adb_args: arguments that will be passed to rish or adb.
-o|--original, -m|--wem, -w|--wav, -f|--flac: formats you want. You may supply multiple formats. Intemediate formats that are not wanted will be deleted automatically.
-o|--original: Only rish or ADB is needed.
-m|--wem: bnkextr is also needed.
-w|--wav: vgmstream is also needed.
-f|--flac: ffmpeg is also needed.
working_dir: working directory, current directory used if not provided"
path='/storage/emulated/0/Android/data/com.garena.game.codm/files/PufferQts/Audio/GeneratedSoundBanks'
dir="$PWD"
rish=0
args=()
original=0
wem=0
wav=0
flac=0
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
      original=2
      shift
      ;;
    -m | --wem)
      wem=2
      [ "$original" -eq 0 ] && original=1
      shift
      ;;
    -w | --wav)
      wav=2
      [ "$original" -eq 0 ] && original=1
      [ "$wem" -eq 0 ] && wem=1
      shift
      ;;
    -f | --flac)
      flac=2
      [ "$original" -eq 0 ] && original=1
      [ "$wem" -eq 0 ] && wem=1
      [ "$wav" -eq 0 ] && wav=1
      shift
      ;;
    -d | --dir)
      dir="$2"
      shift 2
      ;;
    --)
      shift
      args=("$@")
      break
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      echo "$msg" >&2
      exit 1
      ;;
  esac
done
mkdir -p "$dir"
if ! cd "$dir"; then
  echo "Error: can't enter working directory" >&2
fi
if [ "$original" -eq 0 ]; then
  echo 'Error: no format wanted' >&2
  echo "$msg" >&2
  exit 1
fi
if [ "$rish" -eq 0 ]; then
  adb "${args[@]}" pull "$path"
  if ! cd GeneratedSoundBanks; then
    echo 'Error: adb pull failed.' >&2
    exit 1
  fi
else
  command -v uuidgen >/dev/null 2>&1 || pkg install uuid-utils -y
  uuid=$(uuidgen)
  mkdir "/storage/emulated/0/$uuid"
  echo "cp -r /storage/emulated/0/Android/data/com.garena.game.codm/files/PufferQts/Audio/GeneratedSoundBanks /storage/emulated/0/$uuid/; exit" | rish
  cp -r "/storage/emulated/0/$uuid/GeneratedSoundBanks" .
  rm -r "/storage/emulated/0/$uuid"
  if ! cd GeneratedSoundBanks; then
    echo 'Error: Either rish copy or Termux copy failed.'
    exit 1
  fi
fi
shopt -s globstar
[ "$wem" -eq 0 ] && exit
for f in **/*.bnk; do
  test -f "$f" || continue
  bnkextr "$f"
  [ "$original" -eq 1 ] && rm "$f"
done
[ "$wav" -eq 0 ] && exit
for f in **/*.wem; do
  test -f "$f" || continue
  vgmstream -o "$(echo "$f" | sed 's/\.wem$/.wav/')" "$f"
  [ "$wem" -eq 1 ] && rm "$f"
done
[ "$flac" -eq 0 ] && exit
for f in **/*.wav; do
  test -f "$f" || continue
  ffmpeg -i "$f" -c:a flac "$(echo "$f" | sed 's/\.wav$/.flac/')"
  [ "$wav" -eq 1 ] && rm "$f"
done
