PS1=" \[\e[32m\]\W\[\e[0m\] \$ "
bash -c 'echo -en "\033]0;$(echo $HOSTNAME | sed "s/\.local//g")\007"'
RCS_DIR="${HOME}/dev/rcs"

if [ "$(uname)" == "Linux" ]; then
    export DISPLAY=:0
    colorize="--color=auto"
    ttyusb_prefix="ttyUSB"
    ttyusb_minicom="sudo minicom"
elif [ "$(uname)" == "Darwin" ]; then
    complete -W '$(grep -oE "^[a-zA-Z0-9_.-]+:([^=]|$)" Makefile | sed "s/[^a-zA-Z0-9_.-]*$//" | grep -v .PHONY)' make
    colorize="-G"
    ttyusb_prefix="cu."
    ttyusb_minicom="minicom"
    export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
fi

if [ "${SSH_CLIENT}" != "" ] || [ "${SSH_TTY}" != "" ]; then
    unset DISPLAY
fi

export PATH=$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH
export PATH=$PATH:/sbin:/usr/sbin
export PATH=$PATH:$HOME/.poetry/bin
export PATH=$PATH:/usr/lib/go-1.1?/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/kitty.app/bin
export PATH=$PATH:$RCS_DIR/scripts
export PATH=$PATH:$RCS_DIR/scripts_ignore
export PATH=$PATH:$HOME/dev/mtplvcap

export PYENV_ROOT="$HOME/.pyenv"

export GO111MODULE=auto
export GOPATH="${HOME}/dev/go"
export PATH="$PATH:$GOPATH/bin"

export LC_ALL="en_US.UTF-8"

export BASH_SILENCE_DEPRECATION_WARNING=1

set -o vi

# pyenv
eval "$(pyenv init -)"
alias envsetup="pip install -U -r ${RCS_DIR}/requirements.txt"
alias ぴぇんv='pyenv'

nopyenv() {
    if [ $# = 0 ]; then
        echo "Usage: nopyenv COMMAND [ARGS]"
        return
    fi
    remove="$HOME/.pyenv/shims:"
    PATH=$(echo $PATH | sed "s+$remove++g") $@
}

# z
if [[ -x `which z 2> /dev/null` ]]; then
    source ~/dev/z/z.sh
fi

# Color Diff
if [[ -x `which colordiff 2> /dev/null` ]]; then
    alias diff='colordiff -u'
else
    alias diff='diff -u'
fi

export LESS='-R'

saver() {
    while [ 1 ]; do
        timeout 1m cmatrix -b
        sleep 0.5
        timeout 1m nyancat -ns
        sleep 0.5
    done
    clear
}

memo() {
    vim $(date +%y%m%d)_$1.md
}

function ndir() {
    if [ -n "$1" ]; then
        mkdir $1; cd $1
    else
        echo "ndir: specify directory name."
    fi
}

function gdi() {
    while [ 1 ]; do
        choice=$(git status | ag 'ed:\s*' | peco | ag -o 'ed:\s*\K.*')
        if [ ! -z $choice ]; then
            git -c core.pager=less diff --color $choice | less
        else
            return 0
        fi
    done
}

function calc() {
    python3 -c "from math import *; print( $* )"
}

function c() {
    fancy="ls -CF ${colorize}"
    if [ -z "$1" ]; then
        cd ..
        $fancy
    else
        cd "$1"
        $fancy
    fi
}

function copy() {
    if [ "$(uname)" == "Linux" ]; then
        xsel -ip
        xsel -op | xsel -ib
    elif [ "$(uname)" == "Darwin" ]; then
        pbcopy
    fi
}

function jh() {
    echo -n "cd $(pwd)" | copy
}

function gocd() {
    GO_SRC="${GOPATH}/src"
    CHOSEN=$(find ${GO_SRC} -mindepth 3 -maxdepth 3 -type d | sed -E "s|${GO_SRC}/||g" | ag -v "\.[^/]+$" | peco)
    if [ "$CHOSEN" != "" ]; then
        cd ${GO_SRC}/${CHOSEN}
    fi
}

# TODO: DRY
function dj() {
    TARGET="${HOME}/dev"
    CHOSEN=$(find ${TARGET} -mindepth 1 -maxdepth 4 -type d -o -type l | sed -E "s|${TARGET}/||g" | ag -v "\.[^/]+$" | peco)
    if [ "$CHOSEN" != "" ]; then
        cd ${TARGET}/${CHOSEN}
    fi
}

function _ttyhoge() {
    if [ -n "$1" ]; then
        if [ -n "$2" ]; then
            ${ttyusb_minicom} -c on -D /dev/${devpref}${1} -b ${2}
        else
            ${ttyusb_minicom} -c on -D /dev/${devpref}${1} -b 115200
        fi
    else
        ls /dev/${devpref}*
    fi
}

function ttyusb() {
    devpref=$ttyusb_prefix
    _ttyhoge $@
}

function ttyacm() {
    devpref=ttyACM
    _ttyhoge $@
}

function byerootfs() {
    sudo umount $1/proc
    sudo umount $1/dev/pts
    sudo umount $1/dev
    sudo umount $1/sys
}

function recoverdev() {
    sudo rm -f /dev/null /dev/zero /dev/random /dev/urandom
    sudo /bin/mknod -m 0666 /dev/random c 1 8
    sudo /bin/mknod -m 0666 /dev/urandom c 1 9
    sudo /bin/mknod -m 0666 /dev/null c 1 3 
    sudo /bin/mknod -m 0666 /dev/zero c 1 3
}

function addr2line2vi() {
    case $# in
    "2" )
        addr=$2 ;;
    "3" )
        addr=$(printf "%X" $((0x$2+0x$3))) ;;
    "*" )
        echo "Usage: addr2file2vi executable addr [offset]"
        echo "addr and offset are to be in hex."
        return 1 ;;
    esac

    out=$(addr2line -e $1 $addr)
    echo $out
    if [ "$out" == "??" ]; then
        echo "not found"
        return 1
    fi
    fn=$(echo $out | cut -d: -f1)
    line=$(echo $out | cut -d: -f2 | cut -d' ' -f1)
    vi +$line $fn
}

function mdnssh() {
    _IP=$(discover $1)
    if [ $? ]; then
        echo "Discovered: ${_IP}"
        ssh ${_IP}
    fi
}

function sshcp() {
    if [ $# -ne 3 ]; then
        echo "usage: sshcp FILEPATH [USER@]HOST OUTPATH"
        return 1
    fi
    if [ "$PORT" == "" ]; then
        cat $1 | gzip | ssh $2 "cat | gzip -d > $3"
    else
        cat $1 | gzip | ssh -p $PORT $2 "cat | gzip -d > $3"
    fi
}

function slackterm() {
    if [ $# -ne 1 ]; then
        slack-term -config ${HOME}/.config/slack-term/config.json
    else
        CONF="${HOME}/.config/slack-term/$1.json"
        echo "Configuration: ${CONF}"
        slack-term -config ${CONF}
    fi
}

function __fontify() {
    echo -n "$2 -> "
    fontify "$1" "$2" | tee /dev/tty | pbcopy
    echo
}

alias fsb='__fontify serif-b $1'
alias fsi='__fontify serif-i $1'
alias fsbi='__fontify serif-bi $1'
alias fssn='__fontify sans-serif-n $1'
alias fssb='__fontify sans-serif-b $1'
alias fssi='__fontify sans-serif-i $1'
alias fssbi='__fontify sans-serif-bi $1'
alias fscn='__fontify script-n $1'
alias fscb='__fontify script-b $1'
alias ffn='__fontify fraktur-n $1'
alias ffb='__fontify fraktur-b $1'
alias fms='__fontify monospace $1'
alias fds='__fontify double-struck $1'

# Git aliases
alias g="git"

function __reg_git_alias() {
    __git_complete $1 _git_$2
    if [ -z "$3" ]; then
        alias $1="git $2"
    else
        alias $1="git $3"
    fi
}

if [ -f ~/git-completion.bash ]; then
    source ~/git-completion.bash
    __git_complete g _git
    __reg_git_alias ga add
    __reg_git_alias gau add 'add -u'
    __reg_git_alias gap add 'add --patch'
    __reg_git_alias gb branch
    __reg_git_alias gba branch 'branch -a'
    __reg_git_alias gc commit
    __reg_git_alias gcam commit 'commit --amend -m'
    __reg_git_alias gcm commit 'commit -m'
    __reg_git_alias gco checkout
    __reg_git_alias gcop checkout 'checkout --patch'
    __reg_git_alias gcob checkout 'checkout -b'
    __reg_git_alias gd diff
    __reg_git_alias gf fetch
    __reg_git_alias gpfp pull 'pull && git fetch --prune'
    __reg_git_alias gfp fetch 'fetch --prune'
    __reg_git_alias gl log
    __reg_git_alias gp push
    __reg_git_alias gpo push 'push origin'
    __reg_git_alias gposu push 'push origin --set-upstream'
    __reg_git_alias gr rebase
    __reg_git_alias gsp stash 'stash --patch'
    __reg_git_alias gst status
    __reg_git_alias gs status
    __reg_git_alias gt tag
else
    echo "Warning: git-completion.bash not installed"
    which curl > /dev/null
    if [ $? -ne 0 ]; then
        echo "Fatal: please install curl and restart this shell"
    else
        curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > ~/git-completion.bash
        echo "Info: succeeded to download git-completion"
        echo "Info: restart this shell"
    fi
fi

alias l="ls -CF ${colorize}"
alias ls="ls -CF ${colorize}"
alias sl="ls"
alias ll="ls -lh ${colorize}"
alias la="ls -lah ${colorize}"
alias s='ls'
alias lg='ls | ag'

alias cl='clear'
alias cls='clear && s'

alias agc='ag --color'

alias fa='find . 2>/dev/null | ag'
alias fp='find . | peco'

alias ca='cat'

alias le='less'
alias he='head -n20'
alias ta='tail -n20'

alias v='vim'
alias vi='vim'

alias b2s='dtc -I dtb -O dts'
alias s2b='dtc -I dts -O dtb'

alias py='python'
alias ipy='ipython'
alias venv='python -m venv'

alias tmxu='tmux'
alias tmuxa='tmux a'

alias cぇあr='clear'
alias んpm='npm'
alias ご='go'
alias ゔぃ='vi'
alias pyてょn='python'
alias いpyてょn='ipython'
alias ぴp='pip'
alias tむx='tmux'
alias tむxあ='tmux a'
alias えぃt='exit'
alias おペン。='open .'
alias まけ='make'

alias du1='du -hd 1'
alias umount='sudo umount'
alias ha='history | ag -o '\''^\s+[0-9]+\s+\K.*'\'' | uniq | tail -r | peco --layout=bottom-up | pbcopy'
alias has='history | ag -o '\''^\s+[0-9]+\s+\K.*'\'' | sort | uniq | tail -r | peco --layout=bottom-up | pbcopy'
alias minicom='minicom -c on'

alias nowjst='date +"%Y-%m-%d %A %H:%M:%S"'
alias nowutc='date -u +"%Y-%m-%dT%H:%M:%SZ"'

alias renamewindow='tmux rename-window'

# docker
alias dk='docker'
alias dkprune='yes | docker image prune'

# kubernetes
alias ku='kubectl'
alias mku='sudo minikube kubectl'

# systemd etc.
alias nec='networkctl'
alias syc='systemctl'
alias joc='journalctl'

# AWS
alias s3='aws s3'
alias cloudformation='aws cloudformation'

# GitHub CLI
alias gho='gh repo view -w'

# enable alias expansion for sudo
alias sudo='sudo '

alias editrc='vim ~/dev/rcs/rc.sh'
alias editcustom='vim ~/custom.sh'
alias sourcerc='source ~/.bashrc'

if [ "$(pwd)" == "${HOME}" ]; then
    cd ~/dev
fi

if [ -f ~/custom.sh ]; then
    source ~/custom.sh
fi

if [ -f ~/wrttool.sh ]; then
    source ~/wrttool.sh
fi

