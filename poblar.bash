#!/bin/bash
#Nombre del archivo: poblar.bash
#Fecha de creación: 17/11/2018
#Autor: Juan pedro Carmona Romero
#Descripción: Poblar directorio LDAP con usuarios

# Comprobamos que se especifica fichero en parámetro $1

if [ -z "$1"]
then
	echo "Para ejecutar este script debes especificar un fichero de entrada CSV"
	echo "Ejemplo: bash poblar.bash usuarios.csv"
	exit
fi

# Comprobamos que se especifica contraseña en parámetro $2

if [ -z "$2"]
then
	echo "Por favor escriba la contraseña -admin- del directorio"
	exit
fi

# Empezamos bucle para leer fichero CSV desde parámetro $1

while IFS=: read nombre apellidos email usuario pubkey
do

	echo "$nombre -- $apellidos -- $email -- $usuario -- $pubkey"
	
done < $1

