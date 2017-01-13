#!/bin/bash
if [ "$#" -eq 1 ]; then
	filenameComplete=$1
	encoding=$( file $filenameComplete --mime-encoding -b | cat)
	
	filename="${filenameComplete%.*}"
	fileToSave=$filename"_Occurences.txt"
	#on converti en utf-8
	iconv -f $encoding $filenameComplete |
	#On enleve tous les caractères si dessous
	sed "s/\«/ /g" |
	sed "s/\»/ /g" |
	sed "s/\°/ /g" |
	tr '[:punct:]' ' ' |
	tr '[:digit:]' ' '|
	#remplace les espaces par les retour à la ligne 
	tr " " "\012" | 
	tr "\t" " " |
	#mets le mots en minuscule
	tr '[:upper:]' '[:lower:]' |
	#on enleve les stop word fr et en (au cas ou) 
	fgrep -v -w -f stopwords_fr.txt |
	fgrep -v -w -f stopwords_en.txt |
	#on tri (ché po)
	sort | 
	#enleve les lignes vides
	sed '/^$/d' |
	#compte les mots
	uniq -c |
	#on tri par nb d'occurence et on save
	sort -nb -r > $fileToSave
	echo "Sauvegardé sous le nom $fileToSave"
else
	echo "Usage ./script_verboide.sh <file_to_check>"
fi
