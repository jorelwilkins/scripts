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
if [ -z "$server" ]; then
  echo "\$server is null, please set a value. Exiting script."
  exit 1
fi
if [ -z "$username" ]; then
  echo "\$username is null, please set a value. Exiting script."
  exit 1
fi
if [ -z "$password" ]; then
  echo "\$password is null, please set a value. Exiting script."
  exit 1
fi
if [ -z "$eficode" ]; then
  echo "\$eficode is null, please set a value. Exiting script."
  exit 1
fi

###############################
# Do not edit below this line #
###############################

#Store the mac's SN as a variable
sn=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')
echo "Serial Number is: $serialnumber"

# Get coordinates, region and postal code of machine. If machine is connected to VPN this is obscure results
coordinates=`curl -s ipinfo.io | grep loc | awk '{print $2}'`
echo "Geo Coordinates are: $coordinates"
region=`curl -s ipinfo.io | grep region | awk '{print $2}'`
echo "Region is: $region"
postal=`curl -s ipinfo.io | grep postal | awk '{print $2}'`
echo "Postal Code is: $postal"

#Get Mac's ID based off serialnumber
id=$(curl -ksu $username:$password -H "accept: text/xml" $server/JSSResource/computers/serialnumber/$sn | xmllint --xpath "computer/general/id/text()" -)
echo "Mac ID is: $id"

# Send lock command to computer
curl -ksu $username:$password -H "content-type: text/xml" $server/JSSResource/computercommands/command/DeviceLock/passcode/$eficode/id/$id -X POST
exit 0
