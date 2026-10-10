This shell script is a simplified antivirus daemon that runs in the backround when innvocated, scanning target directories for malicious files periodically between equal predefined intervals.

WHAT FILES ARE CONSIDERED MALICIOUS:
------------------------------------

• Flagged extension: the file's extension matches one of the following, hardcoded exactly as written: .exe, .bat, .vbs,
.scr, .ps1.
• Flagged content: the file's contents contain one of the following keywords (case-insensitive), hardcoded exactly as
written: virus, trojan, malware, worm, ransomware

SCRIPTS AND CODES:
======================

There are 2 scripts included in this project along with a Makefile.

SCRIPT 1: "antivirusd.sh" :
---------------------------

This script is the script associated with PART1 of the assignment.
parameters: antivirusd.sh <target_directory> <malicious_directory> <time_interval_in_seconds>

In the execution of this script, it first scans the target directory for any malicious files using the local function scandir which takes the target directory and loops through its files comparing every file's extention to the array of flagged extensions and checking the contents of every file for any flagged content using grep command.

If a malicious file is detected, it is moved to malicious_dir and a message informs the user that this file has been deleted.

The script writes in a file the list of all the files included in the traget directory in long form { output of ls -l command } which is saved as last modification info.

The script runs infinitly scanning the target directory at certain predefined intervals until the script excution is stopped.
During the loop's execution, a new file is created with the most recent run of the ls -l command. this is the new modification info.

Both files are compared using the condition { !cmp -s directory-info.last directory-info.new} command which returns 0 if the files are identical, 1 if the files are different and more than 1 if there is an error; since shell treats 0 as success, the condition is true for different files. 'scandir' is run when a recent modification was done to the directory making the condition true.

Whether a scan was performed or not the loop waits for a specified time interval before it repeats the comparison again using {sleep "<interval_in_s>"} command.

SCRIPT 2: "restore.sh" :
------------------------

This script is the script associated with PART2 of the assignment.
parameters: restore.sh <target_dir> <malicious_dir>

In the execution of this script, the functions listfiles takes an array of the malicious directory' files as a parameter and prints an indexed list of all teh files in the directory then prompts the user to pick a file.This function returns the index of the picked file in the array or zero if the index is invalid.

The user is prompted to choose the action to be performed on the file:
1-restore the file into the target_dir.
2-permenantly delete teh file from malicious_dir.
3-leave the file as-is and go back to the list.

The restoration and deletion of the picked files are carried out by functions Restorefile and Deletefile respectively.
Restorefile takes the picked file and target_directory as parameters and teh deletefile only takes the picked file as a parameter.

This is also an infinite script, whenever any of the given operations is complted it is re-invocated and re-excuted with the same parameters using { exec "$0" "$@" }.

The script is also restarted when an invalid index or choice is incountered.

MAKEFILE: "Makefile" :
----------------------

The Makefile is an automation tool that helps running the scripts more easily. The Makefile defines commands that can be used to directly run a specific script instead of maunually typing commands to run the script.
{make} command reads the instructions in the Makefile and excutes them.

basic structure of a make command:
{target: dependancy
    command  }
The target is the name of the command we want make to execute.
Dependancy is something the command is dependant on.
The command is the actual command the Makefile will run. In this case its the execution of the scripts.

To take parameters in the Makefile some variables are defined in the beginning of the file and given default values.
{ TARGET_DIR=tester_dir
MAL_DIR=malicious_dir
INTERVAL=5  }

{.PHONY:<COMMAND_NAMES> } tells the make file that the list is all command *names* and not files or parameters.

{pre-build:} this is a command that has no dependancies and create the malicious_dir if it doesnt exist already using teh command { mkdir -p $(MAL_DIR)} 

note:
-The flag "-p" shows that the command may try to create a directory that already exists and in that case it ignores the error and doesnt replace teh original directory.

{antivirusd: pre-build} : this command runs the antivirusd.sh script and passes the variables to it.The command depends on teh excution of pre-build.

To call the command: {make antivirusd [ TARGET_DIR=<target_dir> MAL_DIR=<malicious_dir> INTERVAL=<time_in_sec>] }

{restore: pre-build} : restore also depends on pre-build for the same reason. this command passes the variables to the restore.sh script and runs it.

To call the command: {make restore [ TARGET_DIR=<target_dir> MAL_DIR=<malicious_dir>

note: {make} will only run the pre-build command since its a dependancy and will not execute any further than the first target in the makefile.

USING THE ANTIVIRUS:
====================

since both teh scripts are infinite and recursive teh run can only be stopped or suspended by the user {ex: Ctrl+C or Ctrl+Z}

Both processes cannot run simultaneously, think about it, if a file is restores the nested loop in the antivirus script will delete it again and will undo the restoration.

ARRAYS OF FLAGS:
----------------
The flagged extensions and keywords are included in the array at the very beginning of antivirusd.sh script [line 3 and 4] 

NOTES:
======

The included scripts are bash scripts {shebang : #!/bin/bash }, I chose that to be able to deal with bash arrays and conditions more easily in my code.
Bash scripts are a more specific type of shell scripts that are mainly written for bash and use similar syntax to other more familiar languages.

The glob wild card was used in these scripts which is filename-matching pattern, This {malfiles=("$maldir"/*)} gives all the files with paths starting with $maldir meaning all the files inside maldir.
If no files match (in that case directory is empty) then Bash keeps the literal pattern and in the code it is considered an element of the array of malicious files so {shopt -s nullglob} is used to ensure any unmatched pattern or empty directory amounts to no elements in the array.
