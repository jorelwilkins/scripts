#!/bin/bash

username="$4"
password="$5"
server="$6"

sn=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')
id=$(curl -ksu "$username":"$password" -H "accept: text/xml" "$server"/JSSResource/computers/serialnumber/$sn | xmllint --xpath "computer/general/id/text()" -)

user=$(curl -ksu "$username":"$password" -H "Accept: application/xml" "$server"/JSSResource/computers/id/"$id" | xmllint --xpath '/computer/location/username/text()' - )

echo "Assigned Username in Jamf Pro is: $user"
