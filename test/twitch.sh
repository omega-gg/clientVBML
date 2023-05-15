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

echo "--- twitch ---"
echo ""

test "TRACK" "https://www.twitch.tv/videos/1171797190"

test "TRACK LIVE" "https://www.twitch.tv/esl_sc2"

test "RELATED" "vbml://run?backend=twitch&method=related&label=tracks&q=esl_sc2"

test "PLAYLIST A" "https://www.twitch.tv/directory/all"
test "PLAYLIST B" "https://www.twitch.tv/directory/collection/recently-released-games-streams"

test "SEARCH CHANNELS" "vbml://run?backend=twitch&method=search&label=tracks&q=starcraft"

test "SEARCH VIDEOS" "vbml://run?backend=twitch&method=search&label=videos&q=starcraft"
