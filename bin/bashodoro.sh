#! /usr/bin/bash

#let us assume that the person wants a timer for 20 minutes and then a 4 minutes break
session_duration=20 #assuming 20 minutes
seconds=$(($session_duration * 60))

echo "SESSION STARTED"
for ((k = 2; k >= 0; k--)); do
	#sleep for 1 second
	sleep 1s
	echo -ne "Seconds Left : $k \033[0K\r"
done

echo -ne "\nSESSION OVER\n"

# once the session is over, check if log file exists
if [[ -e "log.csv" ]]; then
	echo "logging session in file"
else
	echo "making log file to store sessions history"
	touch logs
fi

# log file is updated for each sesssion
echo $(date) >> logs

