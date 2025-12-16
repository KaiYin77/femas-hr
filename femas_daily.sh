#!/bin/bash

####################################
# FemAs Cloud Daily Check-in Script
# - Credentials inside this file
# - Skip weekends
# - Random delay
# - Login
# - Check-in
####################################

# ---- credentials (EDIT THESE) ----
FEMAS_USER="UT2024070043"
FEMAS_PASS="KKkk123456"

# ---- URLs ----
LOGIN_URL="https://www.femascloud.com/upbeattech/Accounts/login"
CLOCK_LISTING_URL="https://www.femascloud.com/upbeattech/clock_listing"
REVISION_SAVE_URL="https://www.femascloud.com/upbeattech/revision_save"
STATUS_URL="https://www.femascloud.com/upbeattech/att_status_listing"
LOGOUT_URL="https://www.femascloud.com/upbeattech/accounts/logout"

COOKIE="/tmp/femas.cookies"

# ---- skip weekend ----
DAY=$(date +%u)   # 1=Mon ... 6=Sat 7=Sun
if [ "$DAY" -ge 6 ]; then
  echo "$(date) | 🟡 Weekend detected, skipping check-in"
  exit 0
fi

# ---- random delay (0–20 minutes) ----
# DELAY=$(( RANDOM % 1200 ))
DELAY=0
echo "$(date) | Sleeping ${DELAY}s before check-in"
sleep "$DELAY"

# ---- clean old cookie ----
rm -f "$COOKIE"

# ---- login ----
echo "$(date) | Logging in"
curl -s -L -c "$COOKIE" \
  -X POST "$LOGIN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Referer: $LOGIN_URL" \
  --data "data[Account][username]=$FEMAS_USER&data[Account][passwd]=$FEMAS_PASS&data[remember]=1" > /dev/null

# ---- warm up server state ----
echo "$(date) | Initializing clock state"
# curl -s -b "$COOKIE" "$CLOCK_LISTING_URL" > /dev/null

# ---- check-in (REAL ACTION) ----
echo "$(date) | 🟢 Performing check-in"
curl -s -b "$COOKIE" \
  -X POST "$REVISION_SAVE_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data "pk=users%2Fshow_time" > /dev/null

# ---- optional verify ----
echo "$(date) | Refreshing attendance status"
# curl -s -b "$COOKIE" "$STATUS_URL" > /dev/null

# ---- logout ----
echo "$(date) | Logging out"
curl -s -b "$COOKIE" "$LOGOUT_URL" > /dev/null

# ---- cleanup ----
rm -f "$COOKIE"
