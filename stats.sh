#!/bin/bash

#une expression reguliere qui verifie les options
REGEX="^[-]+(.)*$"

#efface l'ecran
function efface_ecran {
	echo `clear`
}

#Affichage de l'aide si l'utilisateur le demande
function affiche_aide {
	efface_ecran
	# l'utilisateur demande l'aide
	echo -e "\033[1;33m Aide du script LangStat"
	echo -e " =======================\033[0m"
	echo
	echo -e " \033[1;30;47mDESCRIPTION\033[0m"
	echo
	echo -e " \033[0;37mCe script vous permet d'effectuer des statistiques concernant le nombre d'occurence de chaque lettre dans un fichier texte\033[0m"
	echo
	echo -e " \033[1;30;47mOPTIONS\033[0m"
	echo 
	echo -e "		\033[1;31m--multi\033[0m\033[0;37m	:	lancer l'analyse et statistique de plusieurs fichiers en meme temps\033[0m"
	echo -e "		\033[1;31m--aide\033[0m\033[0;37m	:	Ouvrire la page d'aide\033[0m"
	echo
	echo -e " \033[1;30;47mEXEMPLES\033[0m"
	echo 
	echo -e "		\033[0;37m./langstat.sh fichier\033[0m"
	echo 
	echo -e "		\033[0;37m./langstat.sh --multi fichier1 fichier2 fichier3 ... fichierN\033[0m"
	echo 
	echo -e "		\033[0;37m./langstat.sh --aide\033[0m"
	echo
}

#recupere le nombre de caracteres dans tout le fichier, utilise pour le calcul de la progression des stats 
function nombre_caractere {
	echo `wc -c $1  | sed -e 's/^[ \t]*//' | cut -d" " -f1` 
} 

#intialise  le tableau des resultats 
function int_tab_resultat {
	lettres=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
}

#avoir la position d'une lettre dans l'alphabet, e tdonc j'aurai sa position dans le tableau des resultats
function postion_lettre {
    echo 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'| awk -v lettre=$1 'match($0,lettre){print RSTART}'
}

#affiche le caractere qui correspond a la position renseigne
function affiche_caractere {
    echo $(printf \\$(printf '%03o' $(($1+65))))
}

#Afficher le tableau des stats
function affiche_resultat {
	i=0
	while [ $i -lt 26 ];
	do
        caractere=$(affiche_caractere  $i)
		echo ${lettres[$i]}"  =  "$caractere 
		let i+=1
	done 
}

#c'est la que ca se passe, le traitement du fichier pour calculer les stats
function traite_fichier {
	if [ -e $1 ];
	then
        int_tab_resultat
        echo -e "\033[1;30;47m$1\033[0m"
        compteur=0
        while [ $compteur -lt 26 ];
        do
            caractere=$(affiche_caractere $compteur)
            lettres[$compteur]=`grep -o $caractere $1 |wc -l`
            progression=`bc -l <<< "($compteur/(${#lettres[*]}-1))*100" | cut -d"." -f1`
            if [ -z $progression ];
            then
                let "progression=0"
            fi
            echo -ne "Progression : $progression%\r"
            let "compteur=$compteur+1"
        done < "$1"
        echo
        echo "Statistiques effectue !!"
        echo "==========================="
        echo "Resultat :"
		affiche_resultat | sort -r -n
        echo
	else
		echo -e "Fichier \033[1;31m$1\033[0m introuvable"
	fi
}

if [ ! -z $1 ] && [ $1 = "--aide" ];
then
	affiche_aide
elif [ $# -lt 1 ] || [ -z $1 ];
then
	echo "Le nom du fichier est OBLIGATOIRE !!"
	echo "Saisissez './langstat.sh --aide' ou pour avoir de l'aide"
else
	if [ $1 = "--multi" ] || [ $1 = "-m" ];
	then
		shift
		echo -e "\033[1;31m!!! ATTENTION !!! : \033[0mSuivant la taille des fichiers, le traitement risque d'etre +/- long. Soyez patient ;-)"
        echo ""
        if [ $1 ];
		then
			while [ $1 ]
			do
				traite_fichier $1
				echo
				shift
			done
		else
			echo -e "\033[1;31mParametres manquants : \033[0mFournissez au moins un fichier a anlyser SVP"
		fi
	elif [[ $1 =~ $REGEX ]];
	then
		echo -e "\033[1;31mCommande inconnu : \033[0mVeuiller lire le manuel en tapant --aide dans les options"
	elif [ ! -e $1 ];
	then
		echo -e "\033[1;31mERREUR </404> : \033[0mFichier introuveable"
	else 
        echo -e "\033[1;31m!!! ATTENTION !!! : \033[0mSuivant la taille des fichiers, le traitement risque d'etre +/- long. Soyez patient ;-)"
		traite_fichier $1
	fi
fi
