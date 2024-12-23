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

echo "--- vimeo ---"
echo ""

test "TRACK" "https://vimeo.com/370892294"

test "FEED" "https://vimeo.com/dalz1el"

#test "RELATED" "vbml:run?backend=vimeo&method=related&label=tracks&q=370892294"

#test "SEARCH TRACKS" "vbml:run?backend=vimeo&method=search&label=tracks&q=chillwave"

#test "SEARCH PEOPLE" "vbml:run?backend=vimeo&method=search&label=people&q=chillwave"

#test "SEARCH CHANNELS" "vbml:run?backend=vimeo&method=search&label=channels&q=chillwave"

#test "SEARCH PLAYLISTS" "vbml:run?backend=vimeo&method=search&label=playlists&q=chillwave"
