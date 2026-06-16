#!/usr/bin/env bash
# Bootstrap script for dotted_wrdes dotfiles.
# Installs core tools on macOS (Homebrew) and Linux (apt + GitHub releases).
# Usage:
#   ./install.sh           -- install everything
#   ./install.sh --latex   -- also install a LaTeX distribution
#   ./install.sh --links   -- only create symlinks, skip package installs

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_LATEX=false
LINKS_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --latex)     INSTALL_LATEX=true ;;
        --links)     LINKS_ONLY=true ;;
        -h|--help)
            echo "Usage: $0 [--latex] [--links]"
            echo "  --latex   also install TeX Live / MacTeX"
            echo "  --links   only symlink dotfiles, skip package installs"
            exit 0 ;;
        *) echo "Unknown option: $arg"; exit 1 ;;
    esac
done

# ── Helpers ──────────────────────────────────────────────────────────────────

OS="$(uname -s)"
info()    { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
ok()      { printf "\033[1;32m  ✓\033[0m %s\n" "$*"; }
warn()    { printf "\033[1;33m  !\033[0m %s\n" "$*"; }
die()     { printf "\033[1;31mERROR:\033[0m %s\n" "$*" >&2; exit 1; }
has()     { command -v "$1" &>/dev/null; }

symlink() {
    local src="$1" dst="$2"
    local dst_dir
    dst_dir="$(dirname "$dst")"
    mkdir -p "$dst_dir"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        ok "Already linked: $dst"
        return
    fi
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        warn "Backing up existing $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -sf "$src" "$dst"
    ok "Linked: $dst → $src"
}

# ── macOS: ensure Homebrew ────────────────────────────────────────────────────

install_brew() {
    if ! has brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Apple Silicon path
        [ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

# ── Package installs ──────────────────────────────────────────────────────────

install_packages_mac() {
    install_brew
    info "Installing packages via Homebrew..."

    local pkgs=(
        neovim
        tmux
        git
        zsh
        the_silver_searcher   # ag
        tig
        ripgrep               # for Telescope live_grep
        ruby
        node                  # for Mason LSP servers
        go
        # zathura and zathura-pdf-poppler available via brew if needed
        # meld available via: brew install --cask meld
    )

    for pkg in "${pkgs[@]}"; do
        # skip comment lines
        [[ "$pkg" == \#* ]] && continue
        if brew list --formula "$pkg" &>/dev/null 2>&1; then
            ok "Already installed: $pkg"
        else
            info "Installing $pkg..."
            brew install "$pkg" || warn "Failed to install $pkg — continuing"
        fi
    done

    if $INSTALL_LATEX; then
        info "Installing MacTeX (this is large, ~5 GB)..."
        brew install --cask mactex || warn "MacTeX install failed — install manually from tug.org/mactex"
    fi

    # Nerd Font for nvim-tree / lualine glyphs
    install_nerd_font_mac

    # Python neovim provider
    install_pynvim_mac
}

install_packages_linux() {
    if ! has apt-get; then
        die "Non-apt Linux detected. Install packages manually."
    fi

    info "Updating apt..."
    sudo apt-get update -qq

    local pkgs=(
        git
        zsh
        tmux
        vim                   # keep classic vim alongside neovim
        silversearcher-ag
        tig
        ripgrep               # for Telescope live_grep
        ruby
        xclip                 # clipboard support in neovim
        curl
        wget
        unzip
        fonts-font-awesome
    )

    info "Installing apt packages..."
    sudo apt-get install -y "${pkgs[@]}" || warn "Some apt packages failed — continuing"

    # i3 desktop (Linux-only)
    if [[ "${DISPLAY:-}" != "" ]] || [[ "${WAYLAND_DISPLAY:-}" != "" ]]; then
        info "Graphical session detected — installing i3 environment..."
        sudo apt-get install -y i3 i3blocks compton rofi zathura || warn "i3 packages failed"
    else
        warn "No display detected — skipping i3/zathura install"
    fi

    if $INSTALL_LATEX; then
        info "Installing TeX Live (texlive-full — this is large)..."
        warn "Run: sudo apt-get install -y texlive-full"
        warn "Or for a smaller install: sudo apt-get install -y texlive-latex-extra latexmk"
        warn "Skipping automatic install to avoid a lengthy download. Re-run with --latex to confirm."
        # Uncomment to actually install:
        # sudo apt-get install -y texlive-full latexmk
    fi

    install_neovim_linux
    install_node_linux
    install_nerd_font_linux
    install_pynvim_linux
}

# ── Nerd Font (devicon glyphs for nvim-tree / lualine) ────────────────────────

install_nerd_font_mac() {
    if brew list --cask font-hack-nerd-font &>/dev/null 2>&1; then
        ok "Already installed: font-hack-nerd-font"
    else
        info "Installing Hack Nerd Font..."
        brew install --cask font-hack-nerd-font || warn "Nerd Font install failed — install a Nerd Font manually"
    fi
    warn "Set your terminal's font to 'Hack Nerd Font' so nvim-tree/lualine icons render"
}

install_nerd_font_linux() {
    local font_dir="$HOME/.local/share/fonts"
    if ls "$font_dir"/HackNerdFont* &>/dev/null 2>&1; then
        ok "Hack Nerd Font already installed"
        return
    fi
    info "Installing Hack Nerd Font..."
    local tmp
    tmp="$(mktemp -d)"
    if curl -fLo "$tmp/Hack.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"; then
        mkdir -p "$font_dir"
        unzip -oq "$tmp/Hack.zip" -d "$font_dir" || warn "Failed to unzip Nerd Font"
        has fc-cache && fc-cache -f "$font_dir" >/dev/null 2>&1
        ok "Hack Nerd Font installed to $font_dir"
    else
        warn "Nerd Font download failed — install a Nerd Font manually from nerdfonts.com"
    fi
    rm -rf "$tmp"
    warn "Set your terminal's font to 'Hack Nerd Font' so nvim-tree/lualine icons render"
}

# ── Neovim: Linux install from GitHub releases ────────────────────────────────

install_neovim_linux() {
    if has nvim; then
        local ver
        ver="$(nvim --version | head -1)"
        ok "Neovim already installed: $ver"
        return
    fi

    info "Installing Neovim from GitHub releases..."
    local nvim_ver
    nvim_ver="$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)"

    local tmp
    tmp="$(mktemp -d)"
    curl -fLo "$tmp/nvim.tar.gz" \
        "https://github.com/neovim/neovim/releases/download/${nvim_ver}/nvim-linux-x86_64.tar.gz"
    tar xzf "$tmp/nvim.tar.gz" -C "$tmp"
    mkdir -p "$HOME/.local"
    # Remove old install if present
    rm -rf "$HOME/.local/nvim"
    mv "$tmp/nvim-linux-x86_64" "$HOME/.local/nvim"
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.local/nvim/bin/nvim" "$HOME/.local/bin/nvim"
    rm -rf "$tmp"
    ok "Neovim ${nvim_ver} installed to ~/.local/bin/nvim"
    warn "Ensure ~/.local/bin is in your PATH (added to .zshrc by install_links)"
}

# ── Node.js: Linux via NodeSource ─────────────────────────────────────────────

install_node_linux() {
    if has node; then
        local node_ver
        node_ver="$(node --version)"
        # check if version is >=14 (Mason requirement)
        local major
        major="$(echo "$node_ver" | tr -d 'v' | cut -d. -f1)"
        if [ "$major" -ge 14 ]; then
            ok "Node.js already installed: $node_ver"
            return
        fi
        warn "Node.js $node_ver is too old (need >=14) — reinstalling via NodeSource..."
    else
        info "Installing Node.js LTS via NodeSource..."
    fi

    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    ok "Node.js $(node --version) installed"
}

# ── Python neovim provider ────────────────────────────────────────────────────

install_pynvim_mac() {
    if has pip3 || python3 -m pip --version &>/dev/null 2>&1; then
        info "Installing pynvim..."
        pip3 install --upgrade pynvim 2>/dev/null || python3 -m pip install --upgrade pynvim || warn "pynvim install failed"
        ok "pynvim installed"
    else
        warn "pip not found — skipping pynvim (run: pip3 install pynvim)"
    fi
}

install_pynvim_linux() {
    # Ensure pip is available
    if ! python3 -m pip --version &>/dev/null 2>&1; then
        info "Installing pip..."
        python3 -m ensurepip --upgrade 2>/dev/null \
            || sudo apt-get install -y python3-pip \
            || warn "Could not install pip"
    fi

    if python3 -m pip --version &>/dev/null 2>&1; then
        info "Installing pynvim..."
        python3 -m pip install --user --upgrade pynvim || warn "pynvim install failed"
        ok "pynvim installed"
    else
        warn "pip unavailable — skipping pynvim"
    fi
}

# ── tmuxinator (gem) ──────────────────────────────────────────────────────────

install_tmuxinator() {
    if has tmuxinator; then
        ok "tmuxinator already installed"
        return
    fi
    if has gem; then
        info "Installing tmuxinator gem..."
        gem install tmuxinator || warn "tmuxinator install failed"
    else
        warn "gem not found — skipping tmuxinator"
    fi
}

# ── Dotfile symlinks ──────────────────────────────────────────────────────────

install_links() {
    info "Creating dotfile symlinks..."

    # Home directory dotfiles (relative symlinks matching existing style)
    symlink "$DOTFILES/.aliases"   "$HOME/.aliases"
    symlink "$DOTFILES/.vimrc"     "$HOME/.vimrc"
    symlink "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
    symlink "$DOTFILES/.zshrc"     "$HOME/.zshrc"

    # ~/.config/ entries (absolute symlinks matching existing style)
    symlink "$DOTFILES/nvim"            "$HOME/.config/nvim"
    symlink "$DOTFILES/zathura/zathurarc" "$HOME/.config/zathura/zathurarc"

    # Linux-only
    if [[ "$OS" == "Linux" ]]; then
        symlink "$DOTFILES/i3/config"              "$HOME/.config/i3/config"
        symlink "$DOTFILES/i3blocks/i3blocks.conf" "$HOME/.config/i3blocks/i3blocks.conf"
        symlink "$DOTFILES/compton"                "$HOME/.config/compton"
    fi

    # Ensure ~/.local/bin is in PATH (Linux: nvim lives here)
    if [[ "$OS" == "Linux" ]]; then
        if ! grep -q '\.local/bin' "$HOME/.zshrc" 2>/dev/null; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
            ok "Added ~/.local/bin to PATH in .zshrc"
        fi
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo "  dotted_wrdes bootstrap — $(date '+%Y-%m-%d')"
    echo "  OS: $OS"
    echo ""

    if ! $LINKS_ONLY; then
        case "$OS" in
            Darwin) install_packages_mac ;;
            Linux)  install_packages_linux ;;
            *)      die "Unsupported OS: $OS" ;;
        esac
        install_tmuxinator
    fi

    install_links

    echo ""
    info "Done. Reload your shell:  exec zsh"
    if has nvim || [ -f "$HOME/.local/bin/nvim" ]; then
        info "First Neovim launch will auto-install plugins via lazy.nvim."
    fi
    if $INSTALL_LATEX; then
        warn "LaTeX: vimtex uses latexmk — ensure it is on your PATH after install."
    fi
}

main
