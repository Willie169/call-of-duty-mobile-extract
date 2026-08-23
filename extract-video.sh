#!/usr/bin/env bash

# shellcheck disable=2001

msg="$0 [-h|--help] [-r|--rish] [-a|--adb] [-d|--dir working_dir] [-p|--path path] [-c|--clean] [-- adb_args]
-h|--help: Print this help message.
-r|--rish: Assume interactive ADB shell is available with rish.
-a|--adb (default): Assume ADB is connected.
adb_args: arguments that will be passed to rish or adb.
working_dir: working directory, current directory used if not provided.
path: path of the audio files you want. Default to /storage/emulated/0/Android/data/com.garena.game.codm/files/PufferQts/Vedios
-c|--clean: Delete all files except vedio files.
More information: https://github.com/Willie169/call-of-duty-mobile-extract"
path='/storage/emulated/0/Android/data/com.garena.game.codm/files/PufferQts/Vedios'
dir="$PWD"
rish=0
args=()
clean=0
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help)
      echo "$msg"
      shift
      exit 0
      ;;
    -r | --rish)
      rish=1
      shift
      ;;
    -a | --adb)
      rish=0
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
      path="$2"
      shift 2
      ;;
    -c | --clean)
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
mkdir -p "$dir"
if ! cd "$dir"; then
  echo "Error: can't enter working directory" >&2
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
[ "$clean" -eq 0 ] && exit 0
while IFS= read -r -d '' f; do
  case "${f,,}" in
    *.mp4)
      ;;
    *)
      rm -f "$f"
      ;;
  esac
done < <(find . -type f -print0)
find . -type d -empty -delete
