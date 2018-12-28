#!/bin/bash

ADMIN_USER="$4"
ADMIN_PASS="$5"

echo "Checking to make sure $ADMIN_USER is present..."
if [[ $(dscl . list /Users) =~ "$ADMIN_USER" ]]; then
    echo "$ADMIN_USER is present."
else
    echo "$ADMIN_USER not found. Creating user..."
    /usr/local/bin/jamf createAccount -hiddenUser -suppressSetupAssistant -username "$ADMIN_USER" -realname "$ADMIN_USER" -password "$ADMIN_PASS" -admin
    if [[ $(dscl . list /Users) =~ "$ADMIN_USER" ]]; then
        echo "      User Created."
    else
        echo "      ERROR Creating User."
        exit 1
    fi
fi
