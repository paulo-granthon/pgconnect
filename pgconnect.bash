#!/bin/bash

# Set the script to exit if any command fails
set -eo pipefail

# define variable defaults
DEFAULT_VAR_NAME_DB_USER="DB_USER"
DEFAULT_VAR_NAME_DB_PASS="DB_PASS"
DEFAULT_VAR_NAME_DB_HOST="DB_HOST"
DEFAULT_VAR_NAME_DB_NAME="DB_NAME"
DEFAULT_VAR_NAME_DB_PORT="DB_PORT"
DEFAULT_ENV_FILE=".env"

# Define the environment variables names
VAR_NAME_DB_USER=""
VAR_NAME_DB_PASS=""
VAR_NAME_DB_HOST=""
VAR_NAME_DB_NAME=""
VAR_NAME_DB_PORT=""
ENV_FILE=''

# Define the colors
RESET='\033[0m'
RED='\033[0;31m'

# Function to check if a variable is empty
function check_variable() {
	if [ -z "$1" ]; then
		echo -e "${RED}Error: $2 is empty. Cannot connect to the database.${RESET}"
		return 1
	fi
}

# capture the result of each check_variable call and if all of them fail, echo a custom message
# if all of them pass, then the script will continue to the next step
# the script will exit if any of the checks fail
function check_variables() {
	USER_CHECK="$(check_variable "${!VAR_NAME_DB_USER}" "${VAR_NAME_DB_USER}")"
	PASS_CHECK="$(check_variable "${!VAR_NAME_DB_PASS}" "${VAR_NAME_DB_PASS}")"
	HOST_CHECK="$(check_variable "${!VAR_NAME_DB_HOST}" "${VAR_NAME_DB_HOST}")"
	PORT_CHECK="$(check_variable "${!VAR_NAME_DB_PORT}" "${VAR_NAME_DB_PORT}")"

	if [ -n "$USER_CHECK" ]; then echo "${USER_CHECK}"; fi
	if [ -n "$PASS_CHECK" ]; then echo "${PASS_CHECK}"; fi
	if [ -n "$HOST_CHECK" ]; then echo "${HOST_CHECK}"; fi
	if [ -n "$PORT_CHECK" ]; then echo "${PORT_CHECK}"; fi
}

# function to imediately execute a query on connect
function watch_query() {
	query=${1:-"show databases"}
	if [ -z "$query" ]; then
		echo "No query provided. Please provide a query to watch."
		return 1
	fi

	DB_NAME_OR_EMPTY=""
	if [ -n "${!VAR_NAME_DB_NAME}" ]; then
		DB_NAME_OR_EMPTY="-d ${!VAR_NAME_DB_NAME}"
	fi

	watch -etn 1 "PGPASSWORD=${!VAR_NAME_DB_PASS} psql -h ${!VAR_NAME_DB_HOST} -U ${!VAR_NAME_DB_USER} -p ${!VAR_NAME_DB_PORT} ${DB_NAME_OR_EMPTY} -c '$query'"
	clear
}

# Function to execute a query once
function execute_query_once() {
	query=${1:-"show databases"}
	if [ -z "$query" ]; then
		echo "No query provided. Please provide a query to execute."
		return 1
	fi

	DB_NAME_OR_EMPTY=""
	if [ -n "${!VAR_NAME_DB_NAME}" ]; then
		DB_NAME_OR_EMPTY="-d ${!VAR_NAME_DB_NAME}"
	fi

	PGPASSWORD="${!VAR_NAME_DB_PASS}" psql -h "${!VAR_NAME_DB_HOST}" -U "${!VAR_NAME_DB_USER}" -p "${!VAR_NAME_DB_PORT}" "${DB_NAME_OR_EMPTY}" -c "$query"
}

# Function to execute a SQL script file
function execute_sql_script_file() {
	script_file=${1}

	if [ ! -f "${script_file}" ]; then
		echo "File \`${script_file}\` does not exist."
		echo -e "Usage: $0 <db_index> --script <script_file>"
		exit 1
	fi

	DB_NAME_OR_EMPTY=""
	if [ -n "${!VAR_NAME_DB_NAME}" ]; then
		DB_NAME_OR_EMPTY="-d ${!VAR_NAME_DB_NAME}"
	fi

	echo "Executing SQL script file: ${script_file}"

	PGPASSWORD="${!VAR_NAME_DB_PASS}" psql -h "${!VAR_NAME_DB_HOST}" -U "${!VAR_NAME_DB_USER}" -p "${!VAR_NAME_DB_PORT}" "${DB_NAME_OR_EMPTY}" -f "$script_file"
}

# Connect to the database using pgcli
function connect_to_database() {
	echo "Connecting to '${!VAR_NAME_DB_NAME}' database..."
	pgcli postgresql://"${!VAR_NAME_DB_USER}":"${!VAR_NAME_DB_PASS}"@"${!VAR_NAME_DB_HOST}":"${!VAR_NAME_DB_PORT}"/"${!VAR_NAME_DB_NAME}"
}

### Main script starts here ###
WAS_VAR_NAME_DB_USER=false
WAS_VAR_NAME_DB_PASS=false
WAS_VAR_NAME_DB_HOST=false
WAS_VAR_NAME_DB_NAME=false
WAS_VAR_NAME_DB_PORT=false
WAS_ENV_FILE_PASSED=false

# capture the command flag.
# This will be used to determine which function to execute
# or if the script should just connect to the database
COMMAND_FLAG=''

# parse arguments
for arg in "$@"; do
	case "$arg" in
	"--user" | "--username" | "-u")
		WAS_VAR_NAME_DB_USER=true; VAR_NAME_DB_USER="$2"; shift;
		;;
	"--pass" | "--password" | "-a")
		WAS_VAR_NAME_DB_PASS=true; VAR_NAME_DB_PASS="$2"; shift;
		;;
	"--host" | "--hostname" | "-h")
		WAS_VAR_NAME_DB_HOST=true; VAR_NAME_DB_HOST="$2"; shift;
		;;
	"--name" | "-n")
		WAS_VAR_NAME_DB_NAME=true; VAR_NAME_DB_NAME="$2"; shift;
		;;
	"--port" | "-p")
		WAS_VAR_NAME_DB_PORT=true; VAR_NAME_DB_PORT="$2"; shift;
		;;
	"--env" | "-e")
		WAS_ENV_FILE_PASSED=true; ENV_FILE="$2"; shift;
		;;
	"--watch" | "-w")
		COMMAND_FLAG="$arg"
		;;
	"--query" | "-q")
		COMMAND_FLAG="$arg"
		;;
	"--script" | "-s")
		COMMAND_FLAG="$arg"
		;;
	esac
done

# set the default variable names if they were not passed
if [ "$WAS_VAR_NAME_DB_USER" == false ]; then VAR_NAME_DB_USER="$DEFAULT_VAR_NAME_DB_USER"; fi
if [ "$WAS_VAR_NAME_DB_PASS" == false ]; then VAR_NAME_DB_PASS="$DEFAULT_VAR_NAME_DB_PASS"; fi
if [ "$WAS_VAR_NAME_DB_HOST" == false ]; then VAR_NAME_DB_HOST="$DEFAULT_VAR_NAME_DB_HOST"; fi
if [ "$WAS_VAR_NAME_DB_NAME" == false ]; then VAR_NAME_DB_NAME="$DEFAULT_VAR_NAME_DB_NAME"; fi
if [ "$WAS_VAR_NAME_DB_PORT" == false ]; then VAR_NAME_DB_PORT="$DEFAULT_VAR_NAME_DB_PORT"; fi
if [ "$WAS_ENV_FILE_PASSED" == false ]; then ENV_FILE="$DEFAULT_ENV_FILE"; fi

# check if the environment file exists
if [ ! -f "$ENV_FILE" ]; then
	echo -e "Environment file \`${RED}${ENV_FILE}${RESET}\` not found. Please provide a valid environment file."
	exit 1
fi

# if there's a value in ENV_FILE, source the corresponding file.
if [ -n "$ENV_FILE" ]; then
	echo "Sourcing environment file: $ENV_FILE"

	# shellcheck disable=SC1090
	source "$ENV_FILE"
fi

# check if variables are set and exit if any of them is empty
VARIALBES_CHECK=$(check_variables)
if [ -n "$VARIALBES_CHECK" ]; then
	echo -e "\nVARIALBES_CHECK: ${VARIALBES_CHECK}"
	echo -e "${RED}"
	echo "Make sure to provide the environment variables."
	echo "Either source the environment file or provide the path to the environment file as an argument."
	echo "Example: ./pgconnect.sh .env"
	echo "or source the environment file before running the script."
	echo "Example: source .env && ./pgconnect.sh"
	echo -e "${RESET}"

	exit 1
fi

# match the flag and execute the corresponding function
case "$COMMAND_FLAG" in
"--watch" | "-w")
	query=${2:-"show databases"}
	watch_query "${query}"
	;;
"--query" | "-q")
	query=${2:-"show databases"}
	execute_query_once "${query}"
	;;
"--script" | "-s")
	execute_sql_script_file "$2"
	;;
*)
	# If no specific flag is provided, execute pgcli command
	connect_to_database
	;;
esac
