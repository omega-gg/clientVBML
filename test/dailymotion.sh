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

echo "--- dailymotion ---"
echo ""

test "TRACK" "https://www.dailymotion.com/video/x83nkms"

test "PLAYLIST" "https://www.dailymotion.com/TechnoOverlfload"

test "RELATED" "vbml://run?backend=dailymotion&method=related&label=tracks&q=x83nkms"

test "SEARCH TRACKS" "vbml://run?backend=dailymotion&method=search&label=tracks&q=chillwave"

# NOTE: No result for 'chillwave'.
test "SEARCH CHANNELS" "vbml://run?backend=dailymotion&method=search&label=channels&q=synthwave"

test "SEARCH PLAYLISTS" "vbml://run?backend=dailymotion&method=search&label=playlists&q=chillwave"
