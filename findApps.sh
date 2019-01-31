#!/bin/sh
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
# DESCRIPTION
# This script can be used to generate a txt file of applications in /Applications. Then upload it as an
# attachment to the machine record via the Classic API. This is designed to be deployed via a policy to machines you wish to gather
# that information from.
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

#Jamf Pro URL (do not include the trailing "/" in the URL)
server="$4"
#API / Jamf Pro Username
username="$5"
#API / Jamf Pro Password
password="$6"
###########################################

#Store Mac's SN as a variable
sn=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')

#Store Mac's ID as a Variable from jamf pro based off serial number
id=$(curl -ksu "$username":"$password" -H "accept: text/xml" "$server"/JSSResource/computers/serialnumber/"$sn" | xmllint --xpath "computer/general/id/text()" -)

#Get the apps and store them as a text file
ls  "/Applications" > "/Library/Application Support/JAMF/installedApps.txt"

#Or use a for loop if so desired. Comment out line 21 and uncomment line below
#for i in /Applications/*.app;do echo "$i" >> "/Library/Application Support/JAMF/installedApps.txt"; done

#Give the Mac 4 seconds to create the above file
sleep 4

#Get the apps.txt based off the mac's ID and upload to jamf
curl -sku "$username":"$password" "$server"/JSSResource/fileuploads/computers/id/"$id" -X POST -F "name=@/Library/Application Support/JAMF/installedApps.txt"

#Clean up
rm -rf /Library/Application\ Support/JAMF/installedApps.txt
