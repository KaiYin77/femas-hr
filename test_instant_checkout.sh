#!/bin/bash

####################################
# Instant Checkout Test
# Tests checkout script without delay
####################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

echo "========================================="
echo "  Instant Checkout Test"
echo "========================================="
echo ""

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "[FAIL] .env file not found at $ENV_FILE"
  echo "       Please run install.bat first"
  exit 1
fi

echo "[INFO] Running checkout script with SKIP_DELAY enabled"
echo "       This will test credentials without random delay"
echo ""

# Set SKIP_DELAY and run checkout script
export SKIP_DELAY=1
bash "$SCRIPT_DIR/femas_checkout.sh"
RESULT=$?

echo ""
if [ $RESULT -eq 0 ]; then
  echo "========================================="
  echo "[PASS] Instant checkout test succeeded!"
  echo "========================================="
  echo ""
  echo "Your credentials and checkout script are working correctly."
  exit 0
else
  echo "========================================="
  echo "[FAIL] Instant checkout test failed"
  echo "========================================="
  echo ""
  echo "Please check:"
  echo "  - Your credentials in .env file"
  echo "  - Your network connection"
  echo "  - The error messages above"
  exit 1
fi
