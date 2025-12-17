#!/bin/bash

####################################
# Holiday Detection Script
# - Checks if today is a weekend
# - Checks if today is a holiday (from holidays config file)
# - Supports single dates and date ranges (YYYY-MM-DD~YYYY-MM-DD)
# Returns: 0 if working day, 1 if holiday
####################################

# Get script directory and config file path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOLIDAYS_FILE="$SCRIPT_DIR/holidays"

# Get today's date
TODAY=$(date +%Y-%m-%d)
TODAY_TIMESTAMP=$(date -d "$TODAY" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$TODAY" +%s)
DAY_OF_WEEK=$(date +%u)   # 1=Mon ... 6=Sat 7=Sun

# ---- Check weekend ----
if [ "$DAY_OF_WEEK" -ge 6 ]; then
  echo "$(date) | 🟡 Weekend detected (Day $DAY_OF_WEEK), skipping attendance"
  exit 1
fi

# ---- Check if holidays file exists ----
if [ ! -f "$HOLIDAYS_FILE" ]; then
  echo "$(date) | ⚠️  WARNING: holidays file not found at $HOLIDAYS_FILE"
  echo "$(date) | 💡 Please copy holidays.example to holidays and customize it"
  echo "$(date) | 🟢 Proceeding as working day (only weekend check active)"
  exit 0
fi

# ---- Function to check if date is in range ----
is_date_in_range() {
  local check_date="$1"
  local start_date="$2"
  local end_date="$3"

  # Convert dates to timestamps for comparison
  local check_ts=$(date -d "$check_date" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$check_date" +%s)
  local start_ts=$(date -d "$start_date" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$start_date" +%s)
  local end_ts=$(date -d "$end_date" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$end_date" +%s)

  if [ "$check_ts" -ge "$start_ts" ] && [ "$check_ts" -le "$end_ts" ]; then
    return 0  # true - date is in range
  else
    return 1  # false - date is not in range
  fi
}

# ---- Read holidays from config file ----
while IFS= read -r line || [ -n "$line" ]; do
  # Skip empty lines and comments
  [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

  # Remove inline comments and trim whitespace
  line=$(echo "$line" | sed 's/#.*//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Skip if line is empty after removing comments
  [ -z "$line" ] && continue

  # Check if this is a date range (contains ~)
  if [[ "$line" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})~([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]]; then
    # Date range format: YYYY-MM-DD~YYYY-MM-DD
    START_DATE="${BASH_REMATCH[1]}"
    END_DATE="${BASH_REMATCH[2]}"

    if is_date_in_range "$TODAY" "$START_DATE" "$END_DATE"; then
      echo "$(date) | 🟡 Holiday detected ($TODAY is in range $START_DATE ~ $END_DATE), skipping attendance"
      exit 1
    fi
  elif [[ "$line" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    # Single date format: YYYY-MM-DD
    if [ "$TODAY" = "$line" ]; then
      echo "$(date) | 🟡 Holiday detected ($TODAY), skipping attendance"
      exit 1
    fi
  else
    echo "$(date) | ⚠️  WARNING: Invalid date format in holidays file: $line"
  fi
done < "$HOLIDAYS_FILE"

# ---- Working day ----
echo "$(date) | 🟢 Working day confirmed ($TODAY)"
exit 0
