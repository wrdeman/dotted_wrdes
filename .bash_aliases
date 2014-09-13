alias ls="ls -G"
alias nb="ipython notebook --pylab inline --browser=firefox"
alias djs="django-admin.py runserver 0.0.0.0:8000"
alias djell="python .django-book.py"
alias lpcc="enscript --pretty-print --color"
alias cleantex="rm *.bbl *.aux *.blg *.log *.out *.*~"

if [[ "$OSTYPE" == "darwin13" ]]; then
 alias preview="open -a Preview"
 alias png2pdf="sh /scripts/png2pdf.sh"
 alias png2eps="sh /scripts/png2eps.sh"
 alias emacs="/Applications/Emacs.app/Contents/MacOS/Emacs"
 alias emacw="/Applications/Emacs.app/Contents/MacOS/Emacs -nw"
else
 alias emacw="emacs -nw"
fi
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


# _codeComplete()
# {
#     local cur=${COMP_WORDS[COMP_CWORD]}
#     COMPREPLY=( $(compgen -W "$(ls PATH/TO/DJANGO_ROOT)" -- $cur) )
# }

# complete -F _codeComplete djest
# complete -F _codeComplete django-admin.py
