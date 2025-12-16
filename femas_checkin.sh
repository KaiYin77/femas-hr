#!/bin/bash

####################################
# Femas Cloud Daily Check-in Script
# - Credentials loaded from .env file
# - Skip weekends
# - Random delay
# - Login
# - Check-in
####################################

# ---- Load credentials from .env file ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: .env file not found at $ENV_FILE"
  echo "Please copy .env.example to .env and fill in your credentials"
  exit 1
fi

# Load environment variables from .env
export $(cat "$ENV_FILE" | grep -v '^#' | xargs)

if [ -z "$FEMAS_USER" ] || [ -z "$FEMAS_PASS" ]; then
  echo "ERROR: FEMAS_USER or FEMAS_PASS not set in .env file"
  exit 1
fi

# ---- URLs ----
LOGIN_URL="https://www.femascloud.com/upbeattech/Accounts/login"
CLOCK_LISTING_URL="https://www.femascloud.com/upbeattech/Users/clock_listing"
REVISION_SAVE_URL="https://www.femascloud.com/upbeattech/revision_save"
STATUS_URL="https://www.femascloud.com/upbeattech/att_status_listing"
MAIN_URL="https://www.femascloud.com/upbeattech/users/main"
LOGOUT_URL="https://www.femascloud.com/upbeattech/accounts/logout"

COOKIE="/tmp/femas.cookies"

# ---- skip weekend ----
DAY=$(date +%u)   # 1=Mon ... 6=Sat 7=Sun
if [ "$DAY" -ge 6 ]; then
  echo "$(date) | 🟡 Weekend detected, skipping check-in"
  exit 0
fi

# ---- random delay (0–10 minutes) ----
DELAY=$(( RANDOM % 600 ))
# DELAY=0
echo "$(date) | Sleeping ${DELAY}s before check-in"
sleep "$DELAY"

# ---- clean old cookie ----
rm -f "$COOKIE"

# ---- login ----
echo "$(date) | 🟢 Logging in"
curl -s -L -c "$COOKIE" \
  -X POST "$LOGIN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Referer: $LOGIN_URL" \
  --data "data[Account][username]=$FEMAS_USER&data[Account][passwd]=$FEMAS_PASS&data[remember]=1" > /dev/null

# ---- extract user_id from main page ----
echo "$(date) | 🟢 Fetching user ID"
MAIN_PAGE_RESPONSE=$(curl -s -b "$COOKIE" "$MAIN_URL")

# Extract user_id from hidden input field
USER_ID=$(echo "$MAIN_PAGE_RESPONSE" | grep -o 'ClockRecord\]\[user_id\]" value="[0-9]*"' | grep -o '[0-9]*' | head -1)

if [ -z "$USER_ID" ]; then
  echo "$(date) | ❌ ERROR: Could not extract user_id from main page"
  echo "$(date) | 💡 Please run: bash inspect_user_id.sh"
  rm -f "$COOKIE"
  exit 1
fi

echo "$(date) | 🟢 User ID: $USER_ID"

# ---- step 1: clock listing ----
echo "$(date) | 🟢 Step 1: Clock listing"
curl -s -b "$COOKIE" \
  -X POST "$CLOCK_LISTING_URL" \
  -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
  -H "X-Requested-With: XMLHttpRequest" \
  -H "Referer: $MAIN_URL" \
  --data "_method=POST&data[ClockRecord][user_id]=$USER_ID&data[AttRecord][user_id]=$USER_ID&data[ClockRecord][shift_id]=&data[ClockRecord][period]=1&data[ClockRecord][clock_type]=S&data[ClockRecord][latitude]=&data[ClockRecord][longitude]=" > /dev/null

# ---- step 2: revision save ----
echo "$(date) | 🟢 Step 2: Revision save"
curl -s -b "$COOKIE" \
  -X POST "$REVISION_SAVE_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data "pk=users%2Fshow_time" > /dev/null

# ---- step 3: attendance status listing ----
echo "$(date) | 🟢 Step 3: Attendance status verification"
curl -s -b "$COOKIE" "$STATUS_URL" > /dev/null

# ---- logout ----
echo "$(date) | 🟢 Logging out"
curl -s -b "$COOKIE" "$LOGOUT_URL" > /dev/null

# ---- cleanup ----
rm -f "$COOKIE"
