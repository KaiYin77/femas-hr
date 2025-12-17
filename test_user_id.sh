#!/bin/bash

####################################
# Inspect Femas Cloud for User ID
# This script helps identify where
# the user_id is located
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
MAIN_URL="https://www.femascloud.com/upbeattech/users/main"
COOKIE="/tmp/femas_inspect.cookies"

# ---- clean old cookie ----
rm -f "$COOKIE"

# ---- login ----
echo "=== Logging in ==="
curl -s -L -c "$COOKIE" \
  -X POST "$LOGIN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Referer: $LOGIN_URL" \
  --data "data[Account][username]=$FEMAS_USER&data[Account][passwd]=$FEMAS_PASS&data[remember]=1" > /dev/null

# ---- fetch main page ----
echo -e "\n=== Fetching main page ==="
MAIN_PAGE_RESPONSE=$(curl -s -b "$COOKIE" "$MAIN_URL")

echo "$MAIN_PAGE_RESPONSE" > /tmp/femas_main_page.html
echo "Main page saved to /tmp/femas_main_page.html"

# ---- Try to extract user_id ----
echo -e "\n=== Searching for user_id patterns ==="

# Method 1: Look for user_id in URLs
echo "1. Searching in URLs/links:"
echo "$MAIN_PAGE_RESPONSE" | grep -oE "user_id[=/][0-9]+" | head -5

# Method 2: Look for data attributes
echo -e "\n2. Searching in data attributes:"
echo "$MAIN_PAGE_RESPONSE" | grep -oE "data-user-id=\"[0-9]+\"" | head -5

# Method 3: Look for JavaScript variables
echo -e "\n3. Searching in JavaScript variables:"
echo "$MAIN_PAGE_RESPONSE" | grep -oE "(var |let |const )?user_?id.*=.*[0-9]+" | head -5

# Method 4: Look for value attributes with user_id name
echo -e "\n4. Searching in input/hidden fields:"
echo "$MAIN_PAGE_RESPONSE" | grep -oE "name=\".*user_id.*\" value=\"[0-9]+\"" | head -5

# Method 5: Look for JSON data
echo -e "\n5. Searching in JSON structures:"
echo "$MAIN_PAGE_RESPONSE" | grep -oE "\"user_id\":\s*[0-9]+" | head -5

# ---- cleanup ----
rm -f "$COOKIE"

echo -e "\n=== Done ==="
echo "Review the patterns above to identify where user_id appears."
echo "The full HTML is saved at: /tmp/femas_main_page.html"
