while IFS=: read nombre apellidos email usuario pubkey
do

ldapdelete -x -w "$2" -D 'cn=admin,dc=juanpe,dc=gonzalonazareno,dc=org' \
"uid=$usuario,ou=People,dc=juanpe,dc=gonzalonazareno,dc=org"

done < $1

