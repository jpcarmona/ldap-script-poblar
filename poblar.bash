#!/bin/bash
#Nombre del archivo: poblar.bash
#Fecha de creación: 17/11/2018
#Autor: Juan pedro Carmona Romero
#Descripción: Poblar directorio LDAP con usuarios

# Empezamos bucle para leer fichero CSV

while IFS=: read nombre apellidos email usuario pubkey
do
	echo "$nombre -- $apellidos -- $email -- $usuario -- $pubkey"
done < $1