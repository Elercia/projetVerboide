#!/bin/bash
if [ "$#" -eq 1 ]; then
	filenameComplete=$1
	encoding=$( file $filenameComplete --mime-encoding -b | cat)
	langueArray=( "en" "es" "de" "it" "ru" "fr")
	
	#on convertit en utf-8
	iconv -f $encoding $filenameComplete |
	#on enleve tous les caractères ci-dessous
	sed "s/\«/ /g" |
	sed "s/\»/ /g" |
	sed "s/\°/ /g" |
	tr '[:punct:]' ' ' |
	tr '[:digit:]' ' '|
	#on remplace les espaces par les retours à la ligne 
	tr " " "\012" | 
	tr "\t" " " |
	#on met les mots en minuscule
	tr '[:upper:]' '[:lower:]' > tmp

	contentBeforeStopwords=$(cat tmp)
	for i in "${langueArray[@]}"
	do
		stopwordsfilePath="Stopwords/stopwords_$i.txt"
		echo "$contentBeforeStopwords" > tmp2
		temp=$(grep -Fvxf $stopwordsfilePath tmp2)
		contentBeforeStopwords=$temp
	done
	#on trie
	echo "$contentBeforeStopwords" > tmp2
	sort tmp2 |
	#enleve les lignes vides
	sed '/^$/d' |
	#enleve les mots de 1 lettre
	sed '/^.$/d' |
	tr '[:space:]' '\n' > fileContent.txt
	
	#on cherche le nombre d'occurences le plus elevé
	
	langueReconnue=""
	occurenceMax=0
	currentOccu=-1
	for i in "${langueArray[@]}"
	do
		#comparer avec Samples/sample$i.txt
		#on recupere le resultat de grep (nombre d'occurences)
		#si le resultat est plus grand que l'ancien alors 
		#on le remplace et on met à jour la variable de langue
		fileToRead="Samples/sample_$i.txt"
		
		currentOccu=`grep -Fxf ./fileContent.txt $fileToRead | wc -l` 
		
		if [ $currentOccu -gt $occurenceMax ]
		then
			occurenceMax=$currentOccu
			langueReconnue=$i
		fi
	done

	#on affiche la langue reconnue
	echo "La langue reconnue est : $langueReconnue"
	
	#on compte les mots
	uniq -c < fileContent.txt |
	#on trie par nombre d'occurences puis l'affiche
	sort -nb -r > tmp
	lines=$(head -n 7 tmp)
	lines=${lines//[[:digit:]]/}
	lines=${lines//[$'\t\r ']/}
	lines=${lines//[$'\n']/, } 
	echo "Les mots les plus utilisé du texte sont : $lines" 
	
	#On supprime les fichiers temporaires que l'on a utilisé
	rm tmp
	rm tmp2
	rm fileContent.txt
else
	echo "Usage ./script_verboide.sh <file_to_check>"
fi