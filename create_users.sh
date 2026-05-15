#!/bin/bash

# Kontrollera root-behörighet (UID 0)
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Detta script måste köras som root."
    exit 1
fi

# Loopa igenom alla användarnamn som skickas som argument
for username in "$@"; do
    
    # Skapa användare med hemkatalog
    if useradd -m "$username"; then
        echo "Användare $username skapad."
    else
        echo "Kunde inte skapa $username."
        continue
    fi

    # Sökväg till hemkatalogen
    user_home="/home/$username"

    # Skapa mappar
    mkdir -p "$user_home/Documents" "$user_home/Downloads" "$user_home/Work"
    
    # Sätt rättigheter (Endast ägare får läsa/skriva/exekvera)
    chmod 700 "$user_home/Documents" "$user_home/Downloads" "$user_home/Work"
    
    WELCOME_FILE="$user_home/welcome.txt"
    echo "Välkommen $username" > "$WELCOME_FILE"
    cut -d: -f1 /etc/passwd | sort >> "$WELCOME_FILE"
    
    # Ändra ägare till den nya användaren
    chown -R "$username:$username" "$user_home"
done


