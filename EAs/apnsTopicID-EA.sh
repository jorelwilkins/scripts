#!/bin/bash

realTopic="com.apple.mgmt.External.put.the.real.topic.here"

machineTopic=$(/System/Library/PrivateFrameworks/ApplePushService.framework/apsctl status | grep "com.apple.mgmt.External." | sed -n '1!p' | awk '{print $5}')

if [ $machineTopic == $realTopic ]; then
	echo "<result>Match</result>"
else
	echo "<result>Does not match</result>"
fi
