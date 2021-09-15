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

echo "--- soundcloud ---"
echo ""

test "TRACK" "https://soundcloud.com/bigwild/sylvan-esso-hey-mami-big-wild-remix"

test "PLAYLIST" "https://soundcloud.com/bigwild"

test "RELATED" "vbml://run?backend=soundcloud&method=related&label=tracks&q=bigwild/sylvan-esso-hey-mami-big-wild-remix"

test "SEARCH TRACKS" "vbml://run?backend=soundcloud&method=search&label=tracks&q=chillwave"

test "SEARCH PEOPLE" "vbml://run?backend=soundcloud&method=search&label=people&q=chillwave"

test "SEARCH PLAYLISTS" "vbml://run?backend=soundcloud&method=search&label=playlists&q=chillwave"
