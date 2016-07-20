#!/usr/bin/env bash

cd /home/pi/project-delta/

git stash save .credentials/calendar.json
git pull
python server.py &