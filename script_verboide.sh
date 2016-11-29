#!/bin/bash
if [ "$#" -eq 1 ]; then
	filenameComplete=$1
	filename="${filenameComplete%.*}"
	fileToSave=$filename"_Occurences.txt"
	sed "s/[0-9.,:\#\;\!\(\)*\?\"\»]//g" $filenameComplete | sed "s/\[//g" | sed "s/\]//g" | tr " " "\012" | tr '[:upper:]' '[:lower:]' | grep -v -w -f stopwords_fr.txt | sort | sed '/^$/d' | uniq -c |sort -nb -r > $fileToSave
	echo "Sauvegardé sous le nom $fileToSave"
else
	echo "Usage ./script_verboide.sh <file_to_check>"
fi
