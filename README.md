rcs
===

[a-z.]+rc and so on


Bootstrap
---------

```sh
#!/bin/sh

cd
brew install git ghq wget bash peco ag  # On Mac
apt install git
wget https://raw.githubusercontent.com/puhitaku/rcs/master/.gitconfig
mkdir ~/dev
ghq get git@github.com:puhitaku/rcs.git
cd ~/dev/github.com/puhitaku/rcs
./bootstrap.sh
```


slack-term.json
---------------

Copy it into `~/.config/slack-term/{workspace_name}` and follow [the official instruction](https://github.com/erroneousboat/slack-term/wiki) to get your token. Replace the `slack_token` value with it.

