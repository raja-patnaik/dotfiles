# Neovim + LazyVim Cheatsheet

**Leader Key:** `Space`

## 🚀 Quick Start

| Key | Action |
|-----|--------|
| `jj` | Exit insert mode |
| `<Space>` | Leader key (wait for menu) |
| `:checkhealth` | Check Neovim configuration |
| `:Lazy` | Open Lazy plugin manager |

---

## 📝 Basic Vim Motions

### Movement
| Key | Action |
|-----|--------|
| `h` `j` `k` `l` | Left, Down, Up, Right |
| `w` / `b` | Next/previous word |
| `e` / `ge` | End of word forward/backward |
| `0` / `$` | Start/end of line |
| `gg` / `G` | First/last line |
| `{` / `}` | Previous/next paragraph |
| `Ctrl-u` / `Ctrl-d` | Half page up/down |
| `Ctrl-b` / `Ctrl-f` | Full page up/down |
| `%` | Jump to matching bracket |

### Editing
| Key | Action |
|-----|--------|
| `i` / `a` | Insert before/after cursor |
| `I` / `A` | Insert at start/end of line |
| `o` / `O` | Open line below/above |
| `u` / `Ctrl-r` | Undo/redo |
| `dd` | Delete line |
| `yy` | Yank (copy) line |
| `p` / `P` | Paste after/before cursor |
| `x` | Delete character |
| `r` | Replace character |
| `ciw` | Change inner word |
| `diw` | Delete inner word |
| `vi"` | Visual select inside quotes |

---

## 🎯 Custom Keybindings

### Insert Mode
| Key | Action |
|-----|--------|
| `jj` | Exit to normal mode |
| `Ctrl-s` | Save file (stays in insert) |

### Window Navigation
| Key | Action |
|-----|--------|
| `Ctrl-h` | Move to left window |
| `Ctrl-j` | Move to bottom window |
| `Ctrl-k` | Move to top window |
| `Ctrl-l` | Move to right window |

### Window Resizing
| Key | Action |
|-----|--------|
| `Ctrl-Up` | Increase height |
| `Ctrl-Down` | Decrease height |
| `Ctrl-Left` | Decrease width |
| `Ctrl-Right` | Increase width |

### Buffer Navigation
| Key | Action |
|-----|--------|
| `Shift-h` | Previous buffer |
| `Shift-l` | Next buffer |

### Text Manipulation
| Key | Action |
|-----|--------|
| `Alt-j` | Move line down |
| `Alt-k` | Move line up |
| `<` / `>` (visual) | Indent left/right (stays in visual) |
| `p` (visual) | Paste without yanking |

### General
| Key | Action |
|-----|--------|
| `Ctrl-s` | Save file |
| `Esc` | Clear search highlights |
| `<leader>q` | Quit |
| `<leader>Q` | Quit all |
| `<leader>\|` | Split vertically |
| `<leader>-` | Split horizontally |
| `<leader>ln` | Toggle relative line numbers |

---

## 📂 File Navigation

### Telescope (Fuzzy Finder)
| Key | Action |
|-----|--------|
| `<leader><space>` | Find files |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search in files) |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Find help tags |
| `<leader>fr` | Recent files |
| `<leader>fc` | Find commands |
| `<leader>fk` | Find keymaps |
| `<leader>/` | Grep in open files |
| `<leader>:` | Command history |

**Inside Telescope:**
- `Ctrl-j` / `Ctrl-k` - Navigate up/down
- `Enter` - Select
- `Ctrl-x` - Open in horizontal split
- `Ctrl-v` - Open in vertical split
- `Ctrl-t` - Open in new tab
- `Esc` - Close

### Neo-tree (File Explorer)
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>E` | Focus file explorer |

**Inside Neo-tree:**
- `a` - Add file/directory
- `d` - Delete
- `r` - Rename
- `y` - Copy
- `x` - Cut
- `p` - Paste
- `R` - Refresh
- `?` - Show help

---

## 💻 LSP & Coding

### Code Actions
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Hover documentation |
| `gK` | Signature help |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format document |
| `[d` / `]d` | Previous/next diagnostic |
| `<leader>cd` | Line diagnostics |

### Diagnostics (Trouble)
| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle trouble |
| `<leader>xw` | Workspace diagnostics |
| `<leader>xd` | Document diagnostics |
| `<leader>xq` | Quickfix list |
| `<leader>xl` | Location list |

---

## 🌳 Tree-sitter Textobjects

### Select Objects
| Key | Action |
|-----|--------|
| `vaf` | Select around function |
| `vif` | Select inside function |
| `vac` | Select around class |
| `vic` | Select inside class |
| `vaa` | Select around parameter |
| `via` | Select inside parameter |

### Navigate Functions/Classes
| Key | Action |
|-----|--------|
| `]m` | Next function start |
| `[m` | Previous function start |
| `]M` | Next function end |
| `[M` | Previous function end |
| `]]` | Next class start |
| `[[` | Previous class start |
| `][` | Next class end |
| `[]` | Previous class end |

---

## 🔧 Git Integration

### Gitsigns
| Key | Action |
|-----|--------|
| `<leader>gb` | Git blame line |
| `<leader>gd` | Git diff |
| `<leader>gs` | Git status |
| `]c` | Next hunk |
| `[c` | Previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |

### LazyGit
| Key | Action |
|-----|--------|
| `<leader>gg` | Open LazyGit |

---

## 🖥️ Terminal

### ToggleTerm
| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle terminal |
| `<leader>tf` | Toggle float terminal |
| `<leader>th` | Toggle horizontal terminal |
| `<leader>tv` | Toggle vertical terminal |
| `Esc Esc` | Exit terminal mode |

---

## 🐛 Debugging (DAP)

| Key | Action |
|-----|--------|
| `F5` | Continue/Start debugging |
| `F10` | Step over |
| `F11` | Step into |
| `F12` | Step out |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>dr` | REPL toggle |
| `<leader>dl` | Run last |

---

## 🤖 AI & Copilot

### GitHub Copilot
| Key | Action |
|-----|--------|
| `Ctrl-j` | Accept suggestion |
| `Alt-]` | Next suggestion |
| `Alt-[` | Previous suggestion |
| `Ctrl-]` | Dismiss suggestion |

### Sidekick AI
| Key | Action |
|-----|--------|
| `Tab` | Jump to/apply next edit suggestion |
| `<leader>aa` | Toggle Sidekick CLI |
| `<leader>as` | Select CLI tool |
| `<leader>at` | Send current context |
| `<leader>av` | Send visual selection |
| `<leader>ap` | Sidekick prompt selector |
| `<leader>ac` | Open Claude directly |
| `Ctrl-.` | Switch focus to/from Sidekick |

---

## 📑 Surround (nvim-surround)

| Key | Action |
|-----|--------|
| `ys{motion}{char}` | Add surround |
| `yss{char}` | Surround entire line |
| `ds{char}` | Delete surround |
| `cs{old}{new}` | Change surround |

**Examples:**
- `ysiw"` - Surround word with quotes
- `yss)` - Surround line with parentheses
- `ds"` - Delete surrounding quotes
- `cs"'` - Change quotes to single quotes
- `cst<div>` - Change surrounding tag to div

---

## 💾 Sessions

| Key | Action |
|-----|--------|
| `<leader>ps` | Restore session |
| `<leader>pl` | Restore last session |
| `<leader>pd` | Stop session persistence |

---

## 🔍 Search & Replace

### In Current File
- `/pattern` - Search forward
- `?pattern` - Search backward
- `n` / `N` - Next/previous match
- `*` / `#` - Search word under cursor forward/backward
- `:%s/old/new/g` - Replace all in file
- `:%s/old/new/gc` - Replace all with confirmation

### Project-wide
- `<leader>sr` - Search and replace in project
- `<leader>sR` - Search and replace (with confirmation)

---

## 📦 Plugin Management

| Key | Action |
|-----|--------|
| `:Lazy` | Open Lazy plugin manager |
| `:Lazy sync` | Update plugins |
| `:Lazy clean` | Remove unused plugins |
| `:Lazy profile` | Profile plugin load times |

---

## 🎨 UI & Appearance

| Key | Action |
|-----|--------|
| `<leader>ui` | Toggle UI elements |
| `<leader>uc` | Toggle conceal level |
| `<leader>ul` | Toggle line numbers |
| `<leader>ur` | Toggle relative line numbers |
| `<leader>us` | Toggle spelling |
| `<leader>uw` | Toggle word wrap |

---

## 📊 Markdown

| Key | Action |
|-----|--------|
| `<leader>mp` | Markdown preview toggle |

---

## ⌨️ Which-key

Press `<Space>` and wait briefly to see all available leader key combinations in a popup menu.

---

## 🔥 Pro Tips

1. **Use `.` to repeat last change** - Super powerful for repetitive edits
2. **Visual block mode (`Ctrl-v`)** - Edit multiple lines at once
3. **Macros (`q{letter}`)** - Record and replay complex edits
4. **Jump list (`Ctrl-o` / `Ctrl-i`)** - Navigate back/forward through jump history
5. **Change list (`g;` / `g,`)** - Navigate through your changes
6. **Search in visual selection** - Select text, then `/<pattern>\%V`
7. **Multiple cursors alternative** - Use `cgn` with `.` for better control
8. **Code folding** - `za` toggle fold, `zR` open all, `zM` close all
9. **`:e!`** - Reload file and discard changes
10. **`:wa`** - Save all open files

---

## 📚 Learning Resources

- Press `<Space>` and wait to see which-key menu
- `:help {topic}` - Built-in help (e.g., `:help telescope`)
- `:Tutor` - Interactive Vim tutorial
- `:checkhealth` - Diagnose configuration issues
- LazyVim docs: https://www.lazyvim.org

---

**Note:** This cheatsheet is based on your current configuration. Keybindings may differ if you modify your config.
