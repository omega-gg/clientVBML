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

echo "--- tmdb ---"
echo ""

test "TRACK MOVIE" "https://www.themoviedb.org/movie/11-star-wars"

test "TRACK TV" "https://www.themoviedb.org/tv/82856-the-mandalorian"

test "RELATED MOVIE" "vbml:run?backend=tmdb&method=related&label=tracks&q=movie/11-star-wars"

test "RELATED TV" "vbml:run?backend=tmdb&method=related&label=tracks&q=tv/82856-the-mandalorian"

test "VIEW MOVIES" "vbml:run?backend=tmdb&method=view&q=movie/popular"
test "VIEW SHOWS"  "vbml:run?backend=tmdb&method=view&q=tv/popular"

# discover/movie?sort_by=popularity.desc&with_watch_providers=8&watch_region=US
test "DISCOVER MOVIES" \
     "vbml:run?backend=tmdb&method=view&q=discover%2Fmovie%3Fsort_by%3Dpopularity.desc%26with_watch_providers%3D8%26watch_region%3DUS"

# discover/tv?sort_by=popularity.desc&with_watch_providers=8&watch_region=US
test "DISCOVER SHOWS" \
     "vbml:run?backend=tmdb&method=view&q=discover%2Ftv%3Fsort_by%3Dpopularity.desc%26with_watch_providers%3D8%26watch_region%3DUS"

test "SEARCH TRACKS" "vbml:run?backend=tmdb&method=search&label=tracks&q=Star Wars"

test "COVER" "vbml:run?backend=tmdb&method=cover&q=Modern Times 1936.mp4"
