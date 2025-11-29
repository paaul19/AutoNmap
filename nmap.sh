#!/bin/bash

# Verificacion
if [ -z "$1" ]; then
    echo "Uso: $0 <IP>"
    exit 1
fi

IP="$1"
TEMP_FILE=$(mktemp)

echo -e "\e[1;36m[*] Iniciando escaneo de puertos abiertos en $IP...\e[0m"

# Primer escaneo
nmap --open -sS --min-rate 5000 -vvv -n "$IP" -oG "$TEMP_FILE" > /dev/null

# Extraer puertos abiertos
OPEN_PORTS=$(grep -oP '\d+/open' "$TEMP_FILE" | cut -d'/' -f1 | tr '\n' ',' | sed 's/,$//')

if [ -z "$OPEN_PORTS" ]; then
    echo -e "\e[1;31m[!] No se encontraron puertos abiertos.\e[0m"
    rm "$TEMP_FILE"
    exit 0
fi

echo -e "\e[1;32m[+] Puertos abiertos encontrados: $OPEN_PORTS\e[0m"

echo -e "\e[1;36m[*] Iniciando escaneo de servicios (esto puede tardar un ratillo)...\e[0m"

# Segundo escaneo
nmap -sV -Pn -p"$OPEN_PORTS" "$IP" | grep -E '^(PORT|Service Info:)|^[0-9]+/tcp'

# Limpiar
rm "$TEMP_FILE"
