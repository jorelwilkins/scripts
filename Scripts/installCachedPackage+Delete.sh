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

pkgName="$4"

/usr/sbin/installer -pkg /Library/Application\ Support/JAMF/Waiting\ Room/"$4" -target /

/bin/rm /Library/Application\ Support/JAMF/Waiting\ Room/"$4"
/bin/rm /Library/Application\ Support/JAMF/Waiting\ Room/"$4".cache.xml
