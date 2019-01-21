#!/bin/bash
####################################################################################################
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT
#
# BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE
# IS UNDER NO OBLIGATION TO SUPPORT, DEBUG, OR OTHERWISE
# MAINTAIN THIS SCRIPT
####################################################################################################
#
#              Name: enableSecureTokenForEndUser.sh
#       Description: This script is intended to enable the end user of a mac with
#                    a secure token from the management account, or account that already
#                    has a securetoken enabled.
#           Credits: https://github.com/kc9wwh
#   Tested On macOS: macOS 10.13.6
#          Jamf Pro: 10.6.0
#           Created: 2018-08-06
#           Updated: 2018-09-10
#        Edited By: @yoopersteeze with inspiriation by @kc9wwh FileVaultEnableAdminAccount script
#           Version: 1.1.0
#
####################################################################################################
################################## VARIABLES ##################################

################################## VARIABLES ##################################

# Company logo. (Tested with PNG, JPG, GIF, PDF, and AI formats.)
LOGO="/System/Library/PreferencePanes/Security.prefpane/Contents/Resources/FileVault.icns"

# The title of the message that will be displayed to the user.
# Not too long, or it'll get clipped.
PROMPT_TITLE="Encryption Update Required"

# The body of the message that will be displayed before prompting the user for
# their password. All message strings below can be multiple lines.
PROMPT_MESSAGE="Per Information Security requirements, we need to update the encryptions settings on your mac.
Please click the Next button below, then enter your Mac's password when prompted."

# The body of the message that will be displayed after 5 incorrect passwords.
FORGOT_PW_MESSAGE="Please contact the help desk for help with your Mac password."

# The body of the message that will be displayed if a failure occurs.
FAIL_MESSAGE="Sorry, an error occurred while updating your Encryption settings. Please contact the help desk for assistance."

# Specify the admin or management account that has a secure token already
ADMIN_USER="$4"
ADMIN_PASS="$5"

###############################################################################
######################### DO NOT EDIT BELOW THIS LINE #########################
###############################################################################

################################## FUNCTIONS ##################################

# Enables SecureToken for the current user.
enableSecureToken() {
    sysadminctl -adminUser $ADMIN_USER -adminPassword $ADMIN_PASS -secureTokenOn $CURRENT_USER -password $USER_PASS
}

######################## VALIDATION AND ERROR CHECKING ########################

# Suppress errors for the duration of this script. (This prevents JAMF Pro from
# marking a policy as "failed" if the words "fail" or "error" inadvertently
# appear in the script output.)
exec 2>/dev/null

BAILOUT=false

# Make sure we have root privileges (for fdesetup).
if [[ $EUID -ne 0 ]]; then
    REASON="This script must run as root."
    BAILOUT=true
fi

# Check for remote users.
REMOTE_USERS=$(/usr/bin/who | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | wc -l)
if [[ $REMOTE_USERS -gt 0 ]]; then
    REASON="Remote users are logged in."
    BAILOUT=true
fi

# Make sure the custom logo file is present.
if [[ ! -f "$LOGO" ]]; then
    REASON="Custom logo not present: $LOGO"
    BAILOUT=true
fi

# Convert POSIX path of logo icon to Mac path for AppleScript
LOGO_POSIX="$(/usr/bin/osascript -e 'tell application "System Events" to return POSIX file "'"$LOGO"'" as text')"

# Bail out if jamfHelper doesn't exist.
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
if [[ ! -x "$jamfHelper" ]]; then
    REASON="jamfHelper not found."
    BAILOUT=true
fi

# Check the OS version.
OS_MAJOR=$(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}')
OS_MINOR=$(/usr/bin/sw_vers -productVersion | awk -F . '{print $2}')
if [[ "$OS_MAJOR" -ne 10 || "$OS_MINOR" -lt 9 ]]; then
    REASON="This script requires macOS 10.9 or higher. This Mac has $(sw_vers -productVersion)."
    BAILOUT=true
fi

# Check to see if the encryption process is complete
FV_STATUS="$(/usr/bin/fdesetup status)"
if grep -q "Encryption in progress" <<< "$FV_STATUS"; then
    REASON="FileVault encryption is in progress. Please run the script again when it finishes."
    BAILOUT=true
elif grep -q "FileVault is Off" <<< "$FV_STATUS"; then
    REASON="Encryption is not active."
    BAILOUT=true
elif ! grep -q "FileVault is On" <<< "$FV_STATUS"; then
    REASON="Unable to determine encryption status."
    BAILOUT=true
fi

# Get the logged in user's name
CURRENT_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

################################ MAIN PROCESS #################################

# Get information necessary to display messages in the current user's context.
USER_ID=$(/usr/bin/id -u "$CURRENT_USER")
if [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -le 9 ]]; then
    L_ID=$(/usr/bin/pgrep -x -u "$USER_ID" loginwindow)
    L_METHOD="bsexec"
elif [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -gt 9 ]]; then
    L_ID=$USER_ID
    L_METHOD="asuser"
fi

# If any error occurred in the validation section, bail out.
if [[ "$BAILOUT" == "true" ]]; then
    echo "[ERROR]: $REASON"
    launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO" -title "$PROMPT_TITLE" -description "$FAIL_MESSAGE: $REASON." -button1 'OK' -defaultButton 1 -startlaunchd &>/dev/null &
    exit 1
fi

# Display a branded prompt explaining the password prompt.
echo "Alerting user $CURRENT_USER about incoming password prompt..."
/bin/launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO" -title "$PROMPT_TITLE" -description "$PROMPT_MESSAGE" -button1 "Next" -defaultButton 1 -startlaunchd &>/dev/null

# Get the logged in user's password via a prompt.
echo "Prompting $CURRENT_USER for their Mac password..."
USER_PASS="$(/bin/launchctl "$L_METHOD" "$L_ID" /usr/bin/osascript -e 'display dialog "Please enter the password you use to log in to your Mac:" default answer "" with title "'"${PROMPT_TITLE//\"/\\\"}"'" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_POSIX//\"/\\\"}"'"' -e 'return text returned of result')"

# Thanks to James Barclay (@futureimperfect) for this password validation loop.
TRY=1
until /usr/bin/dscl /Search -authonly "$CURRENT_USER" "$USER_PASS" &>/dev/null; do
    (( TRY++ ))
    echo "Prompting $CURRENT_USER for their Mac password (attempt $TRY)..."
    USER_PASS="$(/bin/launchctl "$L_METHOD" "$L_ID" /usr/bin/osascript -e 'display dialog "Sorry, that password was incorrect. Please try again:" default answer "" with title "'"${PROMPT_TITLE//\"/\\\"}"'" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_POSIX//\"/\\\"}"'"' -e 'return text returned of result')"
    if (( TRY >= 5 )); then
        echo "[ERROR] Password prompt unsuccessful after 5 attempts. Displaying \"forgot password\" message..."
        /bin/launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO" -title "$PROMPT_TITLE" -description "$FORGOT_PW_MESSAGE" -button1 'OK' -defaultButton 1 -startlaunchd &>/dev/null &
        exit 1
    fi
done
echo "Successfully prompted for Mac password."

# cleanUp
enableSecureToken
exit 0
