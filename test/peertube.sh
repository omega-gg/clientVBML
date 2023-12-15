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

echo "--- peertube ---"
echo ""

test "TRACK" "https://peertube.dsmouse.net/w/719666f2-0fb6-489c-8339-038f902aa55c"

test "TRACK SHORT" "https://peertube.fr/w/kkGMgK9ZtnKfYAgnEtQxbv"

test "FEED" "https://peertube.fr/c/joinpeertube@framatube.org"

test "RELATED" "vbml:run?backend=peertube&method=related&label=tracks&q=peertube.fr/w/kkGMgK9ZtnKfYAgnEtQxbv"

test "SEARCH TRACKS" "vbml:run?backend=peertube&method=search&label=tracks&q=peertube.fr/api/v1/search/videos?search=peertube"
