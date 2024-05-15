#!/bin/bash

if [[ "$(pwd)" != *rcs ]]; then
    echo "Please cd into rcs repository root before running this."
    exit 1
fi

linux=$(uname | grep -q Linux && echo 0)
mac=$(uname | grep -q Darwin && echo 0)

which curl > /dev/null || sudo apt install curl
which pyenv > /dev/null || curl https://pyenv.run | bash

mkdir -p ~/dev/awsprof
curl https://gist.githubusercontent.com/puhitaku/d6f3284107abead3ad9f/raw/842b87983d7e11c6c892e4a9900a8a2828c1deac/awsprof.py > ~/dev/awsprof/awsprof
chmod +x ~/dev/awsprof/awsprof

ln -s $(pwd)/rc.sh ~/rc.sh
ln -s $(pwd)/.tmux.conf ~/.tmux.conf

if [ $linux ]; then
    ln -s $(pwd)/.tmux.conf.linux ~/.tmux.conf.linux
elif [ $mac ]; then
    ln -s $(pwd)/.tmux.conf.mac ~/.tmux.conf.mac
else
    echo "Warning: no OS-dependent .tmux.conf is not installed for $(uname)."
fi


ln -s $(pwd)/.vimrc ~/.vimrc
git submodule update --init  # pull vim packages
ln -s $(pwd)/vim ~/.vim

ln -s $(pwd)/.gitconfig ~/.gitconfig || true  # gitconfig may already exist
ln -s $(pwd)/.inputrc ~/.inputrc
ln -s $(pwd)/.minirc.dfl ~/.minirc.dfl

mkdir -p ~/.config/kitty/
ln -s $(pwd)/kitty.conf ~/.config/kitty/kitty.conf

mkdir -p ~/.config/peco/
ln -s $(pwd)/peco_config.json ~/.config/peco/config.json

mkdir -p ~/.ipython/profile_default
ln -s $(pwd)/ipython_config.py ~/.ipython/profile_default/ipython_config.py

ln -s $(pwd)/.tigrc ~/.tigrc
