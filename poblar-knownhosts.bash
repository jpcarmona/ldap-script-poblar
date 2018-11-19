#!/bin/bash
#Nombre del archivo: poblar-knownhosts.bash
#Fecha de creación: 19/11/2018
#Autor: Juan pedro Carmona Romero
#Descripción: Puebla el fichero known_hosts con claves públicas de servidores


# Con esto obtenemos todas las claves públicas de los servidores SSH desde LDAP. ------------
# Con el siguiente formato:

###		cn:#<nombre servidor>
###		ipHostNumber:#<ip servidor>
###		sshPublicKey:#<tipo de clave>#<clave pública>#<comentario equipo>

pubkeys=$(ldapsearch -h $1 -x -LLL -o ldif-wrap=no \
-b "ou=Servers,dc=juanpe,dc=gonzalonazareno,dc=org" sshPublicKey cn ipHostNumber \
| grep -v '^dn:' | tr -t " " "#")

#--------------------------------------------------------------------------------------------

# Nos devuelve 3 lineas por servidor así que vamos recojiendo cada línea de la siguietne forma:

for i in $pubkeys
do
	if [[ $i =~ .*cn:#.* ]]
	then
		nombre=$(echo "$i" | cut -d "#" -f2)
	elif [[ $i =~ .*ipHostNumber:.* ]]
	then
		ipservidor=$(echo "$i" | cut -d "#" -f2)
	elif [[ $i =~ .*sshPublicKey:.* ]]
	then
		pubkey=$(echo "$i" | cut -d "#" -f2,3 | tr -t "#" " ")
		echo "$nombre $pubkey" >> $2
		echo "$ipservidor $pubkey" >> $2
	fi

done

ssh-keygen -H -f $2
rm $2.old

#### Se podría verificar si existe ya una clave con esa ip o nombre...