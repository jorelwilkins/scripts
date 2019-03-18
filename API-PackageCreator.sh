#!/bin/sh
########################################################################################################
#
# Copyright (c) 2013, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#  -- Edited 15 April 2016 by Christopher Kemp to add interactive features
#	rather than hard-coding credentials etc. into the script.
####################################################################################################

#Import Packages via the API for direct upload of the flat .pkg or .dmg to the root JDS or AWS

#Variables requested from user, added by C. Kemp

echo "Enter the URL of the JSS to be updated, including port number if needed:"
read server					#Server name of the old server e.g. "JAMFSoftware.com"
echo "Username:"
read username					#JSS username with API privileges
echo "Password:"
read -s password					#Password for the JSS account
echo "Enter the full name of the file to sync with the JSS:"
read packageName				#Name of the package (including file extension)

curl -k -v -u ${username}:${password} -H "Content-Type: text/xml" ${server}/JSSResource/packages/id/-1 -d "<package><name>${packageName}</name><filename>${packageName}</filename></package>" -X POST

exit 0
