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
# Herdr's main layout caps the side panel at 900px, too narrow for a review;
# raise the max on every node holding the reviewer block to WIDE. Without the
# cap the panel could cover the terminals, so each sibling of a raised node
# that has no min of its own gets KEEP px. It never lowers a max or replaces
# a min, and leaves the layout as it was without python3.
WIDE=10000 KEEP=480
widen() {
  command -v python3 >/dev/null 2>&1 || { echo "python3 isn't on PATH, so the panel keeps its max width; raise \"max\" on the node holding reviewer in $1 by hand"; return 0; }
  python3 - "$1" "$WIDE" "$KEEP" <<'PY'
import json, sys
path, wide, keep = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
with open(path) as f: tree = json.load(f)
def holders(node, trail):
    if (node.get("content") or {}).get("mod") == "reviewer": return trail
    for child in node.get("children") or []:
        found = holders(child, trail + [child])
        if found is not None: return found
    return None
trail = [tree] + (holders(tree, []) or [])
raised, kept = [], []
for parent, n in zip(trail, trail[1:]):
    if isinstance(n.get("max"), (int, float)) and n["max"] < wide:
        raised.append("%s %s" % (n.get("id"), n["max"])); n["max"] = wide
        for sib in parent.get("children") or []:
            if sib is not n and "min" not in sib and "px" not in (sib.get("size") or {}):
                sib["min"] = keep; kept.append(str(sib.get("id")))
was = ", ".join(raised) + ("; %s keeps at least %dpx" % (", ".join(kept), keep) if kept else "")
if raised:
    with open(path + ".reviewer-tmp", "w") as f: json.dump(tree, f, indent=2); f.write("\n")
    import os; os.replace(path + ".reviewer-tmp", path)
    print("layout: the panel holding reviewer can now be dragged wider (max %dpx; was %s)" % (wide, was))
PY
}
if uses "$file" reviewer; then
  echo "layout $shown already shows reviewer"
  widen "$file"
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
widen "$file"
