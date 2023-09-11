#!/bin/sh

alias ls='ls -h'
alias ll='ls -l'
alias la='ls -al'

# Source configuration files from /etc/profile.d
for i in /etc/profile.d/*.sh ; do
	if [ -r "$i" ]; then
		. $i
	fi
	unset i
done

export EDITOR='/bin/nano'
export VISUAL='/bin/nano'
export PS1='$(whoami)@$(hostname):$(pwd)$ '

if [ "$PS1" ]; then
	if [ "`id -u`" -eq 0 ]; then
		export PS1='\e[0;31mcfsos>\e[m # '
	else
		export PS1='\e[0;31mcfsos>\e[m $ '
	fi
fi

