#!/bin/bash

task_file="$HOME/.tasks"
action=$1
input=$2

user-guide() {
	echo "
======================================================================
			Task Tracker (tt)
======================================================================

Task Tracker Command Usage: ./tt.sh (action) (input)

Valid actions are listed below, Input must be surrounded in quotes, see examples

User Actions:
	add	Appends a new task to your task file 
	remove	Removes an already exisiting task from your task file
	view	List all tasks currently in the file
	clear	Deletes the task file
	help	Prints this user guide
	supershow	(ADMIN ONLY) Lists ALL tasks for every user


Examples:
	./tt.sh add \"Submit Lab Report\"		- Adds "Submit Lab Report" to your task file
	./tt.sh remove \"Submit Lab Report\"	- Removes "Submit Lab Report" from your task file
	./tt.sh view				- Lists all current tasks
	./tt.sh clear				- Removes the task file (with confirmation)
	./tt.sh help				- Prints this help guide
	sudo ./tt.sh supershow           - Prints all tasks for every user (Must have sudo privelages)
	"
}

getvalidinput() {
	while [ -z "$input" ]; do
	read -p "Please provide a valid record description: " input
	done
}

printtaskfile() {
	if [ -f "$task_file" ]; then
	echo "===================="
	cat "$task_file"
	echo "===================="
	else
	echo "Task file not found"
	fi
}

super-show() {
	echo "Showing Tasks for all users:"
	echo

	for user in /home/*; do
		if [ -d "$user" ] && [ -f "$user/.tasks" ]; then
		username=$(basename "$user")
		echo "===== $username ====="
		cat "$user/.tasks"
		echo
		fi
	done

}

shopt -s nocasematch

case "$action" in

	add)
		getvalidinput
		echo "$input" >> "$task_file"
		chmod a+r "$task_file"
		echo "Task \"$input\" Successfully Added"
		;;
	remove | rem)
		getvalidinput
		if [ -f "$task_file" ] && grep -xq "$input" "$task_file"; then
		echo "Entry Found, Removing entry..."
		grep -xv "$input" "$task_file" > "$task_file.tmp" #Creates temp file to hold changes
		mv "$task_file.tmp" "$task_file" #Renames temp file to the original file
		echo "\"$input\" Successfully Removed from .tasks"
		else
		echo "Entry Not found: Exiting Program..."
		fi
		;;
	view | ls)
		echo "Listing all tasks..."
		printtaskfile
		echo "Exiting Program"
		;;
	clear) 
		read -p "Are you sure that you would like to permanently remove all tasks? (y/n): " deletePrompt
		case "$deletePrompt" in
		y | yes)
		echo "Permanently deleting all saved tasks..."
		rm -f "$task_file"
		echo "Successfully removed tasks, exiting program"
		;;
		n | no)
		echo "Smart Choice, exiting program"
		;;
		*)
		echo "Unknown input, exiting program"
		;;
		esac
		;;
	help)
		user-guide
		;;
	super-show | supershow | ss)
		super-show
		;;
	*)
		echo "Invalid Argument, Perhaps the user guide will help!"
		user-guide
		;;
esac

shopt -u nocasematch
