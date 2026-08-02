#!/bin/sh
# Copy the Terminess Powerline console fonts to /usr/share/consolefonts,
# renamed for console-setup with FONTFACE=PowerLine. Run with sudo.
#
# usage: install-psf.sh [FONTS_REPO] [DEST]
set -e
src=${1:-$HOME/code/fonts}
dest=${2:-/usr/share/consolefonts}
cd "$src/Terminus/PSF"
for f in ter-powerline-v*.psf.gz; do
    v=${f#ter-powerline-v}; v=${v%.psf.gz}            # 16n, 16b, 16v
    case $v in *b) w=Bold ;; *v) w=V ;; *) w= ;; esac  # weight
    case ${v%?} in                                    # height -> FONTSIZE
        14|16) s=${v%?} ;;
        12) s=12x6 ;; 18) s=18x10 ;; 20) s=20x10 ;; 22) s=22x11 ;;
        24) s=24x12 ;; 28) s=28x14 ;; 32) s=32x16 ;;
    esac
    cp -v "$f" "$dest/Uni2-PowerLine$w$s.psf.gz"
done
