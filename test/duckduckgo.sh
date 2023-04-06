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

echo "--- duckduckgo ---"
echo ""

test "SEARCH URLS" "vbml://run?backend=duckduckgo&method=search&label=urls&q=site:https://youtube.com chillwave"

test "SEARCH SITE" "vbml://run?backend=duckduckgo&method=search&label=site&q=chillwave"

test "SEARCH TRACKS A" "vbml://run?backend=duckduckgo&method=search&label=tracks&q=chillwave"
test "SEARCH TRACKS B" "vbml://run?backend=duckduckgo&method=search&label=tracks&q=disney+"
test "SEARCH TRACKS C" "vbml://run?backend=duckduckgo&method=search&label=tracks&q=chillwave !"

test "SEARCH PLAYLISTS" "vbml://run?backend=duckduckgo&method=search&label=playlists&q=chillwave"
