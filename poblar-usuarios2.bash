#!/bin/bash
#Nombre del archivo: poblar-usuarios2.bash
#Fecha de creación: 21/11/2018
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


# Creamos variable uidnum "uidNumber"
uidnum=3000


# Empezamos bucle para leer fichero CSV desde parámetro $1
## En IFS especificamos el delimitador de un valor en cada línea.
## Luego se asigna cada valor a cada variable "nombre apellidos email usuario pubkey".
## En este caso sabemos que solo hay 5 valores en cada línea, pero en caso de que hubiera más
## se le asignaría el valor desde el 5º delimitador hasta el final de la línea a la variable 
## "pubkey" en este caso.
##-------------------------------- Inicio Bucle while ------------------------------------
while IFS=: read nombre apellidos usuario
do

#Creamos contraseña a partir del usuario (no es seguro pero es mas cómodo de crear)
pass=$(echo $usuario | tr -d ".")

#Ciframos contraseña con metodo "SSHA"
hashpass=$(slappasswd -h {SSHA} -s $pass)

# Inserción de usuarios con ldapadd
## Además redirigimos la salida del error estándar a la variable "error2" para luego realizar 
## un aviso de los errores
error2=$(ldapadd -x -D 'cn=admin,dc=juanpe,dc=gonzalonazareno,dc=org' -w "$2" << EOF 2>& 1>/dev/null
dn: uid=$usuario,ou=People,dc=juanpe,dc=gonzalonazareno,dc=org
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
uid: $usuario
uidNumber: $uidnum
gidNumber: 2001
homeDirectory: /home/$usuario
cn: $nombre $apellidos
givenName: $nombre
sn: $apellidos
userPassword: $hashpass
EOF
)

# Aviso de errores
if [ -n "$error2" ]
then
echo "Error al insertar el usuario $usuario"
echo "ERROR: -$error2-"
echo ""
fi

# Sumamos +1 a "uidnum" en cada vuelta
uidnum=$((uidnum + 1))

done < $1
##-------------------------------- Final Bucle while -------------------------------------


## Mostrar mensaje de todo correcto
if [ -z "$error2" ]
then
echo ""
echo "Todos los usuarios creados correctamente"
echo ""
fi
