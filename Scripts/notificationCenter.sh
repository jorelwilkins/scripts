#!/bin/bash

title="$4"
message="$5"

'/Library/Application Support/JAMF/bin/Management Action.app/Contents/MacOS/Management Action' -title "$4" -message "$5"
