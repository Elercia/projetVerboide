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
	fgrep -v -w -f Stopwords/stopwords_fr.txt |
	fgrep -v -w -f Stopwords/stopwords_en.txt |
	fgrep -v -w -f Stopwords/stopwords_es.txt |
	fgrep -v -w -f Stopwords/stopwords_de.txt |
	fgrep -v -w -f Stopwords/stopwords_it.txt |
	fgrep -v -w -f Stopwords/stopwords_ru.txt |
	#on tri (ché po)
	sort |
	#enleve les lignes vides
	sed '/^$/d' |
	#enleve les mots de 1 lettre
	sed '/^.$/d' > tmp

	content=$(tr '[:space:]' '\n' < tmp)
	tr '[:space:]' '\n' < tmp > fileContent

	#on cherche le nombre d'occurence le plus elevé
	langueArray=("fr" "en" "es" "de" "it" "ru")
	langueReconnue=""
	occurenceMax=-1
	for i in "${langueArray[@]}"
	do
		#comparer avec Samples/sample$i.txt
		#recup result de comm
		#si plus grand que ancien plus grand remplacer
		#ramplacer la var de langue
		#afficher
		fileToRead=$(cat "Samples/sample_$i.txt")
		currentOccu=comm -12 fileContent $fileToRead | wc -l
		echo $currentOccu
		if [ currentOccu > occurenceMax ]
		then
		        occurenceMax=currentOccu
		        langueReconnue=$i
		fi
	done
	echo "La langue reconnue est : $langueReconnue"





	#compte les mots
	#uniq -c |
	#on tri par nb d'occurence et on save
	#sort -nb -r > $fileToSave
	
	# echo comm Samples/sample_fr fileContent
	#On suppime les ficier temporaire que l'on a utilisé
	rm tmp
	rm fileContent
	echo "Sauvegardé sous le nom $fileToSave"
else
	echo "Usage ./script_verboide.sh <file_to_check>"
fi
