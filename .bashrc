# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions

# Display Settings
PS1='\e[32;1m\u@\h: \e[31m\W\e[0m\$ '


# No duplicates in the History
export HISTCONTROL=erasedups
HISTSIZE=10000
HISTFILESIZE=100000

# Editor
export EDITOR=vim

# Aliases
alias ecl="eclipse"
alias lsall="ls -la"
alias ls="ls --color=auto"
alias e="vim"
alias delf="rm -rf"
alias com="gcc -o"
alias ~="cd ~"
alias ...="cd ../../.."
