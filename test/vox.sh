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

echo "--- vox ---"
echo ""

test "TRACK" "https://vox.omega.gg/w/9d5fYXTcjLHReVUQabKRwB"

test "FEED" "https://vox.omega.gg/c/vox"

test "PLAYLIST" "https://vox.omega.gg/w/p/ehXUsZrq4TJZVBC8J7GWpN"

test "TRENDING" "vbml:run?backend=vox&method=view&q=vox.omega.gg/trending"

test "RELATED" "vbml:run?backend=vox&method=related&label=tracks&q=vox.omega.gg/w/9d5fYXTcjLHReVUQabKRwB"

test "RELATED TIME" "vbml:run?backend=vox&method=related&label=tracks&q=vox.omega.gg/w/9d5fYXTcjLHReVUQabKRwB&t=1"

test "SEARCH TRACKS" "vbml:run?backend=vox&method=search&label=tracks&q=movie"
