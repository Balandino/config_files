#!/bin/zsh

if [ "$#" -ne 1 ]; then
   echo "Enter the name of at least 1 instance"
fi

data=$(cat output.json)

# Case insensitive
search_term=$(echo $1 | tr '[:upper:]' '[:lower:]')

# Convert JSON rows to an array for iteration
tmp=$(echo $data | jq ".[] | select(.Name | ascii_downcase | contains("\"$search_term\"")) | .Name, .Value")
tmp=$(echo $tmp | tr -d '"')
links=(${(f)tmp})

# Get number of entries in array
num_links=${#links[@]}

# No matches, exit
if [[ $num_links -eq 0 ]]; then
   echo "No matches found"
   echo
   return
fi

# Probably too many to display, force user to refine search
if [[ $num_links -gt 20 ]]; then
   echo "Too many matches found, refine search"
   return
fi

# One match (Name & Link), confirm to user
if [[ $num_links -eq 2 ]]; then
   echo "Confirmation"
   echo
   echo "Instance: $links[1]"
   echo "    Link: $links[2]"
   echo
   if read -q "choice?Press Y/y to connect: "; then
      echo
      echo "Connecting!"
      return
   fi
   return
fi

# Multiple matches at this point, display to user for confirmation
count=1
option=0
echo "Multiple matches found:"
echo
for link in $links; do
   echo "$option) $links[$count] ($links[((count +1))])"
   count=$((count + 2)) # Jumps by 2 to cover each 'pair' of Name & Link
   option=$((option + 1)) # Used to signify the number the user will have to enter

   # Exit array when all options covered
   if [ $count -ge $num_links ]; then
      break;
   fi
done

echo
echo "n) Exit"
echo
echo -n "Choice: "
read choice

if [[ "$choice" == 'n' ]]; then
   echo
   return
fi

# Avoid invalid input
if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
   echo "Choice must be a number only"
   return
fi

# Remember arrays are 1 based in zsh and this array
# and that this array has the name in one cell and the link
# in the next one, so data is essentially in pairs
if [ $choice -eq 0 ]; then
   choice=1
else
   choice=$((($choice * 2) + 1))
fi

echo $links[$choice]
echo $links[(($choice +1))]
