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
# DESCRIPTION
# This is a self descrtuct script that will delete all classes in Jamf Pro.
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################
echo "This is a self destruct stript. Please ensure you have a database backup."
echo "There is no magic undo button other than restoring to a backup when the classes were in existance."
read -p "Are you sure you want to continue? [ y | n ]  " answer
if [[ $answer != 'y' ]]; then
	echo "Exiting script!"
	exit 1
fi
read -p "JSS URL: " server
read -p "JSS Username: " username
read -s -p "JSS Password: " password
echo ""

####################################################################################################
#
# DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

classID=$(curl -ksu $username:$password -H "accept: text/xml" $server/JSSResource/classes | xmllint --format - | awk -F '[<>]' '/id/{print $3}')
for class in $classID;do
	curl -ksu $username:$password -H "Content-type: text/xml" $server/JSSResource/classes/id/$class -X DELETE
done
