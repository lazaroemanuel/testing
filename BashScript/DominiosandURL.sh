#!/bin/bash

echo "Dominio;Inicio Vigencia SSL;Termino Vigencia SSL;Updated Date Dominio;Creation Date Dominio;Registry Expiry Date Dominio;Propietario"
for i in `cat url.txt | awk '{print $1}'`
	do

		port=$(grep ^$i url.txt | awk '{print $2}')
		dominio=$(grep ^$i url.txt | awk -F . '{print $(NF-1)"."$(NF)}' | awk '{print $1}')
		subdominio=$(grep ^$i url.txt | awk '{print $1}')
		echo -n "$i;" 
		echo | nc -vz -w 3 $i $port  &> /dev/null 
		if [[ $? -gt 0 ]]
			then 
			echo falla 
		else 
			echo -n "`echo | openssl s_client -servername $i -connect $i:$port 2> /dev/null | openssl x509 -noout -dates | awk -F "=" '{print $2}' | paste -d \; - -`;"
			echo -n "`whois $dominio | egrep "Date|Registrar:" | awk -F ":" '{print $2}' | awk -F T '{print $1}' | paste -d \; - - - -`;"
			for ip in `host $subdominio | grep address | awk '{print $(NF)}'`
				do
					echo -n "$ip;"
					echo -n "`whois $ip | grep OrgName: | head -1 | awk -F : '{print $2}' | tr -d " "`;"
				done
				echo
			
		fi
	done
