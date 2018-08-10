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
# ABOUT THIS PROGRAM
#
# NAME
#	lockComputerAPI.sh - Locks Computer via API
#
# DESCRIPTION
#
#	The policy can be used to scope to either lost of stolen computers. It will lock the machine with a 6 digit
# EFI password and also attempt to echo the geo location
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
# Created by Ryan Peterson Thursday Aug 9, 2018
#
####################################################################################################
#
# DEFINE VARIABLES BELOW
#
####################################################################################################
server=""
username=""
password=""
eficode="" # 6 digits
###############################
#        Error Checking       #
###############################
if [ "$4" != "" ] && [ "$server" == "" ]; then
  server=$4
elif [ "$4" == "" ] && [ "$server" == "" ]; then
  echo "\$server is null, please enter a value. Exiting script"
  exit 1
fi

if [ "$5" != "" ] && [ "$username" == "" ]; then
  username=$5
elif [ "$5" == "" ] && [ "$username" == "" ]; then
  echo "\$username is null, please enter a value. Exiting script"
  exit 1
fi

if [ "$6" != "" ] && [ "$password" == "" ]; then
  password=$6
elif [ "$6" == "" ] && [ "$password" == "" ]; then
  echo "\$password is null, please enter a value. Exiting script"
  exit 1
fi

if [ "$7" != "" ] && [ "$eficode" == "" ]; then
  eficode=$7
elif [ "$7" == "" ] && [ "$eficode" == "" ]; then
  echo "\$eficode is null, please enter a value. Exiting script"
  exit 1
fi

###############################
# Do not edit below this line #
###############################

#Store the mac's SN as a variable
sn=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')

# Get coordinates of machine. If machine is connected to VPN this could obscure results.
coordinates=`curl -s ipinfo.io | grep loc | awk '{print $2}'`
echo "Geo Coordinates are: $coordinates"

#Get Mac's ID based off serialnumber
id=$(curl -ksu $username:$password -H "accept: text/xml" $server/JSSResource/computers/serialnumber/$sn | xmllint --xpath "computer/general/id/text()" -)

# Send lock command to computer
curl -ksu $username:$password -H "content-type: text/xml" $server/JSSResource/computercommands/command/DeviceLock/passcode/$eficode/id/$id -X POST

exit 0
