#!/bin/bash

# Name: data-compressor
# Author: Matjaz Skoda, matjaz.skoda@gmail.com
# Version 1.03

# Description: 
# Simple compression solution which uses 7za compressor to compress large (more GB in size) daily 
# files into monthly archive based on YYYY-MM-DD time in source (daily) file name.
# Large daily files (.json, .log, ...) are named/generated as {base-app-name1}-YYYY-MM-DD.json, {base-app-name2}-YYYY-MM-DD.json, ...
# Monthly archives are then named {base-app-name1}-YYYY-MM.7z, {base-app-name2}-YYYY-MM.7z

# To automatically start this script use cron, add something like this into the /etc/crontab file:
# start data-compressor.sh every day 15 minutes after midnight
# 15 0 * * * data-compressor-user /path/to/data-compressor.sh

# uncomment to echo execution trace
# set -o xtrace

# TODO:
# - Add automatic cheching for required tools/executables used by this script.
# - Change in settings.sh and in code: convert EXT_PATTERN, EXT_PATTERN2 into array for more flexibility on file extensions.
# - Add option to scp/rsync finished monthly archive to other archive location (on end of a month).

# Auto get current script directory
SCRIPT_PATH="$(cd $(dirname $0);pwd -P)"
# include functions
. "${SCRIPT_PATH}/include/functions.sh"
BASE_NAME=${0}
FILE_NAME=${BASE_NAME##*/}
NAME_PART=${FILE_NAME%%.*}

# Include basename of this script to auto name log-file (can be overriden in config/settings.sh)
LOG_FILE=${SCRIPT_PATH}/log/${NAME_PART}.log
if [ ! -d ${SCRIPT_PATH}/log ]; then
	mkdir -p ${SCRIPT_PATH}/log
fi

# Global settings for this script.
if [ -f $SCRIPT_PATH/config/settings.sh ]; then
	. $SCRIPT_PATH/config/settings.sh
else
	write_log "Error: settings file not found ($SCRIPT_PATH/config/settings.sh)" $TRACE_ERROR
	exit 1
fi

if [ ! -f "$PATTERN_FILE" ]; then
	write_log "Pattern file does not exist [$PATTERN_FILE]. Please create one." $TRACE_ERROR
	exit 2
fi

if [ ! -d "$SOURCE_DIR" ]; then
	write_log "Source dir does not exist [$SOURCE_DIR]. Please create one." $TRACE_ERROR
	exit 3
fi

if [ ! -d "$DEST_DIR" ]; then
	write_log "Dest dir does not exist [$DEST_DIR]. Please create one." $TRACE_ERROR
	exit 4
fi


# Time stamp formatting
TS="$(date '+%Y-%m-%d_%H-%M-%S')"
TS_TODAY="$(date '+%Y-%m-%d')"
TS_YESTERDAY="$(date --date='yesterday' +'%Y-%m-%d')"
TS_YEAR_MONTH="$(date '+%Y-%m')"
TS_YEAR_MONTH_YESTERDAY="$(date  --date='yesterday' +'%Y-%m')"


# do_compress(): actually run 7za and do compression according file patterns
# $1 - dateSrcPattern
# $2 - dateDestPattern (archive group date) 
# $3 - filePattern (for compressing)
do_compress()
{
	local dateSrcPattern="$1"
	local dateDestPattern="$2"
	local filePattern="$3"
		
	# Checking for EXT_PATTERN, EXT_PATTERN2 to avoid 7z to 'test' whole X * 10GB archive even if there is no files to add (for saving iops)
	if [ -f "$SOURCE_DIR/$filePattern$dateSrcPattern$EXT_PATTERN" ] || [ -f "$SOURCE_DIR/$filePattern$dateSrcPattern$EXT_PATTERN2" ]; then
		write_log "Compressing: $SOURCE_DIR/$filePattern$dateSrcPattern$EXT_PATTERN" $TRACE_INFO
		write_log "$COMMAND_PART1 -w$SOURCE_DIR $DEST_DIR/$filePattern$dateDestPattern.$(hostname).7z ./$filePattern$dateSrcPattern*"
		
		cd "$SOURCE_DIR"
		# Work dir should be on destination to avoid unnecessary copying of 7z archive during compression (for saving iops)
		$COMMAND_PART1 "-w$DEST_DIR" "$DEST_DIR/$filePattern$dateDestPattern.$(hostname).7z" "./$filePattern$dateSrcPattern*"
	else
		write_log "Source file does not exist [$SOURCE_DIR/$filePattern$dateSrcPattern$EXT_PATTERN]" $TRACE_WARN
	fi
}



# Main part: read pattern file line by line and call compression function
while read -r line || [[ -n "$line" ]]; do
	# Skip zero length lines and lines beginning with # (can be spaces and tabs before first char of line too)
	if [[ ! -z $line ]] && [[ ! $line =~ ^[[:blank:]]*#.* ]]; then

		if [ "$TS_YEAR_MONTH" != "$TS_YEAR_MONTH_YESTERDAY" ]; then 
			write_log "Pack data for previous month: $TS_YEAR_MONTH_YESTERDAY" $TRACE_INFO
			TS_YEAR_MONTH="$TS_YEAR_MONTH_YESTERDAY"
		fi

		write_log "Calling: do_compress: '$TS_YESTERDAY $TS_YEAR_MONTH $line'"
		do_compress "$TS_YESTERDAY" "$TS_YEAR_MONTH" "$line"
		# TODO: Add option to scp/rsync completed monthly archive to other archive location (on a first day of a new month).
	fi
done < "$PATTERN_FILE"

# Delete next line if you do not want log records to be splitted in daily groups
write_log ""
