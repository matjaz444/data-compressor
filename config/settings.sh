# data-compressor.sh global settings

# Set verbosity log level [TRACE_OFF|TRACE_ERROR|TRACE_WARN|TRACE_INFO|TRACE_VERBOSE(default)]
TRACE_LEVEL=$TRACE_VERBOSE

# Uncomment and set correct path if you want custom log file (instead of log-file in script-path/log subfolder).
# LOG_FILE=/path/to/log-file.log

# Echo log messages to stdout (for debugging purposes).
# Set to 0 if you want logging only to $LOG_FILE
ECHO_LOG=1



# In this file we list file patterns for N-files(applications). One row per base filename (application).
PATTERN_FILE="${SCRIPT_PATH}/config/patterns.txt"

# Do not add trailing slash.
SOURCE_DIR=/work/aggregator/data
DEST_DIR=/compressed_archives

# Only seek and compress files with these extensions
# TODO: convert to array
EXT_PATTERN=".json"
EXT_PATTERN2=".log"

# General 7za command: use ionice and nice to set 'niceness' for this process and lower impact on other running processes during compression.
# 7za parameters: 
# -mx=9 (maximum compression), 
# -mmt=off (use only one thread to lower impact on other processes), 
# -sdel (delete source file after successfully added to archive)
COMMAND_PART1="ionice -c 3 nice -n +19 7za a -t7z -mx=9 -mmt=off -sdel "
