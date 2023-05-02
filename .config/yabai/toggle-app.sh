#!/bin/bash
APP=$1

ID=$(yabai -m query --windows --space | jq -r  --arg APP "$APP" '.[] | select(.app ==$APP) | .id ') 
MINIMIZED=$(yabai -m query --windows --space | jq -r  --arg APP "$APP" '.[] | select(.app ==$APP) | ."is-minimized"') 

if [ "true" == "$MINIMIZED" ]
then
  yabai -m window --deminimize  $ID
  yabai -m window --focus $ID
else
  yabai -m window --minimize $ID
fi
