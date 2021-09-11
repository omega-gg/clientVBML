#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

path="../bin"

#--------------------------------------------------------------------------------------------------
# Requests
#--------------------------------------------------------------------------------------------------

cd "$path"

# Track
echo "-----"
echo "TRACK"
echo "-----"
./clientVBML "https://www.youtube.com/watch?v=wOMwO5T3yT4"

# Track
echo "-----"
echo "TRACK LOCKED"
echo "-----"
./clientVBML "https://www.youtube.com/watch?v=tQ0yjYUFKAE"

# Playlist
echo "--------"
echo "PLAYLIST"
echo "--------"
./clientVBML "https://www.youtube.com/channel/UCZyXa4H06Ws3Pwom9cYEdDA"
