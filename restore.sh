#!/bin/bash

listfiles()
{
	malfiles=("$@")
	if [ ${#malfiles[@]} -eq 0 ]
	then
		printf "No malicious files to review \n"
		exit 0
	fi

	i=0
	printf "Malicious files:\n"
	for file in "${malfiles[@]}"
	do
		((i++))
		printf " $i) $file\n"
	done
	read -p "Enter selected file by its index:" index
	if (( index <= i && index >= 1 )) && [[ "$index" =~ ^[0-9]+$ ]]
	then
		return "$index"
	else
		printf "**INVALID INDEX**\n"
		return 0
	fi
}
Restorefile()
{
	pick=$1
	dest=$2
	printf "Restoring $pick to $dest\n"
        if mv "$pick" "$dest"
	then
        	printf "Restored $pick to $dest\n"
	else
		printf "RESTORE FAILED\n"
	fi
}
Deletefile(){
	pick=$1
	printf "Are you sure you want to delete $pick ?\n"
                read -p "(y/n)?" confirm
                if [ "$confirm" = "y" ]
                then
                        rm "$pick"
                        printf "$pick permenantly deleted\n"
                else
                        return 0
                fi
}

dir=$1
maldir=$2
#when the directory is empty the literal name along with the glob operator are stored as first entry and in teh code considered first file.
shopt -s nullglob
#this disables that and shows the drectory is empty.when it is enabled the array doesnt contain teh literal by default.
malfiles=("$maldir"/*)

listfiles "${malfiles[@]}"
idx=$?

if [ "$idx" -eq 0 ]
then
	exec "$0" "$@"
else
	pick="${malfiles[$((idx-1))]}"
fi

printf "Enter action:\n[1]Restore this file back into dir (it was a false positive)\n[2]Permanently delete this file from malicious_dir (it was genuinely malicious)\n[3]Leave this file as-is and go back to the list\n"
read -p "Choice:" choice

if [[ ! "$choice" =~ ^[1-3]$ ]]
then
	printf "INVALID CHOICE\n"
	printf "Back to main...\n*********\n"
	exec "$0" "$@"
fi

if [ "$choice" -eq 1 ]
then
	Restorefile "$pick" "$dir"
	printf "Back to main...\n*********\n"
	exec "$0" "$@"
else
	if [ "$choice" -eq 2 ]
	then
		Deletefile "$pick"
		act=$?
		if [ "$act" -eq 0 ]
		then
			printf "Back to main...\n*********\n"
                        exec "$0" "$@"
		fi
	else
		printf "Back to main...\n*********\n"
		exec "$0" "$@"
	fi
fi

