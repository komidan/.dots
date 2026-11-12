#!/usr/bin/env bash

set -e

TMPDIR="/tmp/dots_font"
FONTDIR="$HOME/.local/share/fonts"
if [[ $# -eq 0 ]]; then
    echo "[$0] usage: $(basename "$0") <url> [url...]"
    exit 1
fi

extract() {
    local archive="$1" dest="$2"
    case "$archive" in
        *.tar.gz|*.tgz) tar -xzf "$archive" -C "$dest" ;;
        *.tar.gz2)      tar -xjf "$archive" -C "$dest" ;;
        *.tar.xz)       tar -xJf "$archive" -C "$dest" ;;
        *.zip)          unzip -q "$archive" -d "$dest" ;;
        *.7z)           7z x "$archive" -o"$dest" >/dev/null ;;
        *) echo "[$0] unsupported format: $(basename "$archive")"; return 1;
    esac
}

install() {
    local url="$1"

    local fname
    fname=$(basename "$url")
    case "$fname" in
        *.tar.gz|*.tgz|*.tar.bz2|*.tar.xz|*.zip|.*7z) ;;
        *) echo "[$0] unrecognized archive format"; return 1 ;;
    esac

    rm -rf "$TMPDIR"
    mkdir -p "$TMPDIR"
    echo "[$0] created '$TMPDIR'"

    echo "[$0] downloading '$fname'"
    if ! curl -fsSL "$url" -o "$TMPDIR/$fname"; then
        echo "[$0] failed to download from '$url'"
        return 1
    fi

    echo "[$0] extracting '$fname'"
    if ! extract "$TMPDIR/$fname" "$TMPDIR"; then
        echo "[$0] failed to extract '$fname'"
        return 1
    fi

    local fonts
    fonts=$(find "$TMPDIR" -type f \( -name "*.ttf" -o -name "*.otf" \))

    if [[ -z "$fonts" ]]; then
        echo "[$0] no font files (.ttf/.otf) found, ignoring."
        return 1
    fi

    mkdir -p "$FONTDIR"
    local count=0
    while IFS= read -r font; do
        cp -n "$font" "$FONTDIR/"
        (( count++ ))
    done <<< "$fonts"

    echo "[$0] installed $count font(s) from '$fname'"
    if rm -rf "$TMPDIR"; then
        echo "[$0] deleted '$TMPDIR'"
    fi
}

failed=0

for url in "$@"; do
    install "$url" || (( failed++ ))
done

echo "[$0] refreshing font cache..."
fc-cache -r

if (( failed > 0 )); then
    echo "[$0] done. \($failed source\(s\) skipped\)"
else
    echo "[$0] done."
fi
