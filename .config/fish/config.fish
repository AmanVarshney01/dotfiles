# Launch Hyprland only on the first tty
if not set -q DISPLAY; and [ (tty) = /dev/tty1 ]
    exec Hyprland
end

# --- Paths & env ---
fish_add_path $HOME/bin $HOME/.local/bin /usr/local/bin

set -gx ANDROID_HOME "$HOME/Android/Sdk"
set -gx NDK_HOME "$ANDROID_HOME/ndk/28.0.12433566"
set -gx BUN_INSTALL "$HOME/.bun"
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
fish_add_path $ANDROID_HOME/tools $ANDROID_HOME/platform-tools $BUN_INSTALL/bin $PNPM_HOME

set -gx BAT_THEME "base16"
set -gx EDITOR "nvim"
set -gx SUDO_EDITOR "nvim"

# --- History ---
set -U fish_history_length 100000

# --- Prompt & utils ---
# starship
if command -v starship >/dev/null
    starship init fish | source
end

# atuin
if command -v atuin >/dev/null
    atuin init fish --disable-up-arrow | source
end

# zoxide
if command -v zoxide >/dev/null
    zoxide init fish | source
end

# --- Aliases ---
alias ls 'eza -lh --group-directories-first --icons'
alias lsa 'ls -a'
alias lt 'eza --tree --level=2 --long --icons --git'
alias lta 'lt -a'
alias ff "fzf --preview 'bat --style=numbers --color=always {}'"
alias fd 'fdfind'
alias cd 'z'
alias cs 'cht.sh'
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias n 'nvim'
alias g 'git'
alias d 'docker'
alias lzg 'lazygit'
alias lzd 'lazydocker'
alias fman 'compgen -c | fzf | xargs man'
alias gcm 'git commit -m'
alias gcam 'git commit -a -m'
alias gcad 'git commit -a --amend'
alias fix_fkeys 'echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode'

# --- Functions ---
function y
    set -l tmp (mktemp -t 'yazi-cwd.XXXXXX')
    yazi $argv --cwd-file="$tmp"
    if set -l cwd (cat "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function aiso2sd
    if test (count $argv) -ne 2
        echo "Usage: iso2sd <input_file> <output_device>"
        return 1
    end
    sudo dd bs=4M status=progress oflag=sync if="$argv[1]" of="$argv[2]"; and sudo eject "$argv[2]"
end

function web2app
    if test (count $argv) -ne 3
        echo "Usage: web2app <AppName> <AppURL> <IconURL>"
        return 1
    end
    set -l app "$argv[1]"
    set -l url "$argv[2]"
    set -l icon_url "$argv[3]"
    set -l icon_dir "$HOME/.local/share/applications/icons"
    set -l desktop "$HOME/.local/share/applications/$app.desktop"
    set -l icon_path "$icon_dir/$app.png"

    mkdir -p "$icon_dir"; and curl -sL -o "$icon_path" "$icon_url"
    if test $status -ne 0
        return 1
    end

    echo "[Desktop Entry]
Version=1.0
Name=$app
Exec=chromium --new-window --ozone-platform=wayland --app=\"$url\" --name=\"$app\" --class=\"$app\"
Terminal=false
Type=Application
Icon=$icon_path
StartupNotify=true" > "$desktop"

    chmod +x "$desktop"
end

function web2app-remove
    if test (count $argv) -ne 1
        echo "Usage: web2app-remove <AppName>"
        return 1
    end
    rm -f "$HOME/.local/share/applications/$argv[1].desktop" "$HOME/.local/share/applications/icons/$argv[1].png"
end

# --- mise ---
if command -v mise >/dev/null
  mise activate fish | source
end
