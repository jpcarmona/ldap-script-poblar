#!/bin/bash
#Nombre del archivo: check-server-sshpubkey
#Fecha de creación: 18/11/2018
#Autor: Juan pedro Carmona Romero
#Descripción: Comprobar que clave pública servidor SSH está en LDAP



# Obtener clave pública que nos ofrece el servidor LDAP: -------------------------
pubkeyldap=$(ldapsearch -h 172.22.200.54 -x -o ldif-wrap=no -b "ou=Servers,dc=juanpe,dc=gonzalonazareno,dc=org" \
"(|(ipHostNumber=$1)(cn=$1))" 2>/dev/null | grep sshPublicKey | cut -f2,3 -d " " )

# Comprobar que se ha obtenido la clave de LDAP
if [ -z "$pubkeyldap" ]
then
	echo "No se ha encontrado la clave pública de $1 en servidor LDAP"
	exit
else
	echo "Se ha encontrado la clave pública de $1 en servidor LDAP"
	echo ""
fi
#---------------------------------------------------------------------------------


# Obtener clave pública que nos ofrece el servidor SSH: ------------------------
keytype=$(echo $pubkeyldap | cut -f1 -d" ")
pubkeyserver=$(ssh-keyscan -t $keytype $1 2>/dev/null | cut -f2- -d" " )

# Comprobar que se ha obtenido la clave de LDAP
if [ -z "$pubkeyserver" ]
then
	echo "No ha sido posible obtener la clave pública del servidor SSH $1"
	echo "Por favor compruebe que tiene conexión con el servidor SSH o si se ha resuelto bien su nombre"
	exit
else
	echo "Se ha encontrado la clave pública de $1 en servidor SSH"
	echo ""
fi
#---------------------------------------------------------------------------------


# Comprobar que concuerdan las 2 claves -----------------------------------------
if [[ $pubkeyldap != $pubkeyserver ]]
then
	echo "La clave pública en LDAP no concuerda con la del servidor SSH"
	exit
else
	echo "Las 2 claves concuerdan, verificación de claves exitosa!"
fi
#---------------------------------------------------------------------------------

