# shopt options ################################################################
shopt -s cdspell
shopt -s checkhash
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob
shopt -s histappend histreedit histverify
shopt -s hostcomplete
shopt -s interactive_comments
shopt -u mailwarn
shopt -s no_empty_cmd_completion
shopt -u nocaseglob
shopt -u nullglob
shopt -s progcomp
shopt -s promptvars
shopt -s sourcepath
################################################################################

# Colors #######################################################################
# Normal Colors
black='\e[0;30m'
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
blue='\e[0;34m'
purple='\e[0;35m'
cyan='\e[0;36m'
white='\e[0;37m'
# Bold
bblack='\e[1;30m'
bred='\e[1;31m'
bgreen='\e[1;32m'
byellow='\e[1;33m'
bblue='\e[1;34m'
bpurple='\e[1;35m'
bcyan='\e[1;36m'
bwhite='\e[1;37m'
# Background
on_black='\e[40m'
on_red='\e[41m'
on_green='\e[42m'
on_yellow='\e[43m'
on_blue='\e[44m'
on_purple='\e[45m'
on_cyan='\e[46m'
on_white='\e[47m'
# Color sets
creset="\e[m"
cpass=${bgreen}
cinform=${byellow}
calert=${bred}
cugent=${bred}${on_yellow}
################################################################################

# Prompt #######################################################################
#
# Format: [TIME USEP@HOST PWD] >
#
# TIME
#	green	-	machine load is low
#	yellow	-	machien load is medium
#	red		-	machine load is high
#	alert	-	machine load is critical
#
# USER
#	cyan	-	normal user
#	yellow	-	privellaged user
#	red		-	root
#
# HOST
#	cyan	-	local session
#	green	-	secure remote session
#	red		-	unsecure remote session
#
# PWD
#	green	-	more than 10% free
#	yellow	-	more than 5% free
#	alert	-	less than 5% free
#	red		-	current user does not have write privellages
#	cyan	-	current filesystem is zero bytes in size
#
# >
#	white	-	no jobs in this shell
#	cyan	-	at least one background job in progress
#	yellow	-	at least one suspended job in progress
###################################################
# Test connection type:
if [ -n "${SSH_CONNECTION}" ]; then
    CNX=${bgreen}
elif [[ "${DISPLAY%%:0*}" != "" ]]; then
    CNX=${alert}
else
    CNX=${bcyan}
fi

# Test user type:
if [[ ${USER} == "root" ]]; then
    SU=${bred}
elif groups | grep -q "wheel"; then
    SU=${byellow}
else
    SU=${bcyan}
fi

NCPU=$(grep -c 'processor' /proc/cpuinfo)
SLOAD=$(( 100*${NCPU} ))
MLOAD=$(( 200*${NCPU} ))
XLOAD=$(( 400*${NCPU} ))

load()
{
    local SYSLOAD=$(cut -d " " -f1 /proc/loadavg | tr -d '.')
    echo $((10#$SYSLOAD))
}

load_color()
{
    local SYSLOAD=$(load)
    if [ ${SYSLOAD} -gt ${XLOAD} ]; then
        echo -en ${alert}
    elif [ ${SYSLOAD} -gt ${MLOAD} ]; then
        echo -en ${bred}
    elif [ ${SYSLOAD} -gt ${SLOAD} ]; then
        echo -en ${byellow}
    else
        echo -en ${bgreen}
    fi
}

disk_color()
{
    if [ ! -w "${PWD}" ] ; then
        echo -en ${bred}
    elif [ -s "${PWD}" ] ; then
        local used=$(command df -P "$PWD" |
                   awk 'END {print $5} {sub(/%/,"")}')
        if [ ${used} -gt 95 ]; then
            echo -en ${alert}
        elif [ ${used} -gt 90 ]; then
            echo -en ${byellow}
        else
            echo -en ${bgreen}
        fi
    else
        echo -en ${bcyan}
    fi
}

job_color()
{
    if [ $(jobs -s | wc -l) -gt "0" ]; then
        echo -en ${byellow}
    elif [ $(jobs -r | wc -l) -gt "0" ] ; then
        echo -en ${bcyan}
	else
		echo -en ${bwhite}
    fi
}

PROMPT_COMMAND='history -a'
PS1="[\[\$(load_color)\]\A\[${creset}\] "
PS1=${PS1}"\[${SU}\]\u\[${creset}\]@\[${CNX}\]\h\[${creset}\] "
PS1=${PS1}"\[\$(disk_color)\]\W\[${creset}\]] "
PS1=${PS1}"\[\$(job_color)\]>\[${creset}\] "
PS1=${PS1}"\[\e]0;[\u@\h] \w\a\]"
################################################################################

# Aliases ######################################################################
alias more='less'
alias ls='ls -h --color=auto'
alias lx='ls -lXB'	#Sort by extension
alias lk='ls -lSr'	#Sort by size (ascending)
alias lt='ls -ltr'	#Sort by date, most recent last
alias lc='ls -ltcr'	#Sort by change time, most recent last
alias lu='ls -ltur'	#Sort by access time, most recent last
alias ll='ls -lv --group-directories-first'
alias lm='ll | more'
alias lr='ll -R'
alias la='ll -A'
alias l='ls -Cf'
alias tree='tree -Csuh'
alias pingg='ping -c 3 www.google.com'
alias ping8='ping -c 3 8.8.8.8'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias cls='clear; ls -h --color=auto'
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

alias du='du -kh'
alias df='df -kTh'

alias localhttp='/usr/bin/python3 -m http.server --bind 127.0.0.1 8000'
alias outhttp='/usr/bin/python3 -m http.server 8000'

alias reloadrc='source /home/haxxul/.bashrc'

# Screen Commands ##############################################################
alias hdmi-left='xrandr --output HDMI1 --auto --left-of eDP1'
alias hdmi-right='xrandr --output HDMI1 --auto --right-of eDP1'
alias hdmi-up='xrandr --output HDMI1 --auto --above eDP1'
alias hdmi-down='xrandr --output HDMI1 --auto --below eDP1'
alias hdmi-off='xrandr --output HDMI1 --off'


# Disk Mounting ################################################################
alias mountdat='udisksctl mount -b /dev/disk/by-uuid/4E01-888C'
alias unmountdat='udisksctl unmount -b /dev/disk/by-uuid/4E01-888C'

################################################################################

# Functions ####################################################################
# Create new directory and cd into it##
mkdircd() { mkdir "$1"; cd "$1"; }

# Change directory and list contents##
cdls () { cd "$1"; pwd; la; }

# Find and list files matching the specified one
ff() { find . -type f -iname '*'"$*"'*' -ls ; }

# Make a tar file
maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }

# Make a zip file
makezip() { zip -r "${1%%/}.zip" "$1" ; }

# Make files all have the same permissions
sanitize() { chmod -R u=rwX,g=,o= "$@" ;}

# Gets just the user's ps
my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }

# Kills a process based on a pattern
killps()
{
    local pid pname sig="-TERM"   # default signal
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
        echo "Usage: killps [-SIGNAL] pattern"
        return;
    fi
    if [ $# = 2 ]; then sig=$1 ; fi
    for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} )
    do
        pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
        if ask "Kill process $pid <$pname> with signal $sig?"
            then kill $sig $pid
        fi
    done
}

# Gives information about the current system
ii()
{
    echo -e "\nYou are logged on ${BRed}$HOST"
    echo -e "\n${BRed}Additionnal information:$NC " ; uname -a
    echo -e "\n${BRed}Users logged on:$NC " ; w -hs |
             cut -d " " -f1 | sort | uniq
    echo -e "\n${BRed}Current date :$NC " ; date
    echo -e "\n${BRed}Machine stats :$NC " ; uptime
    echo -e "\n${BRed}Memory stats :$NC " ; free
#    echo -e "\n${BRed}Diskspace :$NC " ; mydf / $HOME
#    echo -e "\n${BRed}Local IP Address :$NC" ; my_ip
    echo -e "\n${BRed}Open connections :$NC "; netstat -pan --inet;
    echo
}

# Repeats a specified command x number of times
repeat()
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}

# Asks the user if they want to do something
ask()
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

# Compiles C code for debugging##
gccd () { gcc -std=c99 -Wall -g -O0 "$@"; }

chext() 
{
	if [ $# == 2 ]; then
		if [ $1 == "@" ]; then
			# Change all the files file extneions to the new one
			for file in *; do
				mv "$file" "${file%%.*}$2";
			done
		else
			# Change teh specified file extensiono to the new one
			for file in *$1; do
				mv "$file" "${file%$1}$2";
			done
		fi
	elif [ $# == 1 ]; then
		# Add the file extension to the end of all files
		for file in *; do
			mv "$file" "$file$1";
		done
	else
		# Remove all file extensions
		for file in *; do
			mv "$file" "${file%%.*}";
		done
	fi
}

# Extracts any compressed file##
extract () 
{
    if [ -z "$1" ]; then
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>";
    else
        if [ -f "$1" ]; then
            echo -e "[${inform}==${creset}] extracting $1"
            NAME="${1%.*}"
            mkdir $NAME && cd $NAME
            case $1 in
                *.tar.bz2)    tar xvjf ../$1    ;;
                *.tar.gz)     tar xvzf ../$1    ;;
                *.tar.xz)     tar xvJf ../$1    ;;
                *.lzma)       unlzma ../$1      ;;
                *.bz2)        bunzip2 ../$1     ;;
                *.rar)        unrar x -ad ../$1 ;;
                *.gz)         gunzip ../$1      ;;
                *.tar)        tar xvf ../$1     ;;
                *.tbz2)       tar xvjf ../$1    ;;
                *.tgz)        tar xvzf ../$1    ;;
                *.zip)        unzip ../$1       ;;
                *.Z)          uncompress ../$1  ;;
                *.7z)         7z x ../$1        ;;
                *.xz)         unxz ../$1        ;;
                *.exe)        cabextract ../$1  ;;
                *)            echo -e "[${alert}!!${creset}] extract: $1 - unknown archive method" ;;
            esac
            echo -e "[${pass}OK${creset}] $1 extracted.";
        else
            echo -e "[${alert}!!${creset}] $1 does not exist!";
        fi
    fi
}

function minps1 () {

    PS1="\[${CNX}\]\h\[${creset}\]|"
    PS1=${PS1}"\[\$(disk_color)\]\W\[${creset}\]|"
    PS1=${PS1}"\[\$(job_color)\]>\[${creset}\] "
    PS1=${PS1}"\[\e]0;[\u@\h] \w\a\]"



}
################################################################################

# Completion ###################################################################
complete -A hostname   rsh rcp telnet rlogin ftp ping disk
complete -A export     printenv
complete -A variable   export local readonly unset
complete -A enabled    builtin
complete -A alias      alias unalias
complete -A function   function
complete -A user       su mail finger
complete -A helptopic  help
complete -A shopt      shopt
complete -A stopped -P '%' bg
complete -A job -P '%'     fg jobs disown
complete -A directory  mkdir rmdir
complete -A directory   -o default cd

# Compression
complete -f -o default -X '*.+(zip|ZIP)'  zip
complete -f -o default -X '!*.+(zip|ZIP)' unzip
complete -f -o default -X '*.+(z|Z)'      compress
complete -f -o default -X '!*.+(z|Z)'     uncompress
complete -f -o default -X '*.+(gz|GZ)'    gzip
complete -f -o default -X '!*.+(gz|GZ)'   gunzip
complete -f -o default -X '*.+(bz2|BZ2)'  bzip2
complete -f -o default -X '!*.+(bz2|BZ2)' bunzip2
complete -f -o default -X '!*.+(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract

# Documents - Postscript,pdf,dvi.....
complete -f -o default -X '!*.+(ps|PS)'  gs ghostview ps2pdf ps2ascii
complete -f -o default -X \
'!*.+(dvi|DVI)' dvips dvipdf xdvi dviselect dvitype
complete -f -o default -X '!*.+(pdf|PDF)' okular 
complete -f -o default -X '!*.@(@(?(e)ps|?(E)PS|pdf|PDF)?\
(.gz|.GZ|.bz2|.BZ2|.Z))' gv ggv
complete -f -o default -X '!*.texi*' makeinfo texi2dvi texi2html texi2pdf
complete -f -o default -X '!*.tex' tex latex slitex
complete -f -o default -X '!*.lyx' lyx
complete -f -o default -X '!*.+(htm*|HTM*)' lynx html2ps
complete -f -o default -X \
'!*.+(doc|DOC|xls|XLS|ppt|PPT|sx?|SX?|csv|CSV|od?|OD?|ott|OTT)' soffice

# Multimedia
complete -f -o default -X \
'!*.+(gif|GIF|jp*g|JP*G|bmp|BMP|xpm|XPM|png|PNG)' xv gimp ee gqview
complete -f -o default -X '!*.+(mp3|MP3)' mpg123 mpg321
complete -f -o default -X '!*.+(ogg|OGG)' ogg123
complete -f -o default -X \
'!*.@(mp[23]|MP[23]|ogg|OGG|wav|WAV|pls|\
m3u|xm|mod|s[3t]m|it|mtm|ult|flac)' xmms
complete -f -o default -X '!*.@(mp?(e)g|MP?(E)G|wma|avi|AVI|\
asf|vob|VOB|bin|dat|vcd|ps|pes|fli|viv|rm|ram|yuv|mov|MOV|qt|\
QT|wmv|mp3|MP3|ogg|OGG|ogm|OGM|mp4|MP4|wav|WAV|asx|ASX)' xine

complete -f -o default -X '!*.pl'  perl perl5
################################################################################

# Exported Variables ###########################################################
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000
export HOSTFILE=$HOME/.hosts
export PAGER='less'
export LESSOPEN='| /usr/bin/lesspipe.sh %s 2>&-'
export LESS='-i -w  -z-4 -g -e -M -X -F -R -P%t?f%f \
:stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
export EDITOR='/usr/bin/vim'
################################################################################
