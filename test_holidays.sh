#!/bin/bash

####################################
# Test script for holidays configuration
# Tests both single dates and date ranges
####################################

echo "========================================="
echo "  Holiday Configuration Test Script"
echo "========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOLIDAYS_FILE="$SCRIPT_DIR/holidays"

# Check if holidays file exists
if [ ! -f "$HOLIDAYS_FILE" ]; then
  echo "❌ ERROR: holidays file not found"
  echo "Please run: cp holidays.example holidays"
  exit 1
fi

echo "✓ holidays file found: $HOLIDAYS_FILE"
echo ""

# Test cases: [date, expected_result, description]
test_dates=(
  "2025-01-01:HOLIDAY:New Year 2025"
  "2025-01-02:WORK:Day after New Year"
  "2025-01-29:HOLIDAY:Spring Festival (in range 2025-01-27~2025-01-31)"
  "2025-02-01:WORK:After Spring Festival"
  "2025-04-04:HOLIDAY:Children's Day (single date)"
  "2025-04-05:HOLIDAY:Tomb Sweeping (in range 2025-04-04~2025-04-05)"
  "2025-06-02:HOLIDAY:Dragon Boat Festival"
  "2025-07-15:WORK:Regular working day"
  "2025-12-25:HOLIDAY:Constitution Day"
  "2026-01-01:HOLIDAY:New Year 2026"
  "2026-02-17:HOLIDAY:Spring Festival 2026 (in range 2026-02-16~2026-02-20)"
  "2026-05-01:HOLIDAY:Labor Day 2026"
)

echo "Running ${#test_dates[@]} test cases..."
echo "========================================="
echo ""

passed=0
failed=0

for test in "${test_dates[@]}"; do
  IFS=':' read -r test_date expected description <<< "$test"

  # Mock the date for testing by temporarily setting TODAY
  # We'll check the holidays file directly
  TODAY="$test_date"
  TODAY_TIMESTAMP=$(date -d "$TODAY" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$TODAY" +%s 2>/dev/null || echo "0")

  is_holiday=0

  # Check holidays file
  while IFS= read -r line || [ -n "$line" ]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    line=$(echo "$line" | sed 's/#.*//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$line" ] && continue

    # Check date range
    if [[ "$line" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})~([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]]; then
      START_DATE="${BASH_REMATCH[1]}"
      END_DATE="${BASH_REMATCH[2]}"

      start_ts=$(date -d "$START_DATE" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$START_DATE" +%s 2>/dev/null || echo "0")
      end_ts=$(date -d "$END_DATE" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$END_DATE" +%s 2>/dev/null || echo "0")

      if [ "$TODAY_TIMESTAMP" -ge "$start_ts" ] && [ "$TODAY_TIMESTAMP" -le "$end_ts" ]; then
        is_holiday=1
        break
      fi
    # Check single date
    elif [[ "$line" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      if [ "$TODAY" = "$line" ]; then
        is_holiday=1
        break
      fi
    fi
  done < "$HOLIDAYS_FILE"

  # Determine result
  if [ $is_holiday -eq 1 ]; then
    actual="HOLIDAY"
  else
    actual="WORK"
  fi

  # Check if test passed
  if [ "$actual" = "$expected" ]; then
    echo "✓ PASS: $test_date → $actual ($description)"
    passed=$((passed + 1))
  else
    echo "✗ FAIL: $test_date → Expected: $expected, Got: $actual ($description)"
    failed=$((failed + 1))
  fi
done

echo ""
echo "========================================="
echo "Test Results:"
echo "========================================="
echo "Total tests: ${#test_dates[@]}"
echo "Passed:      $passed"
echo "Failed:      $failed"
echo ""

if [ $failed -eq 0 ]; then
  echo "✓ All tests passed!"
  exit 0
else
  echo "✗ Some tests failed!"
  exit 1
fi
