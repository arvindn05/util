#!/bin/sh

# Originally modified from http://blog.eflow.org/archives/tag/java
# Loops over all the *.properties files within a folder, enumerates the keys 
# in each of the properties files and recursively looks for the keys with prefixes of ' OR " OR {
# and prints them out if they are not referenced anywhere in the projects.
# Results are printed to stdout. No files will be changed by the util.
#
# use:
# ./findUnusedProperties.sh src/main/resources/ [skipPrompts]
# if skipPromts is specified, no prompts are given. Useful if recursive grep is taking a long time
if [ -z "$1" ]; then
	echo "Please provide folder to scan: Correct usage is: ./findUnusedProp.sh src/main/resources/"
	exit
fi
skipPrompts=${2:-false}

propFilesFolder=`pwd`/$1
propFiles=`ls $propFilesFolder*.properties`
for propfile in $propFiles
do
	if [ $skipPrompts = false ]; then
		read -n 1 -p "Do you want to scan the file $propfile (y/n)?" choice
		if [ "$choice" != "y" ]; then
			echo
			continue;
		fi
	fi
	echo
	props=`grep -v "#" $propfile | awk -F= '{print $1}'`
	count=0
	total=0

	echo "These property keys were not found in the code base: $propfile"
	for prop in $props
	do
		#echo “Looking for property: $prop”
		if [ ! -z "$prop" ]; then

			total=`expr $total + 1`
			# echo grep -re [\'\"\{]$prop[\'\"] *
			# Any strings starting with ' OR " OR { (for properties in spring file in format ${foo:100}) and the property key.
			output=`grep -re [\'\"\{]$prop *`
			# TODO:arvindn Optimize the grep call by providing the keys to search as a file input.
			if [ -z "$output" ]; then
				echo "$prop"
				count=`expr $count + 1`
			fi
		fi
	done

	echo "done! Found $count possibly uneeded message keys in $propfile (out of $total total keys)"
	echo '#############################################################################'
	echo '#############################################################################'
	if [ $skipPrompts = false ]; then
		echo "Press any key to continue...."
		read -n 1 -s
	fi
done
