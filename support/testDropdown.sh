select_folder() {
    echo "Kies een map:"
    select folder_name in */; do
        if [ -n "$folder_name" ]; then
            selected_folder="${folder_name%/}"
            break
        else
            echo "Ongeldige keuze. Probeer opnieuw."
        fi
    done
}

# Roep de functie aan om de gebruiker een map te laten selecteren
select_folder