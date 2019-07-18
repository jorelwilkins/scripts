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
# Description
# This script will create a webloc (shortcut to webpage) on the users Desktop
####################################################################################################
#Get the logged in user
loggedInUser=$( python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )
#Enter what you want to name the .webloc (cannot contain spaces)
nameOfWebloc="$4" #nameOfWebloc="jamf-nation"
url="$5" #url="https://www.jamf.com/jamf-nation/"
#Path to .webloc
webloc=/Users/"$loggedInUser"/Desktop/"$nameOfWebloc".webloc
#Create the file
touch $webloc
#Use EOF to fill it with stuff
cat > $webloc <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0$
<plist version="1.0">
<dict>
	<key>URL</key>
	<string>$url</string>
</dict>
</plist>
EOF
