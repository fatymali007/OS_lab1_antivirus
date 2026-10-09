#!/bin/bash

flagged_extensions=("exe" "bat" "vbs" "scr" "ps1")
flagged_content=("virus" "trojan" "malware" "worm" "ransomware")

scandir()
{
	dir=$1
	mal_dir=$2
	for file in "$dir"/*
	do
		mal=false

		extension="${file##*.}"

		for flag in "${flagged_extensions[@]}"
		do
			if [ "$extension" = "$flag" ]
			then
				mal=true
				break
			fi
		done
		for fword in "${flagged_content[@]}"
                do
                        if grep -qi "$fword" "$file"
                        then
				mal=true
				break
			fi
		done
		if [ "$mal" = true ]
		then
			echo "$file is malicious and it is DELETED"
			mv "$file" "$mal_dir"
		fi
	done
}

scandir "$1" "$2"
ls -l "$1" > directory-info.last

while true
do
	sleep "$3"
	ls -l "$1" >directory-info.new

	if ! cmp -s directory-info.last directory-info.new
	then
		scandir "$1" "$2"
	fi

	cp directory-info.new directory-info.last
done 
