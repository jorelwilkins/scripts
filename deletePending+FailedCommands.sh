#!/bin/bash

####################################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT
#
# BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE
# IS UNDER NO OBLIGATION TO SUPPORT, DEBUG, OR OTHERWISE
# MAINTAIN THIS SCRIPT
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

read -p "Jamf Pro URL: " server
read -p "Jamf Pro Username: " username
read -s -p "Jamf Pro Password: " password
echo ""

####################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

server=""
username=""
password=""

#get the serialnumber
sn=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')

#get the jamf pro id based off serialnumber
id=$(curl -ksu $username:$password -H "accept: text/xml" $server/JSSResource/computers/serialnumber/$sn | xmllint --xpath "computer/general/id/text()" -)

#Delete pending & failed commands for the mac
curl -ksu $username:$password -H "content-type: text/xml" $server/JSSResource/commandflush/computers/id/$id/status/Pending+Failed -X DELETE
