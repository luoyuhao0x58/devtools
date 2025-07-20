# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

set_custom_prompt() {
    local bg='\[\e[103m\]'
    local time_color='\[\e[33;1m\]'
    local dir_color='\[\e[34;1m\]'
    local git_color='\[\e[35;1m\]'
    local dollar_color='\[\e[33;1m\]'
    local reset='\[\e[0m\]'
    local italics='\[\e[3m\]'
    local p2_4c='\[\e[36m\]'

    _exitstatus_bg() {
        if [[ $? != 0 ]]; then
            echo -ne '\e[41m'
        else
            echo -ne '\e[42m'
        fi
    }

    _venv_prompt() {
        local text=""
        if [ -n "$VIRTUAL_ENV_PROMPT" ]; then
            text="$VIRTUAL_ENV_PROMPT"
        elif [ -n "$VIRTUAL_ENV" ]; then
            text="$(basename "$VIRTUAL_ENV")"
        fi
        if [ -n "$text" ]; then
            printf '\e[90m(%s)\e[0m ' $text
        else
            echo -n ''
        fi
    }

    PS1="\n\$(_exitstatus_bg)${time_color}[\t]${reset} ${dir_color}\W${italics}${git_color}\$(__git_ps1 \" (%s)\" 2>/dev/null)${reset}\n\$(_venv_prompt)${dollar_color}\\\$${reset} "

    PS2="${p2_4c}>${reset} "
    PS4="${p2_4c}+${reset} "
}

if [ "$color_prompt" = yes ]; then
    set_custom_prompt
else
    PS1='\n[\t] \W$(__git_ps1 " (%s)" 2>/dev/null)\n\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export SUDO_PS1=$PS1
    export PROMPT=$PS1

    export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
    export LESS='-R --quit-at-eof'
    # 可选：设置 less 使用的默认颜色（例如，搜索高亮）
    export LESS_TERMCAP_so=$'\E[01;44;33m'  # 设置搜索高亮为蓝底黄字
    export LESS_TERMCAP_se=$'\E[0m'         # 重置搜索高亮的样式
    # 以下主要用于美化 man 手册的显示颜色 :cite[1]:cite[5]:cite[8]
    export LESS_TERMCAP_mb=$'\E[01;31m'     # 闪烁文本 (起始)
    export LESS_TERMCAP_md=$'\E[01;36m'     # 粗体/标题 (起始) - 改为青色
    export LESS_TERMCAP_me=$'\E[0m'         # 所有特效重置 (终止)
    export LESS_TERMCAP_us=$'\E[04;33m'     # 下划线文本 (起始) - 改为黄色下划线
    export LESS_TERMCAP_ue=$'\E[0m'         # 下划线终止
    export LESS_TERMCAP_so=$'\E[01;44;33m'  # 突出模式 (起始) - 蓝底黄字
    export LESS_TERMCAP_se=$'\E[0m'         # 突出模式终止

    export GCC_COLORS="error=01;31:warning=01;35:note=01;36"
    alias tree='tree -C'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export VIRTUAL_ENV_DISABLE_PROMPT=1