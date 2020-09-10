#!/bin/bash

# Searches for credentials in the files found by cloud_enum in the cloud
# Start with: cloud_enum -k <KEYWORD> -t 10 -m <MUTATIONS_DICT> -b <BRUTEFORCE_DICT> -l <REPORT_FILE>
# Provide the cloud_enum report to this script as: CloudCredSearch.sh <cloud_enum_report_file> <credentials_search_report_file_to_be_generated>

# tune temp folder path here
tempfold="/tmp/CCSearch-$RANDOM"

# define keywords to search for (you can use of the proposed strings or add your)
# keywarr=(passw usern login logon secret pwd= userid pwd: pass= pass: user: user= accesskey accountname accountkey)
# keywarr=(passw secret pwd= pwd: pass= pass: accesskey accountkey)
keywarr=(passw accountkey)


if [ -z $1 ]
then
read -p "Enter the path to the cloud_enum found objects list: " listfile

	if [ -z $listfile ]
	then
	echo "You have not entered the cloud_enum found objects list path, neither provided it as an argument."
	read -p "Quiting. Press any key"
	exit
	fi
else
listfile=$1
fi

if [ -z $2 ]
then
read -p "Enter the path and name for the report file: " repfile

	if [ -z $repfile ]
	then
	echo "You have not entered the report file path and name, neither provided it as an argument."
	read -p "Quiting. Press any key"
	exit
	fi
else
repfile=$2
fi

mkdir $tempfold
touch $repfile

while IFS= read -r line
do
strline=$line

	if [[ (${strline:0:2} == "->") && (${strline,,} != *".jpg") && (${strline,,} != *".png") && (${strline,,} != *".exe") && (${strline,,} != *".gif") && (${strline,,} != *".pdf") && (${strline,,} != *".mp4") && (${strline,,} != *".jpeg") && (${strline,,} != *".mpg") ]] # exclude extensions here
	then
	strfile=$(echo $strline | cut -c3-)
	wget -t 3 -T 3 $strfile -P "$tempfold/"
	lfile="$tempfold/${strfile##*/}"
	extension="${lfile##*.}"
	extension=$(echo "${extension,,}") # to lowercase

	if [[ $extension == "zip" ]] # handling zip archives
	then
	unzip -p -aa $lfile >> "$lfile.txt"
	rm -f $lfile
	lfile="$lfile.txt"
	fi
		
	while IFS= read -r fline
	do
		cline=$(echo "${fline,,}") # to lowercase	
		for keywrd in ${keywarr[*]}
		do	
			keywrd=$(echo "${keywrd,,}") # to lowercase			
			if [[ $cline == *"$keywrd"* ]]
			then
			cline=$(echo $cline | xargs -0) # trimming
			fline=$(echo $fline | xargs -0) # trimming
			kwposarr=$(echo $cline | grep -b -o $keywrd | awk 'BEGIN {FS=":"}{print $1}')
			for kwpos in ${kwposarr[*]}
			do
				echo -e "FILE: $strfile\nKEYWORD: $keywrd\nSTRING (occurance + 300 characters): ${fline:$kwpos:300}\n\n" >> $repfile
			done
			fi
		done
	done < $lfile

	rm -f $lfile
	fi

done < $listfile
rmdir $tempfold
echo "Done"
