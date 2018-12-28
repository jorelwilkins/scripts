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
#	setComputerName-AssetTag.sh - Names computer to Asset Tag from Jamf Pro
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################
server="$4" #Jamf Pro Server URL
username="$5" #Jamf Pro API Username
password="$6" #Jamf Pro API Password
####################################################################################################
#Trim the trailing slash off if necessary
if [ $(echo "${server: -1}") == "/" ]; then
	jssURL=$(echo $server | sed 's/.$//')
fi

#Get the Serial Number
serialNumber=$(ioreg -l | grep IOPlatformSerialNumber | awk '{print $4}' | tr -d \")
#Get the Asset Tag from Jamf Pro
assetTag=$(curl -ksu "$username":"$password" "$server"/JSSResource/computers/serialnumber/"$serialNumber" | xmllint --xpath '/computer/general/asset_tag/text()' - )
echo "Asset Tag is: $assetTag"
#Set Computer Name
scutil --set ComputerName "$assetTag"
#Set Local Host Name
scutil --set LocalHostName "$assetTag"
#Set Host Name
scutil --set HostName "$assetTag"
# Set the computer name with jamf binary (uncomment below if necessary)
#/usr/local/bin/jamf setComputerName -name "$assetTag"
#Flush DNS Cache (uncomment below if necessary)
#dscacheutil -flushcache
# Recon the machine (uncomment below if necessary)
#/usr/local/bin/jamf recon
