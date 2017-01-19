#!/bin/bash
if [ "$#" -eq 1 ]; then
	filenameComplete=$1
	encoding=$( file $filenameComplete --mime-encoding -b | cat)
	langueArray=("fr" "en" "es" "de" "it" "ru")
	
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
	tr '[:upper:]' '[:lower:]' > tmp

	contentBeforeSample=`cat tmp`
	for i in "${langueArray[@]}"
	do
		#on enleve les stop word fr et en (au cas ou) 
		samplefilePath="Stopwords/stopwords_$i.txt"
		echo "$contentBeforeSample" > tmp2
		temp=$(fgrep -v -w -f $samplefilePath < tmp2)
		contentBeforeSample=$temp
	done
	#on tri (ché po)
	echo "$contentBeforeSample" > tmp2
	sort tmp2 |
	#enleve les lignes vides
	sed '/^$/d' |
	#enleve les mots de 1 lettre
	sed '/^.$/d' |
	tr '[:space:]' '\n' > fileContent.txt

	#on cherche le nombre d'occurence le plus elevé
	
	langueReconnue=""
	occurenceMax=0
	currentOccu=-1
	for i in "${langueArray[@]}"
	do
		#comparer avec Samples/sample$i.txt
		#recup result de grep
		#si plus grand que ancien plus grand remplacer
		#ramplacer la var de langue
		#afficher
		fileToRead="Samples/sample_$i.txt"
		
		currentOccu=`grep -Fxf ./fileContent.txt $fileToRead | wc -l` 
		
		if [ $currentOccu -gt $occurenceMax ]
		then
			occurenceMax=$currentOccu
			langueReconnue=$i
		fi
	done

	echo "La langue reconnue est : $langueReconnue"
	
	#compte les mots
	uniq -c < fileContent.txt |
	#on tri par nb d'occurence et on save
	sort -nb -r > tmp
	lines=$(head -n 7 tmp)
	lines=${lines//[[:digit:]]/}
	lines=${lines//[$'\t\r ']/}
	lines=${lines//[$'\n']/, } 
	echo "Les mots les plus utilisé du texte sont : $lines" 
	
	# #On suppime les ficier temporaire que l'on a utilisé
	rm tmp
	rm tmp2
	rm fileContent.txt
else
	echo "Usage ./script_verboide.sh <file_to_check>"
fi
