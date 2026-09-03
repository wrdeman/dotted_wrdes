# GitHub in Neovim — octo.nvim

[octo.nvim](https://github.com/pwntester/octo.nvim) puts GitHub issues, pull requests and
**code review** inside nvim. Config: `nvim/lua/plugins/octo.lua` (spec in
`nvim/lua/plugins/init.lua`).

Everything goes through the **`gh` CLI** — octo shells out to it for every API call. No token
lives in this repo; auth is whatever `gh auth login` already set up.

---

## Setup (once)

```sh
gh auth login          # gh is installed by install.sh (brew on macOS, GitHub release on Linux)
gh auth status         # verify
```

Then in nvim: `:checkhealth octo` — checks nvim version, the `gh` binary, auth and the picker.

`cwd` must be inside a git repo with a GitHub remote. Remotes are tried in the order
`upstream`, `origin`, so on a fork you review against upstream.

---

## Entry points

`<leader>o*` opens things; a bare `:Octo` opens a picker of **every** action (`enable_builtin`),
which is the fastest way to find something not mapped below.

| Key | Command | Action |
|-----|---------|--------|
| `<leader>oo` | `:Octo` | picker of all Octo actions |
| `<leader>op` | `:Octo pr list` | list PRs |
| `<leader>oi` | `:Octo issue list` | list issues |
| `<leader>or` | `:Octo review start` | start a review of the current PR |
| `<leader>oR` | `:Octo review resume` | resume a pending (unsubmitted) review |
| `<leader>ov` | `:Octo review submit` | open the submit window |
| `<leader>on` | `:Octo notification list` | GitHub notifications |
| `<leader>os` | `:Octo search` | search GitHub |

Useful typed commands: `:Octo pr create`, `:Octo pr checkout`, `:Octo pr checks`,
`:Octo pr diff`, `:Octo issue create`, `:Octo review discard`, `:Octo review comments`
(list your pending comments), `:Octo actions` (same as bare `:Octo`).

Inside a picker: `<C-b>` open in browser, `<C-y>` copy URL, `<C-o>` checkout PR, `<C-r>` merge.

> **`<localleader>` is also `<Space>`** in this config (both leader and localleader). Octo's
> in-buffer maps are therefore `<Space>…` and **shadow the same-suffix global maps while you
> are in an octo buffer** — e.g. `<leader>ca` is LSP code action everywhere else, but "add
> comment" in an octo buffer, and `<leader>e` is "focus file panel" in a review diff instead of
> the file tree. That is buffer-local only; normal buffers are unaffected.

---

## Reviewing a PR

1. **Open the PR** — `<leader>op`, pick it. You get an `octo://` buffer with the description,
   labels, reviewers, CI checks and the full timeline of comments.
2. **Start the review** — `<localleader>vs` in that buffer (or `<leader>or` / `:Octo review
   start`). A **review tab** opens: a **changed-files panel** at the bottom, and a two-pane
   diff — base on the left, PR version on the right (cursor starts on the right).
3. **Move through the diff:**

| Key | Action |
|-----|--------|
| `]q` / `[q` | next / previous changed file |
| `]Q` / `[Q` | first / last changed file |
| `]u` / `[u` | next / previous **unviewed** file |
| `]t` / `[t` | next / previous comment thread |
| `<localleader><space>` | toggle the file's "viewed" state |
| `<localleader>e` | jump focus to the changed-files panel |
| `<localleader>b` | hide/show the changed-files panel |
| `<localleader>C` | pick specific PR commits to review instead of the whole diff |
| `gf` | open the real file at that line |
| `<C-c>` | close the review tab |

   In the files panel: `j`/`k` move, `<CR>` opens the diff for that file, `R` refreshes.
4. **Comment** (below), then **submit** (below).

Existing threads pop open as the cursor reaches them (`auto_show_threads`), with a virtual-text
comment count on the line.

## Adding comments

| Where | Key | Action |
|-------|-----|--------|
| Review diff | `<localleader>ca` | add a review comment on the line (or on the visual selection) |
| Review diff | `<localleader>sa` | add a **suggestion** (pre-filled with the selected lines as a ```suggestion block) |
| Thread buffer | `<localleader>ca` | new comment in that thread |
| Thread buffer | `<localleader>cr` | reply to the comment under the cursor |
| PR/issue buffer | `<localleader>ca` | top-level comment on the PR/issue |

Both `ca` and `sa` work in **normal mode** (single line) and **visual mode** (multi-line range) —
select the lines first to attach the comment to a range.

**How the write works:** in a PR/issue buffer, `<localleader>ca` appends an empty comment
block *into that same buffer* — type the body there, then `:w`. Octo intercepts the write with
its own `BufWriteCmd` on `octo://*` and pushes it to GitHub; nothing touches disk. In a review
diff, `<localleader>ca` opens the comment in a **split**, and `:w` there sends it and folds the
split back into a thread on the diff line. Either way **`:w` is what sends it** — and
format-on-save is disabled for `octo` buffers (`conform.lua`) so nothing rewrites your text on
the way out. `<localleader>cd` deletes the comment under the cursor, `<localleader>ce` shows its
edit history. `]c` / `[c` walk between comments.

Comments made during a review are **pending** until you submit — `:Octo review comments` lists
them, `:Octo review discard` throws the whole draft away.

Threads: `<localleader>rt` resolve, `<localleader>rT` unresolve.
Reactions on any comment: `<localleader>r+` 👍, `<localleader>r-` 👎, `<localleader>rp` 🎉,
`<localleader>rh` ❤️, `<localleader>re` 👀, `<localleader>rr` 🚀, `<localleader>rl` 😄,
`<localleader>rc` 😕.

## Approving

Two different things, don't mix them up:

Pending comments live **on GitHub as a pending review**, not locally — so closing the review
tab, or `:q`-ing out by accident, loses nothing. `<leader>oR` (`:Octo review resume`) brings the
tab back with the comments intact.

**Submit a review** (the one with your pending comments) — `<localleader>vs` from the review
diff or files panel, or `<leader>ov`. A **submit window** opens for the review body; write it,
then pick the verdict:

| Key | Action |
|-----|--------|
| `<C-a>` | **approve** |
| `<C-y>` | comment (no verdict) |
| `<C-r>` | request changes |
| `<C-c>` | close without submitting (the draft stays pending) |

These are **normal-mode only**, so Enter is an ordinary newline while you type the body.
Octo's default for the comment verdict is `<C-m>`, which a terminal sends as carriage return —
indistinguishable from `<CR>`, so an Esc followed by a stray Enter would submit the review.
`octo.lua` moves it to `<C-y>` and leaves Enter doing nothing here.

**Approve straight from the PR buffer**, no review needed — `<localleader>pa`.
(Octo's default for this is `<leader>qa`; it is remapped in `octo.lua` because `<space>q` is
`:q` here and the two-key prefix would stall it.)

> The two keymap overrides in `octo.lua` are exactly these: **approve PR → `<localleader>pa`**
> and **comment review → `<C-y>`**. Everything else is octo's default.

`<localleader>vd` **from the review diff or files panel** discards the pending review (in a PR
buffer that same key removes a reviewer instead — same letters, different window).

## Merging, and other PR-buffer actions

| Key | Action |
|-----|--------|
| `<localleader>po` | checkout the PR locally |
| `<localleader>pm` | merge (merge commit) |
| `<localleader>psm` | squash and merge |
| `<localleader>prm` | rebase and merge |
| `<localleader>pc` | list PR commits |
| `<localleader>pf` | list changed files |
| `<localleader>pd` | show the PR diff |
| `<localleader>vs` / `<localleader>vr` | start / resume a review (same keys as the diff's submit — see above) |
| `<localleader>va` / `<localleader>vd` | add / remove a reviewer |
| `<localleader>aa` / `<localleader>ad` | add / remove an assignee |
| `<localleader>la` / `<localleader>ld` / `<localleader>lc` | add / remove / create a label |
| `<localleader>ic` / `<localleader>io` | close / reopen |
| `<localleader>tc` | fold/unfold the CI checks list |
| `<localleader>gc` | open the CI check under the cursor |
| `<localleader>gi` | jump to a local repo issue |
| `<CR>` | menu of all actions for this PR/issue |
| `<C-r>` | reload from GitHub |
| `<C-b>` | open in browser |
| `<C-y>` | copy URL |

Default merge method is a **merge commit** and the branch is **not** deleted — pass
`delete`/`nodelete` to `:Octo pr merge` to override per-merge.

---

## Notes

- **Highlighting:** octo buffers register the `markdown` treesitter parser
  (`vim.treesitter.language.register("markdown", "octo")` in `octo.lua`), so `markdown` and
  `markdown_inline` are in the treesitter `ensure_installed` list.
- **Completion:** `<C-x><C-o>` in an octo buffer completes issues/PRs (`#`) and users (`@`)
  via octo's own omnifunc. No nvim-cmp source is wired up for it.
- **Signs:** modified-line marks go in the status (number) column, not the sign column — the
  sign column belongs to gitsigns.
- `use_local_fs` is off: the right side of a review diff is GitHub's copy of the file, not your
  working tree, so reviewing does not depend on having the branch checked out.
