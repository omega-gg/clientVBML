#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

test()
{
    echo "$1 $2"

    # NOTE: We don't want to output anything by default.
    if ./clientVBML "$2" > /dev/null 2>&1; then
        echo "[OK]"
    else
        echo "FAIL"
    fi

    echo ""
}

#--------------------------------------------------------------------------------------------------
# Requests
#--------------------------------------------------------------------------------------------------

echo "--- youtube ---"
echo ""

test "TRACK" "https://www.youtube.com/watch?v=wOMwO5T3yT4"

test "TRACK DISNEY" "https://www.youtube.com/watch?v=lKt-gEQUir4"

test "TRACK LIVE" "https://www.youtube.com/watch?v=UedTcufyrHc"

test "FEED" "https://www.youtube.com/channel/UCZyXa4H06Ws3Pwom9cYEdDA"

test "FEED WEIRD" "https://www.youtube.com/@the.drum.thing."

test "RELATED" "vbml:run?backend=youtube&method=related&label=tracks&q=wOMwO5T3yT4"

test "SEARCH TRACKS" "vbml:run?backend=youtube&method=search&label=tracks&q=chillwave"

test "SEARCH CHANNELS" "vbml:run?backend=youtube&method=search&label=channels&q=chillwave"

test "SEARCH PLAYLISTS" "vbml:run?backend=youtube&method=search&label=playlists&q=chillwave"

# NOTE: This one might break more often so we put it at the end.
test "TRACK LOCKED" "https://www.youtube.com/watch?v=tQ0yjYUFKAE"
