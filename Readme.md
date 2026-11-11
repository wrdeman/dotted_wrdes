# Always install
vim
tmux
zathura
silversearcher-ag
git
wl-clipboard
zsh

## sway Requirements (Wayland)
sway
swaybg
swayidle
swaylock
waybar
fuzzel
grim
slurp
xwayland
xdg-desktop-portal-wlr
network-manager-gnome   # nm-applet tray icon
wireplumber             # wpctl volume keys (default on PipeWire systems)

## Fonts
fonts-font-awesome

# powerline fonts
https://gist.github.com/petercossey/69ff13fe366beec4b1df7f42f5fb4faf
cd ~
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
mv PowerlineSymbols.otf ~/.fonts/
mkdir -p .config/fontconfig/conf.d #if directory doesn't exists
fc-cache -vf ~/.fonts/
mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/

