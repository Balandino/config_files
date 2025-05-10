# Created by newuser for 5.7.1

##################
# Configurations #
##################

unsetopt PROMPT_SP
setopt PROMPT_SUBST
PROMPT='%{$(pwd|grep --color=always /)%${#PWD}G%} %(!.%F{red}.%F{cyan})%n%f@%F{green}%m%f%(!.%F{red}.)%F{red} $%f '

setxkbmap -layout gb,ru
setxkbmap -option 'grp:alt_shift_toggle'

zle_highlight+=(paste:none)   # Remove highlighting when pasting into the shell

set COLORFGBG="default;default" # Required for neomutt background
export COLORFGBG                # Required for neomutt background


#############
#   ALIAS   #
#############

alias ll="ls -l"
alias la="ls -la"
alias cls="clear"
alias c="clear"
alias e="exit"
alias off="shutdown 0"
alias restart="shutdown -r 0"
alias sz="source ~/.zshrc"
alias zp="nvim ~/.zshrc"
alias wp="nvim ~/.wezterm.lua"
alias ap="nvim ~/.alacritty.toml"
alias iprof="nvim ~/.config/i3/config"
alias piconf="nvim ~/.config/picom/picom.conf"


# Already Done?
#:: In order to enable nordvpn you have to start the following service:
#     sudo systemctl enable --now nordvpnd
#:: You have to add yourself to the nordvpn group:
#     sudo gpasswd -a USERNAME nordvpn
#:: You then have to restart for the group to be created:
#     reboot
alias nord="sudo systemctl start nordvpnd.service && nordvpn connect US"

#############
#  KEY MAP  #
#############

# Sorts keys such as home and end
bindkey "\e[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Sets zsh into vi mode.  Have to choose between this or emacs mode?
bindkey -v

#############
# FUNCTIONS #
#############

n(){
   if [ "$#" -ne 1 ]; then
      cd ~/.config/nvim
      nvim init.lua
   else
      nvim "$#"
   fi
}

nn(){
   cd ~/.config/nvim
}

# Simplification for the install command for a simple package
install() {
   sudo pacman -S "$@"
}

upgrade(){
   sudo pacman -S archlinux-keyring
   sudo pacman -Syu
   aur sync -u
}

disk(){
   ncdu --exclude /mnt/win
}

windows(){
   sudo mount -U B2BC468BBC4649D5 /mnt/win
}

aur-remove(){
   sudo pacman -Rs "$@"
   repo-remove /home/custompkgs/custom.db.tar.gz "$@"
}

# A new version of aurutils seems to require a separate conf file
# as opposed to using the current one.  Copying the current one
# to this location resolves the problem
aur-copy-conf(){
   sudo /etc/pacman.conf /etc/aurutils/pacman-x86_64.conf
}

# Do a copy with a progress update.  Checks file size before copying so may not start immediately
copy() {
   if [ "$#" -ne 2 ]; then
      echo "Two pathways are required, a source and a destination."
   else
      rsync -a -h -r --info=progress2 --no-inc-recursive "$1" "$2"
   fi
}

vidlengths() {
   if [ "$#" -ne 1 ]; then
      echo "ERROR: 1 argument required in the form of an extension, such as mkv or mp4"
   else
      printf '%101s\n' "─" | sed 's/ /─/g'
      printf '%-91s' "Title"
      printf '| Duration \n'
      printf '%101s\n' "─" | sed 's/ /─/g'
      for file in *.$1
      do
         printf "%-90s " $file
         ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal "$file" | awk -F: '/^[0-9]+:[0-9]+:[0-9]+/ {printf "| %02d:%02d:%02d\n",$1,$2,$3}'
      done

      seconds=$(find . -maxdepth 1 -iname "*.$1" -exec ffprobe -v quiet -of csv=p=0 -show_entries format=duration {} \; | paste -sd+ -| bc)
      h=$(( seconds / 3600 ))
      m=$(( ( seconds / 60 ) % 60 ))
      s=$(( seconds % 60 ))
      printf '%101s\n' "─" | sed 's/ /─/g'
      printf '%-91s' "Total"
      printf "| %02d:%02d:%02d\n" $h $m $s
      printf '%101s\n' "─" | sed 's/ /─/g'
   fi
}

# Needed at end for zoxide
eval "$(zoxide init zsh)"


##############
# START XORG #
##############

# Initiate startx script which calls ~/.xinitrc, currently set to initiate i3
if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
   # exec startx # Without exec it is possible to close i3 and return to tty.  With exec closing i3 also triggers a restart
   startx
fi
