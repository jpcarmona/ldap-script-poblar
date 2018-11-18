#!/bin/bash
#Nombre del archivo: poblar.bash
#Fecha de creación: 17/11/2018
#Autor: Juan pedro Carmona Romero
#Descripción: Poblar directorio LDAP con usuarios

# Comprobamos que se especifica fichero en parámetro $1
if [ -z "$1" ]
then
	echo "Para ejecutar este script debes especificar un fichero de entrada CSV"
	echo "Ejemplo: bash poblar.bash usuarios.csv"
	exit
fi


# Comprobamos que se especifica contraseña en parámetro $2
if [ -z "$2" ]
then
	echo "Por favor escriba la contraseña -admin- del directorio"
	exit
fi


# Comprobamos que la contraseña es correcta
error=$(ldapsearch -x -D "cn=admin,dc=juanpe,dc=gonzalonazareno,dc=org" \
-b "dc=juanpe,dc=gonzalonazareno,dc=org" -w "$2" "cn=admin" 2>& 1>/dev/null )

if [ -n "$error" ]
then
	echo "Contraseña Incorrecta"
	exit
fi


# Empezamos bucle para leer fichero CSV desde parámetro $1
## En IFS especificamos el delimitador de un valor en cada línea.
## Luego se asigna cada valor a cada variable "nombre iphost pubkey".
##-------------------------------- Inicio Bucle while ------------------------------------
while IFS=: read nombre iphost pubkey
do

# Inserción de equipos con ldapadd
## Además redirigimos la salida del error estándar a la variable "error2" para luego realizar 
## un aviso de los errores
error2=$(ldapadd -x -D 'cn=admin,dc=juanpe,dc=gonzalonazareno,dc=org' -w "$2" << EOF 2>& 1>/dev/null
dn: cn=$nombre+ipHostNumber=$iphost,ou=Servers,dc=juanpe,dc=gonzalonazareno,dc=org
objectClass: ipHost
objectClass: device
objectClass: ldapPublicKey
objectClass: top
cn: $nombre
ipHostNumber: $iphost
sshPublicKey: $pubkey
EOF
)

# Aviso de errores
if [ -n "$error2" ]
then
echo "Error al insertar el equipo $nombre"
echo "ERROR: -$error2-"
echo ""
fi

done < $1
##-------------------------------- Final Bucle while -------------------------------------


## Mostrar mensaje de todo correcto
if [ -z "$error2" ]
then
echo ""
echo "Todos los equipos creados correctamente"
echo ""
fi
