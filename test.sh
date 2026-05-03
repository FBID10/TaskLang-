#!/bin/bash
echo "Running TaskLang Test Suite..."
echo ""

# Valid Tests
echo "[TEST] Valid Tasks"
./TaskLang tests/valid_basic.txt > /dev/null
if [ $? -eq 0 ]; then echo "  ✓ Passed"; else echo "  ✗ Failed"; fi

# Error Tests
echo "[TEST] Missing Brace Error"
./TaskLang tests/error_missing_brace.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "  ✓ Passed (caught error)"; else echo "  ✗ Failed (did not catch error)"; fi

echo ""
echo "Test Suite Complete!"