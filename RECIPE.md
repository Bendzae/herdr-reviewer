# reviewer

The shipped Changes panel, made for code review: every diff row is syntax
colored (One Dark Pro by default), and the diff is reviewed like a pull
request. Click a line to leave a comment on it, comments sit inline under
their lines across any number of files, and "Submit review" sends them all,
each with the lines it is about, to the agent running in the space as one
message. It replaces `changes` in a layout; everything the shipped panel did
(file list, diff, commit box) stays.

![reviewer](preview.png)

## What you see

A card the height of its block: 10px corners, 1px `border`, `background`
fill, `foreground` text at 13px. Top to bottom:

- **Header, 42px**, 14px side padding, 1px `border` line below: "Changes"
  in semibold, then every control in the row 24px tall with 12px text and
  6px corners: an "N files" chip (1px `border`, `muted` text, 8px side
  padding), then the **scope picker**: a select-looking box (`raised`,
  1px `border`, `accent` while open) reading "Uncommitted", "Last commit"
  or "vs main" with an 11px chevron; it is a `Popover` whose list (260px,
  `popover` fill, 6px padding, 8px corners, shadow) has three rows 2px
  apart, each 10px side and 7px top/bottom padding holding a 12px label
  over an 11px `dim` detail — "working tree vs HEAD";
  "e29daef · <subject>, plus uncommitted"; "everything on <branch> since
  it left main" — with a 12px `accent` check on the current one; rows the
  repo can't offer ("HEAD has no parent", "on main itself", "no main or
  master branch") are at half opacity and inert. Hidden for a repo
  without a commit. Then on the right `+added` in `ansi2` and `−deleted`
  in `ansi1` at 11px. With draft comments: a `dim` "Discard" link and a **Submit review
  · N** button (24px tall, 10px side padding, 6px corners, 12px medium,
  `solid` background with `solid_foreground` text). With none and a diff
  open: an "Ask about diff" button on the `raised` background.
- **File list**, 28px rows, 6px padding, at most 200px tall then it
  scrolls: a status letter (A `ansi2`, D and U `ansi1`, M `blocked`), the
  folder in `dim` then the name, one speech-bubble button (`comment.svg`)
  per file, `+n` and `−n` on the right. With no drafts the bubble is an
  18px `muted` 12px icon (`hover` background on hover); with drafts it
  becomes a badge, the count at 10px beside a 10px icon on `accent` at 20%
  alpha (33% on hover). Its tooltip reads "Comment on the whole file" or
  "2 draft comments · click to comment on the whole file", and a click
  does that either way. The open file has the `selected`
  background; hover is `hover`.
- **Diff**, in the terminal's font (`font` in settings, JetBrains Mono
  when unset) one size under the terminal's (`font_size` minus one, 13px
  when unset; `props.font_size` overrides), rows 1.8× the size (23px at
  13px), scrolling both ways:
  - Hunk headers (`@@ -1,13 +1,16 @@`) on the `raised` background in `dim`.
  - A right-aligned line-number column in `dim`, sized to the largest line
    number (new-file numbers for added and context lines, old-file numbers
    for removed lines), then a 16px sign column.
  - Added rows tinted with the palette's `added` color (`#98c379` in One
    Dark Pro) at 48/255 alpha, removed rows with `removed` (`#e06c75`) at 48;
    the gutter of those rows carries the same color at 38 alpha, the sign
    column shows a bold `+` or `−` in it, and the number reads at 80%
    `foreground`. No hover styling (see Watch out).
  - Tokens in the One Dark Pro palette by default: keywords `#c678dd`,
    strings `#98c379`, comments `#7f848e`, numbers and booleans `#d19a66`,
    function calls `#61afef`, types `#e5c07b`, `this`/`self` `#e06c75`;
    operators, punctuation, local names and properties stay `foreground`.
    `props.palette` can pick `theme` (ansi colors) or `dark-plus`.
  - The lines the comment box is about carry a 2px `accent` left border,
    their tint rises to 92 alpha (context rows get `selected`), and their
    number turns `foreground`. Lines that already have a comment carry the
    border at 40% alpha.
  - **Inline comments**: under the last line they cover, a box indented
    42px: 8px corners, 1px `accent` border at 40% alpha, `surface` fill,
    a 10px `dim` label "Comment · lines 5–7 · click to edit" and the text
    at 11px, wrapping to the panel's width.
  - Bottom right, while a diff is open and nothing is drafted: a 10px
    `dim` hint "Click a line to comment · right-click to ask" on a
    translucent `raised` pill.
- **Comment box**, a 300px card floating over the top-right of the diff
  while it is open (12px from the top, 14px from the right), so the rows
  never shift: `surface` at 92% alpha so the rows show faintly through,
  1px `border`, 10px corners, large shadow, 10px padding, 8px
  between rows, UI font): a semibold title "Comment" or "Edit comment", a
  16px circled "?" in `dim` beside it whose tooltip holds the how-to (a
  click shows the same text in a `raised` block under the location line
  and turns the "?" `accent`; a second click hides it)
  ("Click a line to widen the range; click a highlighted line to clear
  it." — whole file: "Click a line to comment on lines instead."; none
  when editing — and "Enter adds, shift-enter starts a new line, Esc
  cancels."), and a 20px × on the right (tooltip "Close (Esc)"); an 11px
  `dim` line "auth.js · lines 5–7" (a single line reads "line 14", a whole
  file "whole file (added, binary)", lines gone from the diff "those lines
  are no longer in the diff"); the textarea (4 rows growing to 14, 8px
  corners, 1px `input` border, `background` fill, placeholder "Leave a
  comment on these lines…"); then **Add comment** / **Save** (26px,
  `solid`, tooltip "Enter"), "Cancel" in `dim` (tooltip "Esc"), and when
  editing "Delete" in `ansi1` at the far right. No hint text sits in the
  box itself. Enter is the textarea's submit; a submit with shift held is
  ignored, since the textarea inserts the newline itself. On a panel under
  600px wide the same box is a strip under the diff instead (full width,
  1px `border` above). While a comment is being edited its card stays in
  the diff as a live preview: full `accent` border, the caption "Comment ·
  line 14 · editing" in `accent`, and the text as it is typed in the box
  ("(empty)" in `dim` when cleared); it resizes with the text.
- **Commit bar**: a 32px input "Commit message" (1px border, `accent`
  while focused) and a 32px Commit button (`solid` when there is a message
  and a repo, `raised`/`dim` otherwise). An error line in `ansi1` above it
  when something fails.

## How it behaves

- Follows the focused pane's folder and machine, like the shipped panel:
  changing panes, spaces or tabs reloads; "Not a git repository" shows in
  the list otherwise. Refreshes every 10 s and on any change under the repo
  (local folders only).
- **Scope.** What is reviewed is the working tree against one of three
  refs: `HEAD` (Uncommitted), `HEAD~1` (Last commit: that commit plus
  whatever is uncommitted), or the merge base of the branch with its base
  branch (vs main: everything since the branch left it, committed or not,
  the pull-request view). The base branch is `props.base`, else
  `origin/HEAD`'s branch, else `main`, else `master`; the merge base is
  taken against the local branch when there is one, else `origin/<base>`.
  A repo opens in "vs main" when the branch has left the base, else
  "Uncommitted"; the choice is remembered per repo and machine in shared
  `reviewer.scope`. The file list is `git diff <ref> --name-status`
  plus untracked files and conflicts from `git status`, sorted by path;
  counts come from `git diff <ref> --numstat`; a file's diff is `git diff
  <ref> -- path`. These automatic reads run with the flags Herdr's own
  Changes panel uses (`--no-optional-locks -c core.fsmonitor=false -c
  diff.autoRefreshIndex=false`), so focusing a repo never takes
  `index.lock` from an agent's commit, starts its fsmonitor, or rewrites
  its index; a `--name-status` entry with no `--numstat` line is a file
  whose stat changed but whose content did not, and is skipped. Clicked
  actions such as commit run without them. Switching scope closes the
  comment box and reloads.
  **Each scope has its own draft comments**: switching swaps the set shown
  (the badge, the inline cards and the file bubbles follow), the other
  scopes' drafts stay saved, and Submit and Discard act on the shown
  scope's set only. `reviewer.scope` cycles the scopes the repo
  offers.
- The first changed file's diff opens by itself; clicking a file opens it,
  clicking it again closes it. Untracked files show as one `+` hunk of the
  whole file.
- **Click a diff row** to open the comment box on that line. With the box
  open and empty, **click a row outside the highlight** to widen the
  comment to the range between them, or **click any highlighted row** to
  clear the selection and close the box. **Click a hunk header** to target
  the whole hunk. **Esc**, the ×, or Cancel closes it too. The keyboard
  goes to the textarea when the box opens (and again 300 ms later). The
  list does not scroll: what was clicked is on screen, and a scroll made
  the rows jump. Only a whole-file comment scrolls to the top of the diff,
  where its card sits.
- **Comment on a whole file**: the speech bubble on a file row opens the
  box with the target "whole file" (and opens that file's diff). It is the
  way to comment on a file whose diff has no lines to click (an image, a
  binary, "No text diff available"). Such comments are drawn first in that
  file's diff, labelled "whole file", and never orphan. Clicking the bubble
  again with an empty box closes it; clicking a diff line while it is open
  turns it into a line comment.
- **Add comment** (button, Enter in the textarea, or cmd/ctrl-enter) saves
  it: the box appears inline under the last line, the file list shows the
  count, the header shows "Submit review · N". Comments can be added on
  several files; switching files keeps them.
- **Click an inline comment** to edit it: the box opens with its text and
  lines, Save replaces it, Delete removes it.
- Drafts survive a reload of the mod and a restart: they are kept in
  shared state `reviewer.drafts` per repo, machine and scope (key
  `<machine>:<root>:<scope>`; drafts saved under the older `<machine>:<root>`
  key are moved to the Uncommitted scope on first load), anchored to their
  lines by kind, number and text. A comment whose lines left the
  diff (edited again on disk) stays in the draft and is sent with the two
  lines it remembers, but isn't drawn inline until the lines are back.
- **Submit review · N** builds one message and hands it to the send
  dialog titled "Review · N comments": a header naming the repo (and the
  machine when remote) and the scope in words ("uncommitted changes" /
  "the last commit (e29daef, "<subject>") plus the uncommitted changes" /
  "all changes on branch <b> since it left main (merge base abc1234),
  committed or not"), then per comment, sorted by file and line, a
  `### path, lines a-b` heading, the lines as `<number> <+|-|space> <text>`,
  and `Comment: <text>`; a whole-file comment comes first for its file
  under `### path, whole file (added, binary)` (status and counts, no
  lines). Send in the dialog (or the direct fallback) sends
  it; the dialog then sets shared `reviewer.sent`, and the panel
  clears the drafts. Cancelling the dialog keeps them. **Discard** drops
  them without sending.
- **Ask about diff** (no drafts) sends the whole open diff the same way,
  titled `path:1-16`. **Right-click a row** asks about that one line at
  once; a hunk header asks about the hunk.
- **The send dialog** (`dialog.js`) is this mod opened as an overlay of
  itself (680×560 with context, 560×250 without), the window dimmed
  behind it: a title "Ask the agent" with the caller's title in `dim` and
  "Esc" at the right; a **To** row with a select-looking box naming the
  focused agent (else an idle one, else the first in the space) with its
  status dot and word, and, with several agents, a chevron that opens a
  `Popover` list with a check on the target; a note textarea (2 rows
  growing to 4 with context); the context, read-only, captioned "Sent
  after your note · N lines · read-only" with a Copy link (copy icon,
  "Copied" with a check once clicked), scrolling both ways; a bottom row
  with the hint "cmd-enter sends · goes to <agent name> as one message",
  Cancel and **Send**. Send pastes note and context as one message with
  `hc send` (asking "Send anyway" first when the agent is working or
  blocked, then `--force`), closes, toasts "Sent to …", sets the `sent`
  shared key and focuses the agent's pane. With no agent in the space,
  Send asks `knownAgents({ on: space.machine })` for the most-used installed
  agent and starts its `run` argv in a new tab with the text. While checking,
  disable Send. If discovery fails or no agent is installed, keep the dialog
  and its text open and show the error. Should the overlay fail
  to open, the text goes straight to the space's agent (`hc send`) with a
  toast; with no agent, a warning toast says so.
- Agent status does not change this panel; the dialog shows it.
- A comment keeps the lines it was made on (`quote`, at most 60 lines),
  so a comment whose lines have since left the diff is still submitted
  with what the reviewer saw, not just its first and last line.
- The dialog warns in `blocked` color above 8 KB of context: "This is N
  KB of text pasted into the agent's terminal; some agents are slow or cut
  it short at this size. Consider sending fewer comments at a time."
- Key commands: `reviewer.submit`, `reviewer.ask`,
  `reviewer.clear` (discard drafts), `reviewer.scope` (next
  scope). They reach shown copies only.
- Another mod opens a file's diff by setting shared `reviewer.open` to
  `{ id, at: Date.now(), path, on }` (an absolute path on machine `on`,
  null for local). `render` starts a refresh when the request is for the
  shown repo and machine and its id was not tried yet; the refresh selects
  the file (or shows "Requested file has no diff in this scope" and keeps
  the scope and drafts) and clears the key when it still holds that id. A
  request for another repo waits until the panel shows it; one older than
  30 seconds, or without `at`, is cleared unread.

## Built from

- A clone of the shipped `changes` mod (`mod.clone`, 0.1.8), so `mod.json`
  is `{ "place": "none", "cloned_from": { "name": "changes", "version": "0.1.8" } }`.
  `main.js` keeps the clone's structure: `location()` keyed on the focused
  pane's `cwd` and machine, `refresh` (git `rev-parse`, `status
  --porcelain=v1 -z`, `diff --numstat`), `load` (git `diff HEAD -- path`,
  or `readTextFile` for untracked files), the `v_virtual_list` diff and the
  `InputState` commit box.
- `highlight.js`: `languageOf(path)` maps an extension to a tokenizer
  language (js/ts/jsx/tsx/mjs/cjs → `js`; rs; py; go; c/h/cpp/cc/hpp/m →
  `c`; java/kt/scala/cs → `java`; rb; php; sh/bash/zsh/fish, Dockerfile,
  Makefile → `sh`; sql; css/scss/less; html/xml/svg/vue/svelte → `html`;
  yml/yaml/toml → `yaml`; json; swift) or null for no colors.
  `tokenize(text, lang, state)` scans one line and returns
  `{ spans: [{ text, cls }], state }` with classes keyword, string (escapes
  folded in), comment, number, function (a word before `(`), type (a
  capitalized word, not in sh/sql/css/yaml/json/html), boolean (true,
  false, null-likes, ALL_CAPS) and variable (`this`/`self`/`cls`, `$vars`,
  yaml keys). Operators and punctuation are left plain on purpose, and a
  row has at most 24 spans (the rest merges into plain), so one row is a
  handful of elements. Only the first 600 characters of a line are
  tokenized. `state` carries an open block comment or triple string to the
  next row.
- `palette.js`: `ONE_DARK_PRO`, `DARK_PLUS`, and `palette(name, theme)`
  (`theme` maps to ansi colors).
- `diffRows(lines, lang)` numbers and tokenizes every row once when a diff
  loads (`setLines`), which also builds `index` (row descriptor → index)
  for anchoring. `rebuild()` makes the list's `items`: one per row plus one
  per anchored comment after its last row, with `sizes` (rows 1.8× the
  font size, `44 + 1.45 × font size × wrapped lines` for comments, the
  wrapping estimated from the panel width reported by `on_size_change`).
- Comments: `{ id, path, from, to, text }` where `from`/`to` are row
  descriptors `{ kind, number, text }`. The composer is
  `{ path, from, to, editing }` with the same descriptors; `target()`
  resolves it against the open diff. `clickRow`, `editComment`,
  `addComment`, `deleteComment`, `closeComposer`, `setComments` (persists
  to shared `reviewer.drafts` under `${machine}:${root}`), `submit`
  (builds the message, calls `ask` with `sent: "reviewer.sent"`,
  clears on "sent", or when `render` sees the shared key move past the
  submit time).
- `v_virtual_list("changes-diff", items.length, sizes, key, render)` with
  `on_item_click` (keys `r:<row>` and `c:<comment id>`) and
  `on_item_secondary_click` (quick ask). A `TextareaState` for the
  comment, created in `init`, with `submit` → `addComment`.
- `ask.js`: `pickAgent()`, `ask({ title, context, sent })` → opens this
  mod as a dialog overlay with props `{ dialog: true, title, context,
  sent }`, or sends with `hc send` and sets the `sent` key itself;
  resolves "dialog", "sent" or "none". `dialog.js` exports `Dialog`
  (`init`, `render`, `send`, `start`, `close`); `main.js` hands a copy
  over to it when `props().dialog` is set, so the dialog copy never runs
  git.
- `herdr` calls: `spaces`, `panes`, `focused`, `exec`, `readTextFile`,
  `watchFolder`, `theme`, `settings`, `nextCommand`, `props`, `shared`,
  `setShared`, `agents`, `hc`, `notify`, `openOverlay`, `appHome`.
  Programs run: `git`, `hc`.
- Art: `changes.svg` from the clone (unused by the panel itself).

## Watch out

- The virtual list's row renderer runs twice per frame inside layout, and a
  per-row hover style forces a frame on every mouse move. The first build
  colored operators and punctuation too and gave rows a hover tint; moving
  the mouse over the diff lagged. Hence: no hover on rows, few span classes,
  the 24-span cap. Keep it that way.
- A handler registered inside the row renderer throws at run time, and a
  row may hold no retained state (no textarea). Rows have no buttons; every
  click comes through the list's `on_item_click` with the row's key, and
  the comment box lives outside the list, floating over its top-right
  corner (a column on the left made the rows jump sideways whenever it
  opened, a column on the right narrowed the diff; scrolling the clicked
  row to the middle made the rows jump vertically, so that went too). It
  covers the right end of the rows under it; long lines run beneath.
  Every press inside the box stops propagating (mouse down, mouse up and
  click), or a press on Add would also reach the row under the box and
  reopen it the moment it closed. Two
  other placements were tried and dropped: a strip docked above the commit
  bar (far from the lines, and the edited comment showed twice), and an
  inline box mirroring an invisible textarea (the textarea never reports
  its cursor, arrow keys never reach the panel, so the drawn caret lied).
  The list's scroll offset can't be read either, so the column can't line
  up with the clicked row, and nothing is done about it: the rows stay
  put, which matters more.
- Comment heights are estimated (0.62 em per character); a
  comment with very long words may wrap one line more than estimated and
  clip its last line. Keep comments short or widen the panel.
- Block-comment state runs through removed and added rows alike; a comment
  opened on a removed line and closed on an added one colors the rows
  between as comment. Rare and harmless.
- `===` and `||` draw as ligatures in JetBrains Mono, like in the terminal.
- A mod command (`reviewer.submit`) is refused with "need the mod
  loaded" while no copy is shown and for a second or two after any file in
  the mod folder changes (hot reload).
- `hc send` wraps what it pastes in `<hc from="…">` tags; agents see the
  review inside them.
- Remote spaces: every `exec`/`readTextFile` passes `{ on }`; the message
  says "(on machine)" after the path so the agent knows where the file is.
- Limits from the clone: 1,000 files, 1,500 diff lines, 4,000 characters
  per line; 400 rows per "Ask about diff".

## Done when

- On a feature branch the header reads "vs main" and the list holds every
  file the branch changed; on `main` with a clean tree, "Last commit"
  shows that commit's files and "Uncommitted" shows none.
- A space whose folder has uncommitted changes to a `.js`, `.rs` or `.py`
  file shows that file's diff with keywords, strings, comments and numbers
  in four different colors on green and red rows, line numbers on the left,
  hunk headers on the raised background. Moving the mouse over the diff
  doesn't lag.
- Clicking a row opens the comment box under that line, naming it;
  clicking a row two lines down widens it to "lines a–b" and the box moves
  under the new last line; clicking one of those highlighted rows clears
  it; so does Esc. Typing shows up in the box as you type.
- Typing a comment and pressing Add comment puts a box with that text
  under the last line, a "1" speech-bubble badge on the file, and "Submit review · 1"
  in the header. Clicking the box reopens it for editing; Delete removes it.
- After switching to another changed file and adding a comment there, the
  header reads "Submit review · 2" and each file shows its own badge.
- Submit review opens the send dialog titled "Review · 2 comments"
  whose context lists both comments under `### path, lines` headings with
  the quoted lines; after Send, the drafts are gone and the agent's
  terminal (`hc read <t>`) shows the message.
- Cancelling the dialog keeps the drafts; Discard removes them.
- Right-clicking a row opens the dialog for that one line.
- The mod needs nothing else installed: the dialog is its own overlay.
