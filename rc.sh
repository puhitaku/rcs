PS1=" \[\e[32m\]\W\[\e[0m\] \$ "

if [ "$(uname)" == "Linux" ]; then
    export DISPLAY=:0
    colorize="--color=auto"
elif [ "$(uname)" == "Darwin" ]; then
    colorize="-G"
fi

export PATH=$PATH:/sbin:/usr/sbin
export PATH=$PATH:$HOME/.pyenv/bin:$HOME/.pyenv/shims
export PATH=$PATH:$HOME/.poetry/bin
export PATH=$PATH:/usr/lib/go-1.10/bin

export GOPATH="${HOME}/dev/go"
export PATH="$PATH:$GOPATH/bin"

export LC_ALL="en_US.UTF-8"

set -o vi

# pyenv
eval "$(pyenv init -)"

# z
if [[ -x `which z` ]]; then
    source ~/dev/z/z.sh
fi

# Color Diff
if [[ -x `which colordiff` ]]; then
    alias diff='colordiff -u'
else
    alias diff='diff -u'
fi

export LESS='-R'

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
            git diff $choice
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

function gocd() {
    GO_SRC="${GOPATH}/src"
    CHOSEN=$(find ${GO_SRC} -mindepth 3 -maxdepth 3 -type d | sed -E "s|${GO_SRC}/||g" | ag -v "\.[^/]+$" | peco)
    if [ "$CHOSEN" != "" ]; then
        cd ${GO_SRC}/${CHOSEN}
    fi
}

function ttyusb() {
    if [ -n "$1" ]; then
        if [ -n "$2" ]; then
            sudo minicom -c on -D /dev/ttyUSB${1} -b ${2}
        else
            sudo minicom -c on -D /dev/ttyUSB${1} -b 115200
        fi
    else
        ls /dev/ttyUSB*
    fi
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

# Git aliases

if [ -f ~/git-completion.bash ]; then
    source ~/git-completion.bash
else
    echo "Warning: git-completion.bash not installed. Downloading."
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > ~/git-completion.bash
fi

function __reg_git_alias() {
    __git_complete $1 _git_$2
    if [ -z "$3" ]; then
        alias $1="git $2"
    else
        alias $1="git $3"
    fi
}

__reg_git_alias ga add
__reg_git_alias gap add 'add --patch'
__reg_git_alias gb branch
__reg_git_alias gc commit
__reg_git_alias gcam commit 'commit --amend -m'
__reg_git_alias gcm commit 'commit -m'
__reg_git_alias gco checkout
__reg_git_alias gd diff
__reg_git_alias gf fetch
__reg_git_alias gl log
__reg_git_alias gp push
__reg_git_alias gpo push 'push origin'
__reg_git_alias gr rebase
__reg_git_alias gst status
__reg_git_alias gt tag
alias g="git" && __git_complete g _git

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

alias le='less'
alias he='head -n20'
alias ta='tail -n20'

alias v='vim'
alias vi='vim'

alias b2s='dtc -I dtb -O dts'
alias s2b='dtc -I dts -O dtb'

alias py='python'
alias ipy='ipython'
alias pyてょn='python'
alias いpyてょn='ipython'
alias venv='python -m venv'

alias copy='xsel -ip && xsel -op | xsel -ib'
alias ca='cat'
alias du1='du -hd 1'
alias rename='tmux rename-window'
alias dk='docker'
alias umount='sudo umount'
alias ha='history | ag -o '\''^\s+[0-9]+\s+\K.*'\'' |  peco --layout=bottom-up | pbcopy'
alias minicom='minicom -c on'

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

