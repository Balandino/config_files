# Created by newuser for 5.7.1
#
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

##############################################
# Install zinit plugin manager and source it #
##############################################
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"


##################
# Add in Plugins #
##################
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab


# Load completions
autoload -U compinit && compinit


###########
# Aliases #
###########
alias ls='ls --color'
alias ll='ls -l --color'
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

###########
# Options #
###########
eval "$(fzf --zsh)" # Integrate fzf with zsh and 'Ctrl + R' to search
# eval "$(/opt/homebrew/bin/brew shellenv)" # UNCOMMENT FOR MacOS ONLY, adds homebrew apps to path

setxkbmap -layout gb,ru
setxkbmap -option 'grp:alt_shift_toggle'

zle_highlight+=(paste:none)   # Remove highlighting when pasting into the shell

set COLORFGBG="default;default" # Required for neomutt background
export COLORFGBG                # Required for neomutt background

###########
# History #
###########

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space

#############
#  NordVpn  #
#############
# Nord Instructions
#
# Already Done?
#:: In order to enable nordvpn you have to start the following service:
#     sudo systemctl enable --now nordvpnd
#:: You have to add yourself to the nordvpn group:
#     sudo gpasswd -a USERNAME nordvpn
#:: You then have to restart for the group to be created:
#     reboot


# Worked for me
# sudo systemctl start nordvpn.service
# nordvpn login
# nordvpn connect United_Kingdom

###########
# zstyle #
###########
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Case-insensitive matching on history
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Colours on completions
zstyle ':completion:*' menu no # Stop menu showing so fzf tab can takeover
zstyle ':fzf-tab:copmplete:cd:*' fzf-preview 'ls --color $realpath'

###########
# Keymaps #
###########

# History searching
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

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

nf(){
   if [ "$#" -ne 1 ]; then
      echo "The name of at least one file to search for must be enterd"
   fi

   # Get Array of find results
   IFS=$'\n'
   results=($(find ./ -name "*$1*"))
   unset IFS
   num_results=${#results[@]}

   # Otherwise menu will be huge
   if [ $num_results -gt 9 ]; then
      echo "Too many results found, narrower search term required"
      return
   fi

   # 1 Match - launch nvim
   if [ $num_results -eq 1 ]; then
      cd $(dirname "${results[1]}")
      nvim $(basename "${results[1]}")
      return
   fi

   # Multiple matches, outut menu for user choice
   count=0
   echo
   for result in $results; do
      echo "${count}) ${result}"
      count=$(($count+1))
   done

   echo
   echo -n "Choice: "
   read choice

   # Avoid invalid input
   if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
      echo "Choice must be a number from 0 - 9"
      return
   fi

   # Compensate for 1-based array in zsh
   choice=$(($choice+1))

   # Launch nvim
   cd $(dirname "${results[$choice]}")
   nvim $(basename "${results[$choice]}")
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


#########################
# Ending Configurations #
#########################

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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

