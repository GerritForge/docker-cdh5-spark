#!/usr/bin/env bash
. $(dirname $0)/colors.sh

green "-- Starting Oozie --"
export OOZIE_URL=http://localhost:11000/oozie
service oozie start