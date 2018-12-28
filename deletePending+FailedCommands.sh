#!/bin/bash

server=""
username=""
password=""

#get the serialnumber
sn=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')

#get the jamf pro id based off serialnumber
id=$(curl -ksu $username:$password -H "accept: text/xml" $server/JSSResource/computers/serialnumber/$sn | xmllint --xpath "computer/general/id/text()" -)

#Delete pending & failed commands for the mac
curl -ksu $username:$password -H "content-type: text/xml" $server/JSSResource/commandflush/computers/id/$id/status/Pending+Failed -X DELETE
