#!/bin/bash
#set -xv
# The UPIC system (Unité Polyagogique Informatique du CEMAMu) 
# is a groundbreaking tool for composing and generating electronic music
# developed by composer Iannis Xenakis in the late 1970s.


#sudo apt install xdotool ffmpeg
# aplay is part of alsamixer, ima assume everyone has this.

#xdotool getmouselocation
#x:357 y:2062 screen:0 window:14680070

# White noise
#ffmpeg -f lavfi -i anoisesrc=d=10:c=white -f wav - | aplay

# Get screen resolution
#3840x2160
res=$(xrandr | grep '*' | awk '{print $1}')

# Extract the width and height
rx=$(echo $res | cut -d'x' -f1)
ry=$(echo $res | cut -d'x' -f2)

# interupt handler for a more graceful shutdown
trap ctrl_c INT

ctrl_c() {
  echo "** Trapped CTRL-C"
  # Perform cleanup or other actions here
  rm temp.wav
  exit 1
}

# Function to map x to frequency
function map_x_to_frequency() {
	#local sets local varaibles
    local x=$1
    local screen_width=$rx 
    local min_freq=10
    local max_freq=6969
    local freq=$((min_freq + (x * (max_freq - min_freq)) / screen_width))
    echo $freq
}

# Function to map y to duration 
function map_y_to_duration() {
	#local sets local varaibles
    local y=$1
    local screen_height=$ry
    local min_dur=1
    local max_dur=4
    local dur=$(echo "$min_dur + ($y * ($max_dur - $min_dur)) / $screen_height" | bc -l)
    echo $dur
}

# Infinite loop track mouse
while true; do
    eval $(xdotool getmouselocation --shell)

    # Convert x, y to frequency and duration
    frequency=$(map_x_to_frequency $X)
    duration=$(map_y_to_duration $Y)

    # make sound expansiate this later maybe.
    ffmpeg -f lavfi -i "sine=frequency=$frequency:duration=$duration" -q:a 9 -acodec pcm_s16le temp.wav -y
    #echo "Mouse position: X=$X, Y=$Y -> Frequency=$frequency Hz, Duration=$duration seconds"
    # Play sound
    aplay temp.wav
    #sleep 0.1
done
