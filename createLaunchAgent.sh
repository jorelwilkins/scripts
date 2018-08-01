#!/bin/bash

# Get the logged in username
loggedInUser=$( python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )

# Desired name for plist Example: com.mycompany.thing (do not include .plist)
plistName="$4"
# plistName=""
# Path to script
scriptPath="$5"
# scriptPath=""
# Output the plist
outputPlist=/Users/$loggedInUser/Library/LaunchAgents/$plistName.plist
# Make the LaunchAgents directory if need be
mkdir -p /Users/$loggedInUser/Library/LaunchAgents

cat > $outputPlist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$plistName</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/sh</string>
    <string>$scriptPath</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF

chown root:wheel $outputPlist
launchctl load -w $outputPlist
