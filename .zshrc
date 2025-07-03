# Launch Hyprland only on the first tty
[[ -z $DISPLAY && $(tty) == /dev/tty1 ]] && exec Hyprland

# --- Paths & env ---
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export ANDROID_HOME="$HOME/Android/Sdk"
export NDK_HOME="$ANDROID_HOME/ndk/28.0.12433566"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$BUN_INSTALL/bin:$PNPM_HOME"
export BAT_THEME="base16"
export EDITOR="nvim"
export SUDO_EDITOR="nvim"

# --- History ---
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY SHARE_HISTORY HIST_FCNTL_LOCK EXTENDED_HISTORY HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# --- Completions path ---
[[ :$FPATH: == *:$HOME/.zsh/completions:* ]] || export FPATH="$HOME/.zsh/completions:$FPATH"

# --- Antidote plugin manager ---
[[ -f $HOME/.antidote/antidote.zsh ]] || git clone --depth=1 https://github.com/mattmc3/antidote.git $HOME/.antidote
source "$HOME/.antidote/antidote.zsh"
ZSH_PLUGINS_FILE="$HOME/.zsh_plugins"
[[ -f $ZSH_PLUGINS_FILE ]] || cat <<'EOF' > "$ZSH_PLUGINS_FILE"
zsh-users/zsh-autosuggestions
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-completions
Aloxaf/fzf-tab
jimhester/per-directory-history
EOF
antidote load "$ZSH_PLUGINS_FILE"

# --- Prompt & utils ---
command -v starship >/dev/null && eval "$(starship init zsh)"
[[ -s "$HOME/.atuin/bin/env" ]] && { . "$HOME/.atuin/bin/env"; eval "$(atuin init zsh --disable-up-arrow)"; }
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# --- Aliases ---
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'batcat --style=numbers --color=always {}'"
alias fd='fdfind'
alias cd='z'
alias cs='cht.sh'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias n='nvim'
alias g='git'
alias d='docker'
alias bat='batcat'
alias lzg='lazygit'
alias lzd='lazydocker'
alias fman='compgen -c | fzf | xargs man'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias fix_fkeys='echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode'

# --- Functions ---
y() {
  local tmp="$(mktemp -t 'yazi-cwd.XXXXXX')" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(<"$tmp")" && [[ -n $cwd && $cwd != $PWD ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

aiso2sd() {
  (( $# == 2 )) || { echo "Usage: iso2sd <input_file> <output_device>"; return 1; }
  sudo dd bs=4M status=progress oflag=sync if="$1" of="$2" && sudo eject "$2"
}

web2app() {
  (( $# == 3 )) || { echo "Usage: web2app <AppName> <AppURL> <IconURL>"; return 1; }
  local app="$1" url="$2" icon_url="$3"
  local icon_dir="$HOME/.local/share/applications/icons"
  local desktop="$HOME/.local/share/applications/${app}.desktop"
  local icon_path="${icon_dir}/${app}.png"
  mkdir -p "$icon_dir" && curl -sL -o "$icon_path" "$icon_url" || return 1
  cat > "$desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=$app
Exec=chromium --new-window --ozone-platform=wayland --app="$url" --name="$app" --class="$app"
Terminal=false
Type=Application
Icon=$icon_path
StartupNotify=true
EOF
  chmod +x "$desktop"
}

web2app-remove() {
  (( $# == 1 )) || { echo "Usage: web2app-remove <AppName>"; return 1; }
  rm -f "$HOME/.local/share/applications/${1}.desktop" "$HOME/.local/share/applications/icons/${1}.png"
}

# --- Completion init (deferred) ---
zmodload zsh/complist
[[ -n $ZSH_COMPDUMP_LOADED ]] || { autoload -Uz compinit && compinit -d "$HOME/.zcompdump" -C; ZSH_COMPDUMP_LOADED=1 }

# --- mise ---
eval "$(/home/aman/.local/bin/mise activate zsh)"
