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

echo "--- lastfm ---"
echo ""

test "TRACK" "https://www.last.fm/music/Stardust/_/Music+Sounds+Better+With+You"

test "FEED" "https://www.last.fm/music/Stardust"

test "RELATED" "vbml:run?backend=lastfm&method=related&label=tracks&q=Stardust%2F_%2FMusic%2BSounds%2BBetter%2BWith%2BYou"

test "SEARCH TRACKS" "vbml:run?backend=lastfm&method=search&label=tracks&q=Daft Punk"

test "COVER" "vbml:run?backend=lastfm&method=cover&label=Daft Punk&q=One More Time.mp3"
