alias ls="ls -G"
alias nb="ipython notebook --browser=firefox"

alias lpcc="enscript --pretty-print --color"
alias cleantex="rm *.bbl *.aux *.blg *.log *.out *.*~"

alias cboot="dpkg --list | grep linux-image | awk '{ print $2 }' | sort -V | sed -n '/'`uname -r`'/q;p' | xargs sudo apt-get -y purge"
alias sos="pacmd set-card-profile 0 output:analog-stereo"
alias pss="gnome-screenshot -a"
######################################################################
###############               git          ###########################
######################################################################
alias g='git'
alias gs='g s'
alias gl='g l'

alias gca='git commit -v -a'
alias gst='git status'
alias gco='git checkout'
alias glg='git log --stat --max-count=5'
alias ga='git add'
alias gd='git diff'

alias gup='git fetch && git rebase'
alias gp='git push'
alias gc='git commit -v'
#alias gcm='git checkout master'
alias gb='git branch'
alias gba='git branch -a'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias glgg='git log --graph --max-count=5'
alias gss='git status -s'
alias gm='git merge'
alias gpush='git push origin master'
alias gpull='git pull origin master'

export WORKON_HOME=~/.venvs
source /home/simon/.local/bin/virtualenvwrapper.sh
