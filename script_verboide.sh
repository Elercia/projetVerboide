#!/bin/bash
if [ "$#" -eq 1 ]; then
 filenameComplete=$1
 filename="${filenameComplete%.*}"
 fileToSave=$filename"_Occurences.txt"
 sed "s/[0-9.,:\#\;\!\(\)*\?\"\»]//g" $filenameComplete | sed "s/\[//g" | sed "s/\]//g" | tr " " "\012" | tr '[:upper:]' '[:lower:]' | iconv -f ISO-8859-1 -t ascii//TRANSLIT --verbose | grep -v -w -f stopwords.txt | sort | sed '/^$/d' | uniq -c |sort -nb -r > $fileToSave
 echo "Sauvegardé sous le nom $fileToSave"
fi
