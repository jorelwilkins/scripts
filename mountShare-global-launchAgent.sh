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
username="$4" # username for share if there is one
password="$5" # password for share if there is one
server="$6" # hostname or IP of server share is on
share="$7" # name of share to mount
outputPlist="/Library/LaunchAgents/com.smb.launchd.smbshare.plist"
/bin/mkdir -p /Library/LaunchAgents
####################################################################################################
# Check to see if variables were passed in Jamf Pro
if [ "$4" != "" ] && [ "$username" == "" ]; then
  username=$4
fi

if [ "$5" != "" ] && [ "$password" == "" ]; then
  password=$5
fi

if [ "$6" != "" ] && [ "$server" == "" ]; then
  server=$6
fi

if [ "$7" != "" ] && [ "$share" == "" ]; then
  share=$7
fi
####################################################################################################
/bin/echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.smb.launchd.smbshare</string>
    <key>ProgramArguments</key>
    <array>
      <string>open</string>
      <string>smb://'$username':'$password'@'$server'/'$share'</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>' >> "$outputPlist"
####################################################################################################
/usr/sbin/chown -R root:wheel $outputPlist
/bin/chmod 644 $outputPlist
/bin/launchctl load -w "$outputPlist"
