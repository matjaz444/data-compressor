## data-compressor ##

Simple compression solution which uses 7za compressor to compress large (more GB in size) daily files into monthly archive based on YYYY-MM-DD time in source (daily) file name.

Large daily files (.json, .log, ...) are named/generated as {base-app-name1}-YYYY-MM-DD.json, {base-app-name2}-YYYY-MM-DD.json, ...

Monthly archives are then named {base-app-name1}-YYYY-MM.7z, {base-app-name2}-YYYY-MM.7z

## Configuration ##

Before you run this script, please set configuration in ./config/settings.sh and ./config/patterns.txt. 

Settings in both files are clearly named, there are also additional comments.

## Auto start ##
To automatically start this script use cron, add something like this into the /etc/crontab file:
```
# start data-compressor.sh every day 15 minutes after midnight
# 15 0 * * * data-compressor-user /path/to/data-compressor.sh
```
