UNAME=$(uname)
source $HOME/.commonfuncs

# Log dir hash
hash -d L=/var/log
hash -d P=$HOME/work/projects

[ -d /usr/local/etc/rc.d ] && hash -d R=/usr/local/etc/rc.d
[ -d /var/db/zope ] && hash -d Z=/var/db/zope
[ -d /data ] && hash -d Z=/data

# OS X specific settings
if [ $UNAME = "Darwin" ]; then
    # set up dir hashes
    hash -d PP=$HOME/work/presentation
    hash -d S=$HOME/Sites
    hash -d D=$HOME/Documents

    # Set up global aliases for copy / pasting in tmux
    if checkPath reattach-to-user-namespace && [ -n "$TMUX" ]; then
        alias -g pbcopy="reattach-to-user-namespace pbcopy"
        alias -g pbpaste="reattach-to-user-namespace pbpaste"
    fi

fi

# set up common aliases between shells
source $HOME/.commonrc

## global aliases
# disable the plonesite part in a buildout run, example: $ bin/buildout -N psef
alias -g psef="plonesite:enabled=false"
# replace the plonesite in a buildout run, example: $ bin/buildout -N pssr
alias -g pssr="plonesite:site-replace=true"
# easily get to the site packages dir of any python install, example: $ cd $(python2.5 site-packages)
alias -g site-packages='-c "from distutils.sysconfig import get_python_lib; print get_python_lib()"'
# SVN repos
# 
# NOTE: you can expand aliases with "_expand_alias"
#       see bindkey for more info $ bindkey -M viins
alias -g spriv='https://svn.sixfeetup.com/svn/private/'
alias -g spub='https://svn.sixfeetup.com/svn/public/'
alias -g scollective='https://svn.plone.org/svn/collective/'
alias -g sgit='https://git.sixfeetup.com/git/'

# some pipes
if [ $UNAME = "Darwin" ]; then
  alias -g S='| sed -Ee'
  alias -g SP='| sed -n -Ee'
else
  alias -g S='| sed -re'
  alias -g SP='| sed -n -re'
fi
alias -g A='| awk'
alias -g G='| grep -Ei'
alias -g C='| cut'
alias -g CF='| cut -d" " -f'
alias -g L='| less'
alias -g M='| more'
alias -g H='| head'
alias -g T='| tail'
alias -g W='| wc'
alias -g WL='| wc -l'

# copying
if checkPath pbcopy; then
    alias -g CP='| pbcopy'
elif checkPath xsel; then
    alias -g CP='| xsel'
elif checkPath xclip; then
    alias -g CP='| xclip'
fi

# Diffing
if checkPath colordiff; then
    alias -g CD='| colordiff'
else
    alias -g CD='| vim -R "+syntax on" -'
fi
alias -g pretty_json="| python -mjson.tool | vim -R +'set ft=javascript' -"

# moreutils
alias -g VI='| vipe'
alias -g TS='| ts -i'

# fuzzy finder
alias -g FZ='| fzf -m'
alias -g FZF='| fzf -m'

# cvs setup
export CVSROOT=:pserver:clayton@cvs:/var/cvsroot

# automatically print timing statistics if the command took longer
# than a minute
export REPORTTIME=60

setopt NO_BEEP
# Changing Directories
setopt AUTO_CD 
setopt CDABLE_VARS
setopt AUTO_PUSHD
setopt PUSHDMINUS
setopt PUSHD_IGNORE_DUPS
# Include dot files in globbing
# use the following to ignore dot files: % ^.*
setopt GLOB_DOTS

# History
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY
alias histappend="fc -AI"
alias histread="fc -R"

# Look for a command that started like the one starting on the command line.
# taken from: http://www.xsteve.at/prg/zsh/.zshrc (not sure of original source)
function history-search-end {
    integer ocursor=$CURSOR

    if [[ $LASTWIDGET = history-beginning-search-*-end ]]; then
      # Last widget called set $hbs_pos.
      CURSOR=$hbs_pos
    else
      hbs_pos=$CURSOR
    fi

    if zle .${WIDGET%-end}; then
      # success, go to end of line
      zle .end-of-line
    else
      # failure, restore position
      CURSOR=$ocursor
      return 1
    fi
}

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# set up the history-complete-older and newer
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# use vi mode
bindkey -v

# Use jj for ESC
bindkey "jj" vi-cmd-mode
bindkey "jk" vi-cmd-mode
# use home and end in addition to ^e and ^a
bindkey -M viins '^A' vi-beginning-of-line
bindkey -M viins '^E' vi-end-of-line
bindkey -M viins '^[[H' vi-beginning-of-line
bindkey -M viins '^[[F' vi-end-of-line
# use delete as forward delete
bindkey -M viins '\e[3~' vi-delete-char
# line buffer
bindkey -M viins '^B' push-line-or-edit
# change the '-' for up in history, always kills my command editing.
bindkey -M vicmd '^[OA' vi-up-line-or-history
# Make sure that shift-tab doesn't take me out of insert mode. going to the
# end of the line will work 99% of the time.
bindkey -M viins '^[[Z' vi-end-of-line
# change the shortcut for expand alias
bindkey -M viins '^X' _expand_alias
# Search backwards with a pattern
bindkey -M vicmd '^R' history-incremental-pattern-search-backward
bindkey -M vicmd '^F' history-incremental-pattern-search-forward
# set up for insert mode too
bindkey -M viins '^R' history-incremental-pattern-search-backward
bindkey -M viins '^F' history-incremental-pattern-search-forward
# complete previous occurences of the command up till now on the command line
bindkey -M viins "^[OA" history-beginning-search-backward-end
bindkey -M viins "^[[A" history-beginning-search-backward-end
bindkey -M vicmd "k" history-beginning-search-backward-end
bindkey -M vicmd "j" history-beginning-search-backward-end
bindkey -M viins "^N" up-line-or-search
bindkey -M viins "^[OB" history-beginning-search-forward-end
bindkey -M viins "^[[B" history-beginning-search-forward-end
bindkey -M viins "^P" down-line-or-search

# edit current command in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# set up history
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
export HISTFILE HISTSIZE SAVEHIST

# Append history after 30 minutes of inactivity
export TMOUT=900
function TRAPALRM() { histappend }

## old style completions
# supervisor
if checkPath supervisorctl; then
    # set up completions for supervisor
    compctl -s "$(supervisorctl status >/dev/null 2>&1 | awk -F' ' '{print $1}')" supervisorctl
fi
# zope
compctl -s 'fg kill start logreopen reload shell status wait help logtail restart show stop' zeoserver zeoctl
compctl -s 'fg kill start logreopen reload shell status wait help logtail restart show stop run adduser test debug' instance zopectl

# gitify completion
compctl -s 'fetch gitify help h push update up' gitify

# noguivm completions
compctl -s '$(\ls -d $VM_LIBRARY/*.vmwarevm | sed -e "s|$VM_LIBRARY/||" -e "s/.vmwarevm//")' noguivm
compctl -s '$(\ls /opt/local/share/games/fortune | grep .dat | sed "s/.dat//")' fortune makeMeLaugh lulz

## Completions
autoload -U compinit
compinit -C

# make sure git-achievements can complete like git
compdef git-achievements=git

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

if checkPath git and checkPath python; then
    # Make git status information available
    export ZSH_THEME_GIT_PROMPT_NOCACHE="True"
    source ~/.zsh/git-prompt/gitstatus.sh
else
    alias git_super_status='echo'
fi

# use some crazy ass shell prompt
# thanks to for the basis: http://aperiodic.net/phil/prompt/
ME="clayton"
source ~/.zshprompt

# load up per environment extras
source ~/.zshextras

# Load up some plugins and enhancments
autoload -U is-at-least
if [ -z $MY_ZSH_PLUGINS_LOADED ] && is-at-least 4.3; then
    # sourcing these plugins again can cause issues, this var will
    # stop that from happening
    MY_ZSH_PLUGINS_LOADED="true"

    source $HOME/.zsh.d/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source $HOME/.zsh.d/opp.zsh
    source $HOME/.zsh.d/opp/[^.]*

    # Set up zsh highlighters
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor root)
    # set up command line syntax highlighting overrides
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
    ZSH_HIGHLIGHT_STYLES[function]='fg=green,underline'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=black,bg=green'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=yellow,underline'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=white,bold,bg=blue'
    ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=white,bold,bg=blue'
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
