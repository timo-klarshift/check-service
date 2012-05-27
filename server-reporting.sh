#!/bin/bash

# simple server reporting via email #
recipient="timo@klarshift.de"

########################################################################

# check services
./check-service.sh services.txt

# send content via mail
if [ -f down-services.txt ]; then		
	cat down-services.txt | mail -s "Services DOWN" $recipient &
	echo "Sending mail ..."
	rm down-services.txt
fi;
