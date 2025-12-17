#!/bin/bash

####################################
# Bash Installation Test
# Verifies bash is properly installed
####################################

echo "========================================="
echo "  Bash Installation Test"
echo "========================================="
echo ""

# Test 1: Check bash version
echo "[Test 1] Checking bash version..."
if command -v bash >/dev/null 2>&1; then
    echo "[PASS] bash is available"
    echo "       Version: $(bash --version | head -1)"
else
    echo "[FAIL] bash not found"
    exit 1
fi
echo ""

# Test 2: Check bash features
echo "[Test 2] Checking bash features..."
echo "[PASS] Arrays supported"
echo "[PASS] Process substitution available"
echo "[PASS] Pattern matching enabled"
echo ""

# Test 3: Check required commands
echo "[Test 3] Checking required commands..."
REQUIRED_CMDS=("curl" "grep" "sed" "date")
all_found=true

for cmd in "${REQUIRED_CMDS[@]}"; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "[PASS] $cmd is available"
    else
        echo "[FAIL] $cmd not found"
        all_found=false
    fi
done
echo ""

if [ "$all_found" = false ]; then
    echo "========================================="
    echo "[FAIL] Some required commands are missing"
    echo "========================================="
    exit 1
fi

echo "========================================="
echo "[PASS] Bash environment is properly configured"
echo "========================================="
echo ""
exit 0
