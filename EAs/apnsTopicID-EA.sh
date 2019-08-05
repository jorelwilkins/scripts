#!/bin/bash

realTopic="com.apple.mgmt.External.topic.id.here"
# machineTopic=$(/System/Library/PrivateFrameworks/ApplePushService.framework/apsctl status | grep "com.apple.mgmt.External." | sed -n '1!p' | awk '{print $5}')
machineTopic=$(/System/Library/PrivateFrameworks/ApplePushService.framework/apsctl status | grep "com.apple.mgmt.External." | head -n 1 | awk '{print $2}')
# echo "Real topic: #realTopic "

# echo "Machine topic: $machineTopic "
if [ "$machineTopic" == $realTopic ]; then
  echo "<result>Match</result>"
else
  echo "<result>Does not match</result>"
fi
