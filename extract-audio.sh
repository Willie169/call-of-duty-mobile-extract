#!/usr/bin/env bash

# shellcheck disable=2001

msg="$0 [-h|--help] [-g|--garena] [-k|--korea] [-v|--vietnam] [-c|--china] [-r|--rish] [-a|--adb] [-d|--dir working_dir] [-p|--path path] [-l|--clean] [-- adb_args]
-h|--help: Print this help message.
-g|--garena, -k|--korea, -v|--vietnam, -c|--china: Set the package name in the default path of the audio files. The default path is /storage/emulated/0/Android/data/<pkg>/files/PufferQts/Audio. If none of them is used, <pkg> is com.activision.callofduty.shooter. If -g|--garena is used, <pkg> is com.garena.game.codm. If -k|--korea is used, <pkg> is com.tencent.tmgp.kr.codm. If -v|--vietenam is used, <pkg> is com.vng.codmvn. If -c|--china is used, <pkg> is com.tencent.tmgp.cod. The path can be overriden by -p|--path path.
-r|--rish: Assume interactive ADB shell is available with rish.
-a|--adb (default): Assume ADB is connected.
adb_args: arguments that will be passed to rish or adb.
-o|--original, -m|--wem, -w|--wav, -f|--flac: formats you want. You may supply multiple formats. Intermediate formats that are not wanted will be deleted automatically.
-o|--original: Only rish or ADB is needed.
-m|--wem: bnkextr is also needed.
-w|--wav: vgmstream is also needed.
-f|--flac: ffmpeg is also needed.
working_dir: working directory, current directory used if not provided.
path: custom path of the audio files.
-l|--clean: Delete all files except audio files.
More information: https://github.com/Willie169/call-of-duty-mobile-extract"
cpath=''
path='/storage/emulated/0/Android/data/com.activision.callofduty.shooter/files/PufferQts/Audio'
dir="$PWD"
rish=0
args=()
original=0
wem=0
wav=0
flac=0
clean=0
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help)
      echo "$msg"
      shift
      exit 0
      ;;
    -g | --garena)
      path='/storage/emulated/0/Android/data/com.garena.game.codm/files/PufferQts/Audio'
      shift
      ;;
    -k | --korea)
      path='/storage/emulated/0/Android/data/com.tencent.tmgp.kr.codm/files/PufferQts/Audio'
      shift
      ;;
    -v | --vietnam)
      path='/storage/emulated/0/Android/data/com.vng.codmvn/files/PufferQts/Audio'
      shift
      ;;
    -c | --china)
      path='/storage/emulated/0/Android/data/com.tencent.tmgp.cod/files/PufferQts/Audio'
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
      if [ -z "$2" ]; then
        echo "Error: -d|--dir requires an argument" >&2
        exit 1
      fi
      dir="$2"
      shift 2
      ;;
    -p | --path)
      if [ -z "$2" ]; then
        echo "Error: -p|--path requires an argument" >&2
        exit 1
      fi
      cpath="$2"
      shift 2
      ;;
    -l | --clean)
      clean=1
      shift
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
[ -n "$cpath" ] && path="$cpath"
mkdir -p "$dir"
if ! cd "$dir"; then
  echo "Error: can't enter working directory" >&2
  exit 1
fi
if [ "$original" -eq 0 ]; then
  echo 'Error: no format wanted' >&2
  echo "$msg" >&2
  exit 1
fi
if [ "$rish" -eq 0 ]; then
  if ! { adb "${args[@]}" pull "$path" && cd "$(basename "$path")"; }; then
    echo 'Error: adb pull failed' >&2
    exit 1
  fi
else
  if ! { command -v uuidgen >/dev/null 2>&1 || pkg install uuid-utils -y; }; then
    echo "Error: uuidgen not available and can't be installed" >&2
    exit 1
  fi
  uuid=$(uuidgen)
  if ! mkdir "/storage/emulated/0/$uuid"; then
    echo "Error: can't create /storage/emulated/0/$uuid" >&2
    exit 1
  fi
  echo "cp -r $path /storage/emulated/0/$uuid/; exit" | rish "${args[@]}"
  cp -r "/storage/emulated/0/$uuid/$(basename "$path")" .
  rm -r "/storage/emulated/0/$uuid"
  if ! cd "$(basename "$path")"; then
    echo 'Error: Either rish copy or Termux copy failed'
    exit 1
  fi
fi
shopt -s globstar nullglob
[ "$wem" -eq 0 ] && exit 0
for f in **/*.bnk; do
  if ! command -v bnkextr >/dev/null 2>&1; then
    echo 'Error: bnkextr not available' >&2
    exit 1
  fi
  bnkextr "$f"
  [ "$original" -eq 1 ] && rm "$f"
done
[ "$wav" -eq 0 ] && exit 0
for f in **/*.wem; do
  if ! command -v vgmstream-cli >/dev/null 2>&1; then
    echo 'Error: vgmstream-cli not available' >&2
    exit 1
  fi
  rm -f "$(echo "$f" | sed 's/\.wem$/.wav/')"
  vgmstream-cli -o "$(echo "$f" | sed 's/\.wem$/.wav/')" "$f"
  [ "$wem" -eq 1 ] && rm "$f"
done
[ "$flac" -eq 0 ] && exit 0
for f in **/*.wav; do
  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo 'Error: ffmpeg not available' >&2
    exit 1
  fi
  rm -f "$(echo "$f" | sed 's/\.wav$/.flac/')"
  ffmpeg -i "$f" -c:a flac "$(echo "$f" | sed 's/\.wav$/.flac/')"
  [ "$wav" -eq 1 ] && rm "$f"
done
[ "$clean" -eq 0 ] && exit 0
while IFS= read -r -d '' f; do
  case "${f,,}" in
    *.bnk | *.wem | *.wav | *.flac)
      ;;
    *)
      rm -f "$f"
      ;;
  esac
done < <(find . -type f -print0)
find . -type d -empty -delete
