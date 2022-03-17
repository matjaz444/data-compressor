# General bash logging function write_log() and TRACE_LEVEL consts
# v 1.15
# Author: Matjaz Skoda, matjaz.skoda@gmail.com

# Trace level consts
TRACE_OFF=0
TRACE_ERROR=1
TRACE_WARN=2
TRACE_INFO=3
TRACE_VERBOSE=4

TRACE_ERROR_PREFIX="ERROR: "
TRACE_WARN_PREFIX="WARN: "
TRACE_INFO_PREFIX="INFO: "
TRACE_VERBOSE_PREFIX="VERBOSE: "


# write_log(): write log strings/messages to $LOG_FILE
# $1 - message
# $2 - verbosity level [TRACE_OFF|TRACE_ERROR|TRACE_WARN|TRACE_INFO|TRACE_VERBOSE(default)]
# $3 - any - if any value specified, there will be no ECHO_LOG output to stdout (even if $ECHO_LOG=1)
write_log()
{
	local no_echo=false
	
	# if level not defined set it to verbose
	if [ -z ${TRACE_LEVEL+x} ]; then
		TRACE_LEVEL=$TRACE_VERBOSE
	fi
	
	if [ ${TRACE_LEVEL} -eq ${TRACE_OFF} ]; then
		return
	fi
	
	if [ -z ${2+x} ]; then
		local trace_level=${TRACE_VERBOSE}
	else
		local trace_level=$2
	fi

	if [ ! -z ${3+x} ]; then
		local no_echo=true
	fi

	if [ ${trace_level} -le ${TRACE_LEVEL} ]; then
	
		case ${trace_level} in
			${TRACE_ERROR}) _prefix=${TRACE_ERROR_PREFIX} ;;
			${TRACE_WARN}) _prefix=${TRACE_WARN_PREFIX} ;;
			${TRACE_INFO}) _prefix=${TRACE_INFO_PREFIX} ;;
			${TRACE_VERBOSE}) _prefix=${TRACE_VERBOSE_PREFIX} ;;
			*) _prefix="undefined: " ;;
		esac

		# Current time stamp		
		local TS=$(date '+%Y-%m-%d %H:%M:%S')
		
		# check if variable $LOG_FILE is defined
		if [ -z ${LOG_FILE+x} ]; then
			if [ ! -z ${log_file+x} ]; then
				LOG_FILE="$log_file"
			else
				echo "ERROR write_log(): LOG_FILE is not defined!"
				exit 1
			fi
		fi
		echo $TS": "${_prefix}$1 >> "$LOG_FILE"
		
		if [ ! -z ${ECHO_LOG+x} ] && [ $ECHO_LOG -eq 1 ]; then 
			if [[ $no_echo = false ]]; then
				echo $TS": "${_prefix}$1
			fi
		fi
	fi
}



# deprecated
# $1 - message
# $2(optional) - custom path to log file
write_log_old()
{
	TS=$(date '+%Y-%m-%d %H:%M:%S')
	if [ $# -eq 2 ]; then
		echo $TS": "$1 >> $2
	else
		echo $TS": "$1 >> $LOG_FILE
	fi	
}

