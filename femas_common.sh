#!/bin/bash

####################################
# Common functions for Femas Cloud scripts
# This script is intended to be sourced by other scripts.
# It expects SCRIPT_DIR to be defined in the sourcing script.
####################################

# ---- Global variables ----
LOGIN_URL="https://www.femascloud.com/upbeattech/Accounts/login"
CLOCK_LISTING_URL="https://www.femascloud.com/upbeattech/Users/clock_listing"
REVISION_SAVE_URL="https://www.femascloud.com/upbeattech/revision_save"
STATUS_URL="https://www.femascloud.com/upbeattech/att_status_listing"
MAIN_URL="https://www.femascloud.com/upbeattech/users/main"
LOGOUT_URL="https://www.femascloud.com/upbeattech/accounts/logout"
COOKIE="/tmp/femas.cookies"

# ---- Functions ----

# Loads credentials from .env file
# Expects SCRIPT_DIR to be set.
load_env() {
	local env_file="$SCRIPT_DIR/.env"
	if [ ! -f "$env_file" ]; then
		echo "ERROR: .env file not found at $env_file"
		echo "Please copy .env.example to .env and fill in your credentials"
		exit 1
	fi
	export $(cat "$env_file" | grep -v '^#' | xargs)
	if [ -z "$FEMAS_USER" ] || [ -z "$FEMAS_PASS" ]; then
		echo "ERROR: FEMAS_USER or FEMAS_PASS not set in .env file"
		exit 1
	fi
}

# Checks for weekends and national holidays
# Expects SCRIPT_DIR to be set.
check_holiday() {
	local action=$1
	bash "$SCRIPT_DIR/check_holiday.sh"
	if [ $? -ne 0 ]; then
		echo "$(date) | 🟡 Holiday detected, skipping $action"
		exit 0
	fi
}

# Sleeps for a random delay (0-20 minutes)
random_delay() {
	local action=$1
	local color_icon=$2

	local delay_seconds=0
	if [ "$SKIP_DELAY" != "1" ] && [ "$SKIP_DELAY" != "true" ]; then
		delay_seconds=$(( $(shuf -i 0-99999 -n 1) % 300 ))
	fi
	echo "$(date) | $color_icon Sleeping ${delay_seconds}s before $action"
	sleep "$delay_seconds"
}

# ---- login Femas Cloud ----
login() {
	local color_icon=$1
	echo "$(date) | $color_icon Logging in"
	rm -f "$COOKIE"
	curl -s -L -c "$COOKIE" \
		-X POST "$LOGIN_URL" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		-H "Referer: $LOGIN_URL" \
		--data "data[Account][username]=$FEMAS_USER&data[Account][passwd]=$FEMAS_PASS&data[remember]=1" > /dev/null
	}

# ---- extract user_id from main page ----
get_user_id() {
	local color_icon=$1
	echo "$(date) | $color_icon Fetching user ID"
	local main_page_response
	main_page_response=$(curl -s -b "$COOKIE" "$MAIN_URL")
	# USER_ID is exported to the calling script's scope
	USER_ID=$(echo "$main_page_response" | grep -o 'ClockRecord\]\[user_id\]" value="[0-9]*"' | grep -o '[0-9]*' | head -1)
	if [ -z "$USER_ID" ]; then
		echo "$(date) | ❌ ERROR: Could not extract user_id from main page"
		echo "$(date) | 💡 Please run: bash inspect_user_id.sh"
		rm -f "$COOKIE"
		exit 1
	fi
	echo "$(date) | $color_icon User ID: $USER_ID"
}

# ---- step 1: clock listing ----
perform_clock_listing() {
	local color_icon=$1
	local clock_type=$2 # 'S' for check-in, 'E' for check-out
	echo "$(date) | $color_icon Clock listing"
	curl -s -b "$COOKIE" \
		-X POST "$CLOCK_LISTING_URL" \
		-H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
		-H "X-Requested-With: XMLHttpRequest" \
		-H "Referer: $MAIN_URL" \
		--data "_method=POST&data[ClockRecord][user_id]=$USER_ID&data[AttRecord][user_id]=$USER_ID&data[ClockRecord][shift_id]=&data[ClockRecord][period]=1&data[ClockRecord][clock_type]=$clock_type&data[ClockRecord][latitude]=&data[ClockRecord][longitude]=" > /dev/null
	}

# ---- step 2: revision save ----
perform_revision_save() {
	local color_icon=$1
	local pk_data=$2
	echo "$(date) | $color_icon Revision save"
	curl -s -b "$COOKIE" \
		-X POST "$REVISION_SAVE_URL" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		--data "pk=$pk_data" > /dev/null
	}

# ---- step 3: attendance status listing ----
verify_status() {
	local color_icon=$1
	echo "$(date) | $color_icon Attendance status verification"
	curl -s -b "$COOKIE" "$STATUS_URL" > /dev/null
}

# ---- logout ----
logout() {
	local color_icon=$1
	echo "$(date) | $color_icon Logging out"
	curl -s -b "$COOKIE" "$LOGOUT_URL" > /dev/null
	# ---- cleanup ----
	rm -f "$COOKIE"
}
