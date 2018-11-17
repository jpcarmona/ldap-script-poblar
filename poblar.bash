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

# Comprobamos que se especifica contraseña en parámetro $2

error=$(ldapsearch -x -D "cn=admin,dc=juanpe,dc=gonzalonazareno,dc=org" \
-b "dc=juanpe,dc=gonzalonazareno,dc=org" -w "$2" "cn=admin" 2>& 1>/dev/null )

if [ -n "$error" ]
then
	echo "Contraseña Incorrecta"
	exit
fi

# Creamos variable uidnum "uidNumber"
uidnum=2000

# Empezamos bucle para leer fichero CSV desde parámetro $1
while IFS=: read nombre apellidos email usuario pubkey
do

ldapadd -x -D 'cn=admin,dc=juanpe,dc=gonzalonazareno,dc=org' -w "$2" << EOF
dn: uid=$usuario,ou=People,dc=juanpe,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: ldapPublicKey
uid: $usuario
uidNumber: 2000
gidNumber: $uidnum
homeDirectory: /home/$usuario
cn: $nombre $apellidos
givenName: $nombre
sn: $apellidos
mail: $email
EOF

uidnum=$((uidnum + 1))

done < $1

