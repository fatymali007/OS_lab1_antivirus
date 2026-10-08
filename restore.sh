#!/bin/bash

listfiles()
{
	malfiles=("$@")
	if [ ${#malfiles[@]} -eq 0 ]
	then
		printf "No malicious files to review"
		return 0
	fi

	i=1
	printf "Malicious files:"
	for file in "${malfiles[@]}"
	do
		printf " $i) $file"
		((i++))
	done
	read -p "Enter selected file by its index:" index
	if [ "$index' -lt "$i" ]
	then
		return "$index"
	else
		printf "INVALID INDEX"
		return 0
	fi
}
Restorefile()
{
	pick=$1
	dest=$2
	printf "Restoring $pick to $dest"
        mv "$pick" "$dest"
        printf "Restored $file to $dest"
}
Deletefile(){
	pick=$1
	printf "Are you sure you want to delete $pick"
                read -p "(y/n)?" confirm
                if [ "$confirm"="y" ]
                then
                        rm "$pick"
                        printf "$pick permenantly deleted"
                else
                        return 0
                fi
}

dir=$1
maldir=$2

malfiles=("$maldir"/*)

listfiles "${malfiles[@]}"
idx=$?

if [ "$idx" -eq 0 ]
then
	exit
else
	pick="${malfiles[$idx]}"
fi

printf "Enter action:\n [1]Restore this file back into dir (it was a false positive)\n[2]Permanently delete this file from malicious_dir (it was genuinely malicious)\n[3]Leave this file as-is and go back to the list\n"
read -p "Choice:" choice
if [ "$choice" -eq 1]
then
	Restorefile "$pick" "$dir"
	printf "Back to main...\n"
	exec "$0" "$@"
else
	if [ "$choice" -eq 2 ]
	then
		Deletfile "$pick"
		act=$?
		if [ "$act" -eq 0 ]
		then
			printf "Back to main...\n"
                        exec "$0" "$@"
	fi
else
	printf "Back to main...\n"
	exec "$0" "$@"
fi
