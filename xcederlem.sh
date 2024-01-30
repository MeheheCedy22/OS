#!/bin/bash
#
# Meno: Marek Čederle
# Kruzok: Streda 19:00 - Laštinec
# Datum: 10.12.2023
# Zadanie: zadanie07
#
# Text zadania:
#
# V zadanych adresaroch uvedenych ako argumenty najdite textove subory,
# v ktorych obsahu sa vyskytuje ich meno. Prehladavajte vsetky zadane adresare
# a aj ich podadresare.
# Ak nebude uvedena ako argument ziadna cesta, prehladava sa aktualny pracovny
# adresar (teda .).
# Ak bude skript spusteny s prepinacom -d <hlbka>, prehlada adresare len do
# hlbky <hlbka> (vratane). Hlbka znamena pocet adresarov na ceste medzi
# startovacim adresarom a spracovavanym suborom. Hlbka 1 znamena, ze bude
# prezerat subory len v priamo zadanych adresaroch.
#
# Syntax:
# zadanie.sh [-h][-d <hlbka>] [cesta ...]
#
# Vystup ma tvar:
# Output: '<cesta k najdenemu suboru> <pocet riadkov s menom suboru>'
#
# Priklad vystupu:
# Output: '/public/testovaci_adresar/testdir1/test 19'
#
# Program musi osetrovat pocet a spravnost argumentov. Program musi mat help,
# ktory sa vypise pri zadani argumentu -h a ma tvar:
# Meno programu (C) meno autora
#
# Usage: <meno_programu> <arg1> <arg2> ...
#    <arg1>: xxxxxx
#    <arg2>: yyyyy
#
# Parametre uvedene v <> treba nahradit skutocnymi hodnotami.
# Ked ma skript prehladavat adresare, tak vzdy treba prehladat vsetky zadane
# adresare a vsetky ich podadresare do hlbky.
# Pri hladani maxim alebo minim treba vzdy najst maximum (minimum) vo vsetkych
# zadanych adresaroch (suboroch) spolu. Ked viacero suborov (adresarov, ...)
# splna maximum (minimum), treba vypisat vsetky.
#
# Korektny vystup programu musi ist na standardny vystup (stdout).
# Chybovy vystup programu by mal ist na chybovy vystup (stderr).
# Chybovy vystup musi mat tvar (vratane apostrofov):
# Error: 'adresar, subor, ... pri ktorom nastala chyba': popis chyby ...
# Ak program pouziva nejake pomocne vypisy, musia mat tvar:
# Debug: vypis ...
#
# Poznamky:
#
# - Pre zapnutie/vypnutie debug vystupu prepiste premennu DEBUG na true/false.
#
# Riesenie:


help() {
    echo "$(basename "$0") (C) Marek Čederle"
    echo ""
    echo "Usage: $(basename "$0") [-h] [-d <depth>] [path ...]"
    echo "-h - This help message"
    echo "-d <depth> - Depth to search (optional)"
    echo "path - Directories to search (optional)"
}

isNum() {
    local check=$1
    
    if [ "$debug" = true ]; then
        echo "Debug: isNum: '$check'"
    fi
    
    if [[ "$check" =~ ^[0-9]+$ ]]; then
        return 0 # true (0 is good return value)
    else
        return 1 # false
    fi
}

search_text_in_files() {
    local search_dir="$1"
    local depth="$2"
    
    if [ "$debug" = true ]; then
        echo "Debug: search_dir: '$search_dir'"
        echo "Debug: depth: '$depth'"
    fi
    
    if [ -d "$search_dir" ]; then
        while IFS= read -r -d '' file; do
            count=$(grep -c "$(basename "$file")" "$file")

            if [ "$count" -gt 0 ]; then
                echo "Output: '$file $count'"
            fi
        done < <(find "$search_dir" -maxdepth "$depth" -type f -name '*.txt' -print0 2> >(sed 's/find/Error/g' >&2))
    else
        echo "Error: '$search_dir': is not a valid directory." >&2
        exit 1
    fi
}

# ----- Start of the script -----

debug=false # Debug mode off by default

depth=999999 # Default depth
search_dir="." # Default search directory

if [ "$debug" = true ]; then
    echo "Working directory: '$(pwd)'"
fi

# Parse command-line options
while getopts ":hd:" opt; do
    
    if [ "$debug" = true ]; then
        echo "Debug: \$opt \$OPTARG"
        echo "Debug: $opt $OPTARG"
    fi
    
    case $opt in
        h)
            help
            exit 0
        ;;
        d)
            if isNum "$OPTARG"; then
                depth="$OPTARG"
            else
                echo "Error: '-$opt': depth must be a natural number" >&2
                exit 1
            fi
            
            if [ "$depth" -lt 1 ]; then
                echo "Error: '-$opt': depth must be greater than 0" >&2
                exit 1
            fi
        ;;
        #    Checks if the argument after -d is empty
        :)
            echo "Error: '-$OPTARG': argument must not be empty" >&2
            exit 1
        ;;
        \?)
            echo "Error: '-$OPTARG': is not valid argument" >&2
            exit 1
        ;;
    esac
done


# Remove parsed options from the arguments
shift $((OPTIND-1))


# Print all remaining arguments
if [ "$debug" = true ]; then
    for arg do
        echo "Debug: Remaining argument: '$arg'"
    done
fi

# If there are no arguments left, search in the default (current) directory
if [ $# -eq 0 ]; then
    search_text_in_files "$search_dir" "$depth"
    exit 0
fi

# If there are any arguments left, use them as search directories
while [ $# -gt 0 ]; do
    search_text_in_files "$1" "$depth"
    shift
done
