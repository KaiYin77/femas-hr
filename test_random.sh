#!/bin/bash

####################################
# Test script to verify RANDOM distribution
# Tests the same logic used in femas_checkout.sh
####################################

echo "========================================="
echo "  RANDOM Distribution Test"
echo "========================================="
echo ""
echo "Testing range: 0-1199 seconds (0-20 minutes)"
echo "Sample size: 100 iterations"
echo ""

# Arrays to hold statistics
declare -a delays
total=0
min=9999
max=0

# Generate 100 random delays
echo "Generating 100 random delays..."
for i in {1..100}; do
  DELAY=$(( RANDOM % 1200 ))
  delays+=($DELAY)
  total=$((total + DELAY))

  if [ $DELAY -lt $min ]; then
    min=$DELAY
  fi

  if [ $DELAY -gt $max ]; then
    max=$DELAY
  fi
done

# Calculate average
avg=$((total / 100))

echo ""
echo "========================================="
echo "STATISTICS:"
echo "========================================="
echo "Minimum delay:    $min seconds"
echo "Maximum delay:    $max seconds"
echo "Average delay:    $avg seconds"
echo "Expected average: ~600 seconds"
echo ""

# Show distribution in 5-minute buckets
echo "========================================="
echo "DISTRIBUTION (5-minute buckets):"
echo "========================================="

bucket_0_5=0
bucket_5_10=0
bucket_10_15=0
bucket_15_20=0

for delay in "${delays[@]}"; do
  if [ $delay -lt 300 ]; then
    bucket_0_5=$((bucket_0_5 + 1))
  elif [ $delay -lt 600 ]; then
    bucket_5_10=$((bucket_5_10 + 1))
  elif [ $delay -lt 900 ]; then
    bucket_10_15=$((bucket_10_15 + 1))
  else
    bucket_15_20=$((bucket_15_20 + 1))
  fi
done

echo " 0-5  min: $bucket_0_5 samples $(printf '=%.0s' $(seq 1 $bucket_0_5))"
echo " 5-10 min: $bucket_5_10 samples $(printf '=%.0s' $(seq 1 $bucket_5_10))"
echo "10-15 min: $bucket_10_15 samples $(printf '=%.0s' $(seq 1 $bucket_10_15))"
echo "15-20 min: $bucket_15_20 samples $(printf '=%.0s' $(seq 1 $bucket_15_20))"
echo ""

# Show first 10 samples
echo "========================================="
echo "FIRST 10 SAMPLES:"
echo "========================================="
for i in {0..9}; do
  printf "Sample %2d: %4d seconds\n" $((i+1)) ${delays[$i]}
done

echo ""
echo "========================================="
echo "CONCLUSION:"
echo "========================================="

# Check if distribution is reasonable
if [ $avg -ge 400 ] && [ $avg -le 800 ]; then
  echo "[PASS] Average is within expected range"
else
  echo "[FAIL] Average is outside expected range"
  exit 1
fi

if [ $min -lt 100 ] && [ $max -gt 1100 ]; then
  echo "[PASS] Good spread across full range"
else
  echo "[WARN] Limited spread detected"
fi

if [ $bucket_0_5 -ge 15 ] && [ $bucket_0_5 -le 35 ] && \
   [ $bucket_5_10 -ge 15 ] && [ $bucket_5_10 -le 35 ] && \
   [ $bucket_10_15 -ge 15 ] && [ $bucket_10_15 -le 35 ] && \
   [ $bucket_15_20 -ge 15 ] && [ $bucket_15_20 -le 35 ]; then
  echo "[PASS] Distribution is fairly even"
else
  echo "[WARN] Distribution may be uneven"
fi

echo ""
echo "Note: Bash \$RANDOM is a pseudo-random number generator."
echo "It's sufficient for timing delays but not for cryptographic use."
echo ""
exit 0
