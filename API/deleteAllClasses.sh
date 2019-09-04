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
echo "#####################"
echo "###!!! WARNING !!!###"
echo "#####################"
echo "This is a self destruct stript that will delete all classes."
echo "Please ensure you have a database backup."
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
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Trim the trailing slash off if necessary courtest if iMatthewCM on GitHub
if [ $(echo "${server: -1}") == "/" ]; then
	server=$(echo $server | sed 's/.$//')
fi
# Courtesy of github dot com slash zdorow
echo "Testing connection to Jamf Pro..."
test=$(curl --fail -ksu "$username":"$password" "$server"/JSSResource/users -X GET)
status=$?
if [ $status -eq 6 ]; then
	echo ""
	echo "The Jamf Pro URL is incorrect. Please edit the URL and try again."
	echo "If the error persists please check permissions and internet connection"
	echo ""
	exit 99
elif [ $status -eq 22 ]; then
	echo ""
	echo "Username and/or password is incorrect. Please edit and try again."
	echo "If the error persists please check permissions and internet connection"
	echo ""
	exit 99
elif [ $status -eq 0 ]; then
    echo ""
    echo "Connection test successful! "
    echo ""
else
    echo ""
    echo "Something went really wrong,"
    echo "Lets try this again."
    exit 99
fi
echo ""
echo "Deleting all classes now!"
classID=$(curl -ksu $username:$password -H "accept: text/xml" $server/JSSResource/classes | xmllint --format - | awk -F '[<>]' '/id/{print $3}')
for class in $classID;do
	curl -ksu $username:$password -H "Content-type: text/xml" $server/JSSResource/classes/id/$class -X DELETE
done
