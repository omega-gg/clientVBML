#!/bin/sh
# NOTE: We don't want to quit this script when a backend is failing.
#set -e

#--------------------------------------------------------------------------------------------------
# Requests
#--------------------------------------------------------------------------------------------------

sh duckduckgo.sh
sh youtube.sh
sh dailymotion.sh
sh vimeo.sh
sh facebook.sh
sh odysee.sh
sh peertube.sh
sh twitch.sh
sh tiktok.sh
sh soundcloud.sh
sh tmdb.sh
sh lastfm.sh
sh opensubtitles.sh
