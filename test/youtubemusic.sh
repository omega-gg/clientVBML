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

echo "--- youtubemusic ---"
echo ""

test "SEARCH TRACKS" "vbml:run?backend=youtubemusic&method=search&label=tracks&q=Daft Punk"

test "SEARCH ALBUMS" "vbml:run?backend=youtubemusic&method=search&label=albums&q=Daft Punk"

test "SEARCH ARTISTS" "vbml:run?backend=youtubemusic&method=search&label=artists&q=Daft Punk"

test "ALBUM" "https://music.youtube.com/browse/MPREb_K8qWMWVqXGi"

test "ARTIST" "https://music.youtube.com/channel/UCRr1xG_2WIDs18a6cIiCxeA"

test "COVER" "vbml:run?backend=youtubemusic&method=cover&label=Daft Punk&q=One More Time.mp3"
