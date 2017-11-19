# Always install
vim
tmux
zathura
silversearcher-ag
git
xclip
zsh

## i3 Requirements
i3
i3blocks
compton
rofi

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

