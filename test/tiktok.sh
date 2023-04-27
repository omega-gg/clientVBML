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

echo "--- tiktok ---"
echo ""

test "TRACK" "https://www.tiktok.com/@astroshooter__/video/7196395432459636010"

test "PLAYLIST" "https://www.tiktok.com/@astroshooter__"
