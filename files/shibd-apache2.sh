#!/bin/sh

/etc/init.d/shibd start

while [ \! -f /var/cache/shibboleth/login.clinnection.com.xml ]
do
	echo "Waiting for XML"
	sleep 10
        /etc/init.d/shibd restart
done 

exec apache2ctl -D FOREGROUND
