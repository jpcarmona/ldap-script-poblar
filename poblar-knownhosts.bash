#!/bin/bash
#Nombre del archivo: poblar-knownhosts.bash
#Fecha de creación: 19/11/2018
#Autor: Juan pedro Carmona Romero
#Descripción: Puebla el fichero known_hosts con claves públicas de servidores

pubkeys=$(ldapsearch -h 192.168.1.24 -x -LLL -o ldif-wrap=no \
-b "ou=Servers,dc=juanpe,dc=gonzalonazareno,dc=org" sshPublicKey cn ipHostNumber \
| grep -v '^dn:' | tr -t " " "#")

for i in $pubkeys
do
	if [[ $i =~ .*cn:#.* ]]
	then
		echo "cn"
	elif [[ $i =~ .*ipHostNumber:.* ]]
	then
		echo "ipHostNumber"
	elif [[ $i =~ .*sshPublicKey:.* ]]
	then
		echo "sshPublicKey:"
	fi

done
