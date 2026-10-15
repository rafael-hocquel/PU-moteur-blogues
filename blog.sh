#!/bin/bash

#################################################################################################
# Script: blog.sh                                                                               #
# Description: Script that manages a blog, from pages creation, modification, suppression       #
#              and visualization as html of pdf                                                 #
# Documentation: ./blog.sh usage                                                                #
# Authors: Zakaria Sabri - Rafaël HOCQUEL - Adrian Styzinski - S1D                              #
# Last Update: 18/12/2025                                                                       #
#################################################################################################

set -o errexit # Exit if command failed
set -o pipefail # Exit if pipe failed
set -o nounset # Exit if variable not set
IFS=$'\n\t' 

#############################################################################
# Name: showScriptUsage                                                     #
# Description: Shows script documentation                                   #
# Usage: showScriptUsage                                                    #
# Arguments: none                                                           #
# Return: none                                                              #
#############################################################################
function showScriptUsage
{
	echo "
Usage : ./blogue.sh COMMANDE [PARAMETRE]

La liste des commandes est 'editer', 'supprimer', 'lister', 'construire'

        - Éditer un document : ./blog.sh editer [PAGE]
        - Supprimer un document : ./blog.sh supprimer [PAGE]
        - Lister les documents : ./blog.sh lister
        - Générer les fichiers PDF/HTML : ./blog.sh construire
        - Visualiser le site : ./blog.sh visualiser [pdf]

La commande 'usage' affiche cette documentation
"
}

#################################################################################################
# Name: launchCorrespondingAction                                                               #
# Description: Launches the function corresponding to user command                              #
# Usage: launchCorrespondingAction [action] [option]                                            #
# Arguments: action: the action to launch (see 'usage'), option: page or option for the command #
# Return: none                                                                                  #
#################################################################################################
function launchCorrespondingAction
{
    ACTION="${1:-}"
    OPTION="${2:-}"

# Switch-case statement that runs the function corresponding to user-input
case "$ACTION" in
editer)
	editDocument "$OPTION";;
supprimer)
# Function that deletes the document given as a parameter
	deleteDocument "$OPTION";;
lister)
# Function that lists all existing markdown documents
	listPages;;
construire)
# Function that builds pdf and html version of the blog
	buildBlog;;
visualiser)
	visualizeBlog "$OPTION";;
usage)
# Function that prints out how to use this script
	showScriptUsage;;
*)
# Unknown action
	echo "[ERREUR] Commande '$ACTION' inconnue"
	showScriptUsage
	exit 1
	;;
esac
}

######################################################################################
# Name: createFolderIfNotExists                                                      #
# Description: Checks if the given folder exists or creates it if it doesn't         #
# Usage: createFolderIfNotExists folderName                                          #
# Arguments: folderName: the name of the folder to create                            #
# Return: none                                                                       #
######################################################################################
function createFolderIfNotExists
{
    NAME="$1"
    if ! test -d "$NAME"; then # If "NAME" folder does not exist
        echo "Aucun dossier \"$NAME\" trouvé, création en cours..."
        mkdir "$NAME"
        echo "Dossier \"$NAME\" crée"
    fi
}

######################################################################################
# Name: main                                                                         #
# Description: Main function of the script that do mandatory checks (folders) and    #
#                executes the given command                                          #
# Usage: main                                                                        #
# Arguments: folderName: the name of the folder to create                            #
# Return: none                                                                       #
######################################################################################
function main 
{
    createFolderIfNotExists markdown
    createFolderIfNotExists web

    # Check that script was called with parameters, otherwise we print the script usage and quit
    NUMBER_OF_PARAMETERS=$#

    # We show the script usage is script is called without any parameter
    if test $NUMBER_OF_PARAMETERS -eq 0; then
        echo "[ERREUR] 1 action est attendue"
        showScriptUsage
        exit 1
    fi

    # Transforms the action into lower_case to make script not case-sensitive
    ACTION="$1"
    OPTION="$2"

    launchCorrespondingAction "$ACTION" "$OPTION"
}



######################################################################################
# Name: findUserEditor                                                               #
# Description: Searches for the first text editor on the system and returns it       #
# Usage: findUserEditor                                                              #
# Arguments: none                                                                    #
# Return: the first text editor installed on the system or empty string if not found #
######################################################################################
function findUserEditor
{
    USER_EDITOR=""
    if ! test -z "${EDITOR:-}"; then # User has a default editor
        USER_EDITOR="$EDITOR"
    elif test -f "/usr/bin/editor"; then # User has a program named "editor"
        USER_EDITOR="/usr/bin/editor"
    else
        if which nano > /dev/null 2>&1; then # Fallback #1: User has nano
            USER_EDITOR="nano"
        elif which vim > /dev/null 2>&1; then # Fallback #2: User had vim
            USER_EDITOR="vim" 
        elif which vi > /dev/null 2>&1; then # Fallback #3: User had vi
            USER_EDITOR="vi"
        else
            echo "[ERREUR] Un éditeur de texte est attendu" >&2 
            exit 1
        fi
    fi
    echo "$USER_EDITOR"
}

#################################################################################################
# Name: listPages                                                                               #
# Description: Lists all markdown pages in the markdown folder (creates it if it doesn't exist) #
# Usage: listPages                                                                              #
# Arguments: none                                                                               #
# Return: none                                                                                  #
#################################################################################################
function listPages
{
    echo "Pages ($(find markdown -type f | wc -l)): "
    ls markdown
}

#################################################################################################
# Name: editDocument                                                                            #
# Description: Selects a text editor and allow user to edit a markdown file                     #
# Usage: editDocument [page]                                                                    #
# Arguments: page: pageName without extension                                                   #
# Return: none                                                                                  #
#################################################################################################
function editDocument
{
	USER_EDITOR=$(findUserEditor)
echo $#
    PAGE_NAME="${1:-}"
    if test -z "$PAGE_NAME"; then # No page name given
        echo "Voici les pages que vous voudriez peut-être éditer : "

        # Lists files in "markdown" directory or create one if it doesn't exists
        listPages

        echo "Quel fichier voulez vous éditer ?"
        read -r PAGE_NAME
    fi

    # If no page was given after prompt
    if test -z "$PAGE_NAME" ; then
        echo "[ERREUR] Le nom de la page ne peut pas être vide" >&2
        exit 1
    fi

    # If page name is "index" cause it might cause conflicts with the index.html file when generating HTML version of the blog
    if test "$PAGE_NAME" = "index"; then
        echo "[ERREUR] Impossible d'éditer la page \"index\" car un tel nom de page peut causer des conflits lors de la création de la page HTML du blog" >&2
        exit 1
    fi
    $USER_EDITOR "markdown/$PAGE_NAME.md"
    
}

#################################################################################################
# Name: deleteDocument                                                                          #
# Description: Deletes the given page from markdown/                                            #
# Usage: deleteDocument page                                                                    #
# Arguments: page: pageName without extension                                                   #
# Return: none                                                                                  #
#################################################################################################
function deleteDocument
{
    PAGE="${1:-}"

    if ! test -f markdown/"$PAGE.md"; then # If the file doesn't exist 
        echo "[ERREUR] Le nom d'une page existante est attendue"
    else 
        echo "Vouler vous VRAIMENT SUPPRIMER la page ${PAGE} ? [Y/n]" # Asking for confirmation
        read -r CONFIRMATION 

        lowerCaseConfirmation=$(echo "${CONFIRMATION:-}" | tr '[:upper:]' '[:lower:]') # Lower the user-input as script isn't case-sensitive
            if test "$lowerCaseConfirmation" = "n" || test "$lowerCaseConfirmation" = "no"; then # No during confirmation 
                echo "Annulation de la suppression"
                exit 2
            elif test "$lowerCaseConfirmation" = "y" || test "$lowerCaseConfirmation" = "yes" || test -z "$lowerCaseConfirmation"; then #Yes during confirmation or no parameters given 
                rm markdown/"${PAGE}.md" # Remove the page 
                echo "Page supprimée avec succès"
            else # Every other invalid choices
                echo "[ERREUR] Choix invalide"
                exit 1
            fi
    fi
}


#################################################################################################
# Name: buildBlog                                                                               #
# Description: Builds the blog (pdf and html versions) from pages located in markdown/          #
# Usage: buildBlog                                                                              #
# Arguments: none                                                                               #
# Return: none                                                                                  #
#################################################################################################
function buildBlog
{
    createFolderIfNotExists markdown

    createFolderIfNotExists web

        # Latest Modification Informations
    echo "Contenu actualisé le $(date "+%d/%m/%y") par $USER sur $HOSTNAME \\" > markdown/index.md



    # If no page was created (1 because of index.md)
    if test "$(find markdown -type f | wc -l)" -le 1; then
        echo "[ERREUR] Vous devez créer au moins une page avant de créer le blog."
        exit 1
    fi

    # Generate PDF Version
    # This lines creates a 'shellcheck' warning but adding double quotes "" does not work with pandoc
    pandoc $(find markdown/*.md | grep -v "index.md") -o blog.pdf

    # Generate HTML Version
    for FILE in markdown/*.md;
    do
        FILE_NAME=$(basename "$FILE" .md) # Extract file name without extension
        PAGE_TITLE=""

        # Do not add index.md as a link in the index.md page
        if ! test "$FILE_NAME.md" = "index.md"; then
            PAGE_TITLE="$FILE_NAME"
            echo "- [$FILE_NAME]($FILE_NAME.html) \\" >> markdown/index.md # Add link (markdown link format) into index.md with path to HTML files
        # Generate HTML File (-s to create html structure [html, header, body etc...])
            pandoc "$FILE" -so "web/$FILE_NAME.html" --metadata title="$PAGE_TITLE"
        fi


    done

    # Convert index.md to html
    pandoc markdown/index.md -so web/index.html --metadata title="Sommaire"

    echo "Blogue construit avec succès"
}

#################################################################################################
# Name: visualizeBlog                                                                           #
# Description: Opens the html version of the blog (or pdf version if 'pdf' option is given) in. #
#              the default document vizualizer of the system                                    #
# Usage: visualizeBlog [pdf]                                                                    #
# Arguments: pdf: opens the pdf version instead of the html version                             #
# Return: none                                                                                  #
#################################################################################################
function visualizeBlog
{
    PARAMETER="$(echo "${1:-}" | tr '[:upper:]' '[:lower:]')"
    if test "$PARAMETER" = "pdf"; then
        if ! test -f blog.pdf; then # If the file doesn't exist 
            echo "[ERREUR] Vous devez d'abord construire le blog avant de le visualiser dans un fichier PDF"
        else
            xdg-open blog.pdf || echo "Erreur lors de l'ouverture du PDF"
        fi
    elif test -z "$PARAMETER"; then
        if ! test -f web/index.html; then # If the file doesn't exist 
            echo "[ERREUR] Vous devez d'abord construire le blog avant de le visualiser dans un navigateur"
        else
            xdg-open web/index.html || echo "Erreur lors de l'ouverture du blog en version web"
        fi
    else
        echo "[ERREUR] Pramètre Inconnu"
    fi
}


# Main Script
ACTION=$(echo "${1:-}" | tr '[:upper:]' '[:lower:]')
OPTION="${2:-}"
main "$ACTION" "$OPTION"