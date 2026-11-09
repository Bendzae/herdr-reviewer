# reviewer

A [Herdr](https://herdr.dev) mod that turns the shipped Changes panel into
a pull-request style review of your working tree. Diffs are syntax colored,
you click lines to leave comments, and "Submit review" sends every comment,
with the lines it is about, to the agent running in the space as one
message.

![reviewer](preview.png)

## What it does

- **Syntax-colored diffs** in One Dark Pro (or `dark-plus`, or your
  terminal theme's ansi colors), with line numbers, hunk headers and
  clearly tinted added and removed rows.
- **Four review scopes**: *Uncommitted* (working tree vs `HEAD`),
  *Last commit* (that commit plus whatever is uncommitted), *vs main*
  (everything since the branch left its base, committed or not), or any
  one commit on its own, picked from the same list: the branch's own
  commits when it has left its base, else the last 100. A branch
  that has left its base opens in *vs main*; the choice is remembered per
  repo.

  ![Scope picker](screenshots/scope-picker.png)

- **Comments on lines, ranges, hunks or whole files.** Click a line to
  open the comment box, click another line to widen the range, click a hunk
  header to target the hunk, or the speech bubble on a file to comment on
  the whole file (binaries and images included).

  ![Comment box](screenshots/comment-box.png)

- **Inline draft comments** sit under their lines across any number of
  files, each file shows a badge with its count, and the header reads
  "Submit review · N". Click a comment to edit or delete it. Drafts survive
  reloads and restarts, and each scope keeps its own set.

  ![Inline comments](screenshots/inline-comments.png)

- **Submit review** builds one message, sorted by file and line, each
  comment under a `### path, lines a-b` heading with the quoted lines, and
  hands it to a send dialog where you pick the agent, add a note and send.

  ![Send dialog](screenshots/send-dialog.png)

- **Ask the agent about anything in the diff**, no review needed.
  Right-click a line or a hunk header to ask about just that, or click
  "Ask about diff" to send the whole open file's diff. The same dialog
  opens with the lines attached, you type your question, and it lands in
  the agent's terminal as one message. With no agent in the space it
  starts the most-used installed agent on that space’s machine in a new tab
  with the text. If no agent is installed or discovery fails, the dialog
  keeps your text and shows an error.

  The agent gets the whole review as one message, each comment with the
  lines it is about, and the drafts are cleared.

  ![The review in the agent's terminal](screenshots/review-in-agent.png)

Everything the shipped panel did (file list, diff, commit box) stays.

## Install

1. Run `scripts/install.sh`. It copies `mods/reviewer/` into
   `~/.config/herdr-app/mods/` (or `$HERDR_APP_HOME/mods/`) and runs
   `herdr-app check` on the copy. Without the script: copy the folder by
   hand and run `herdr-app check ~/.config/herdr-app/mods/reviewer`. Don't
   symlink it; Herdr loads a linked folder but never reloads it.
2. With Herdr open, the script then puts Reviewer where the Changes panel
   is: it swaps the `changes` block in the shown layout for `reviewer`, so
   the Changes button in the tab bar opens Reviewer. Herdr's own layouts
   are read-only, so if you are on one (such as the default `main`) the
   script clones it as `<name>-reviewer` and switches to it; the clone
   keeps your sizes and look. A layout you cloned yourself is edited in
   place. Pass `--no-layout` to skip this step.
3. Run the script again after each update or checkout; Herdr reloads the
   panel in place. It leaves a layout that already shows `reviewer` alone.

Without the script, or with Herdr closed, do step 2 by hand: in your own
layout (`herdr-app do layout.clone '{"name":"main","as":"main-reviewer"}'`
if you are on a shipped one), replace the `changes` block's mod with
`reviewer`, or add a new block for it. Herdr never overwrites it, since it
is a clone of the shipped `changes` mod rather than the shipped mod itself.

Or ask the agent in your Herdr window to add
`herdr.dev/mods/vytasgavelis/reviewer`; the steps are in Herdr's
`AGENTS.md`. Those steps only copy the folder, so ask it to swap the
`changes` block as above too. Reviewer's `mod.json` has `"place": "none"`
because Herdr can't dock a new mod into a shipped layout, and in a
personal one it would dock at the window's edge, not in the Changes
panel's spot.

The mod runs `git` and `hc` (Herdr's terminal core) and reads files under
the repo it shows. It needs nothing else installed: the send dialog is the
mod opened as an overlay of itself.

## Versions

The mod's version is the `version` field in `mods/reviewer/mod.json`, and
each release is tagged `v<version>` in this repo. Installed copies carry no
git history, so quote that field when reporting a problem. Version 0.5.0 was
last tested on Herdr 0.1.13 (`herdr-app` 0.1.13, `herdr` 0.9.5).

## Commands and props

Bind these in `keys.json` if you want keys for them (none are bound by
default):

| Command | Does |
|---|---|
| `reviewer.submit` | Submit the shown scope's draft comments |
| `reviewer.ask` | Ask the agent about the whole open diff |
| `reviewer.clear` | Discard the shown scope's drafts |
| `reviewer.scope` | Cycle Uncommitted, Last commit and vs main |

Block props: `palette` (`one-dark-pro`, `dark-plus` or `theme`),
`font_size` (overrides the diff's size), `base` (the branch *vs main*
compares against; default `origin/HEAD`, else `main`, else `master`).

## Open a file from another mod

Write a one-shot request with Herdr's `setShared`:

```js
setShared("reviewer.open", {
  id: `${Date.now()}-${Math.random()}`,
  at: Date.now(),
  path: "/absolute/path/to/repo/src/file.js",
  on: null, // Remote machine ID for remote files; null for local files.
  ref: "abc1234", // Optional: review this commit on its own first.
});
```

`path` may also be the repository folder itself, to open Reviewer on the
repo without selecting a file (useful with `ref`). `ref` is anything
`git rev-parse` resolves to a commit (a hash, a tag, `HEAD~2`); it switches
the scope to that commit, as picking it from the scope list would. A `ref`
that isn't in the repo leaves the scope as it was and shows a message.

Then reveal Reviewer's block using `layout.select` and `layout.show`.
Reviewer selects the file and loads its diff after refreshing, including when
a refresh or commit is already running. The request is consumed once; opening
the same file again keeps its diff open. A newer request survives an older
refresh. A request for another repository or machine waits until the
reviewer shows that repository, for up to 30 seconds; after that it is
dropped, as is one without `at`.

The focused pane must already be in the target repository and machine.
Without `ref`, the current review scope stays selected; draft comments are
preserved either way.
If the requested file has no diff in that scope, or falls outside the first
1,000 files, Reviewer shows a message instead of an unrelated diff.

## Recipe

`RECIPE.md` is the brief this mod was built from: an agent with an empty
folder can rebuild it from there.

## License

MIT, see [LICENSE](LICENSE). The mod started as a clone of Herdr's shipped
`changes` mod (Apache-2.0) and uses Lucide icons (ISC); see
[THIRD-PARTY-NOTICES](THIRD-PARTY-NOTICES).
