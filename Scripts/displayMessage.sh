#!/bin/bash

#These are variables that can be set inside of the policy
messageToDisplay="$4" # Example: macOS Mojave is now available in Self Service!
policyToExecute="$5" # ID of the policy to execute or view
policyAction="$6" # This can be set to "view" or "execute"

#If user clicks the OK, then open Self Service to execute or view the policy based of it's ID
buttonClicked=$(osascript <<EOF
button returned of (display dialog "$messageToDisplay" buttons {"OK", "Cancel"} default button 1)
EOF)

if [[ "$buttonClicked" == "OK" ]];then
open "jamfselfservice://content?entity=policy&id=$5&action=$6"
fi
