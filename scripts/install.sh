#!/bin/sh
# Installs this checkout's mods/reviewer into Herdr, replacing what is there,
# and checks that it loads. Run it again after every checkout or edit: Herdr
# reloads the panel in place when the files change. A symlink will not do,
# Herdr never reloads a linked mod folder.
#
# With the Herdr window open it then puts Reviewer where the Changes panel
# is: in the shown layout it swaps the `changes` block's mod for `reviewer`.
# Herdr's own layouts are read-only, so a shipped one (say `main`) is first
# cloned as `<name>-reviewer`, which Herdr switches to; a layout you cloned
# yourself is edited in place. Herdr can't dock a new mod into a shipped
# layout, which is why this step exists.
#
# Usage: scripts/install.sh [--no-layout]   (HERDR_APP_HOME picks another Herdr home)
set -eu
layout_step=1
for arg in "$@"; do
  case $arg in
    --no-layout) layout_step=0 ;;
    *) echo "usage: scripts/install.sh [--no-layout]" >&2; exit 2 ;;
  esac
done
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

[ "$layout_step" = 1 ] || exit 0
manual="In your layout, replace the \`changes\` block's mod with \`reviewer\` (see README, Install)."
shown=$(herdr-app status 2>/dev/null | sed -n 's/^ *"layout": *"\([^"]*\)".*/\1/p' | head -n 1) || shown=
if [ -z "$shown" ]; then
  echo "Herdr isn't open, so the layout was left alone. Run this again with Herdr open, or: $manual"
  exit 0
fi
file=$home/layouts/$shown.json
uses() { grep -q "\"mod\": *\"$2\"" "$1"; }
if [ ! -f "$file" ]; then
  echo "can't find the shown layout at $file. $manual"
  exit 0
fi
if uses "$file" reviewer; then
  echo "layout $shown already shows reviewer"
  exit 0
fi
if ! uses "$file" changes; then
  echo "layout $shown has no \`changes\` block to swap. Add a block with \"mod\": \"reviewer\" where you want it."
  exit 0
fi
if ! grep -q '"cloned_from"' "$file"; then
  # Herdr's own layout: clone it (the clone keeps its look and clicks) and edit the clone.
  clone=$shown-reviewer
  if [ -f "$home/layouts/$clone.json" ]; then
    echo "layout $clone already exists; switch to it with: herdr-app do layout.switch '{\"name\":\"$clone\"}'"
    exit 0
  fi
  herdr-app do layout.clone "{\"name\":\"$shown\",\"as\":\"$clone\"}" >/dev/null
  file=$home/layouts/$clone.json
  i=0
  while [ ! -f "$file" ] && [ $i -lt 50 ]; do sleep 0.1; i=$((i + 1)); done
  [ -f "$file" ] || { echo "Herdr didn't write $file. $manual" >&2; exit 1; }
  shown=$clone
fi
tmp=$file.reviewer-tmp
sed 's/"mod": *"changes"/"mod": "reviewer"/' "$file" > "$tmp" && mv "$tmp" "$file"
echo "layout $shown: the Changes panel now shows reviewer (the Changes button in the tab bar opens it)"
