#!/bin/sh
# Installs this checkout's mods/reviewer into Herdr, replacing what is there,
# and checks that it loads. Run it again after every checkout or edit: Herdr
# reloads the panel in place when the files change. A symlink will not do,
# Herdr never reloads a linked mod folder.
# Usage: scripts/install.sh   (HERDR_APP_HOME picks another Herdr home)
set -eu
src=$(cd "$(dirname "$0")/../mods/reviewer" && pwd)
home=${HERDR_APP_HOME:-$HOME/.config/herdr-app}
dest=$home/mods/reviewer
[ -f "$src/mod.json" ] || { echo "no mod at $src" >&2; exit 1; }
command -v herdr-app >/dev/null || { echo "herdr-app is not on PATH" >&2; exit 1; }
if [ -L "$dest" ]; then echo "$dest is a symlink; remove it first (Herdr never reloads a linked mod)" >&2; exit 1; fi
mkdir -p "$dest"
# Drop everything but the two files Herdr writes there itself, then copy.
find "$dest" -mindepth 1 -maxdepth 1 ! -name jsconfig.json ! -name gpui-kit.d.ts -exec rm -rf {} +
cp -R "$src/." "$dest/"
herdr-app check "$dest" || { echo "the installed copy fails to load; Herdr keeps the previous build running until it is fixed" >&2; exit 1; }
version=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$dest/mod.json" | head -n 1)
echo "reviewer ${version:-?} installed in $dest"
