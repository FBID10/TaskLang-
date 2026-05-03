#!/bin/bash
echo "Running TaskLang Test Suite..."
echo ""

# Valid Tests
echo "[TEST] Valid Basic Tasks"
./TaskLang tests/valid_basic.txt > /dev/null
if [ $? -eq 0 ]; then echo "  ✓ Passed"; else echo "  ✗ Failed"; fi

echo "[TEST] Valid Simple Task (RUN only)"
./TaskLang tests/valid_simple.txt > /dev/null
if [ $? -eq 0 ]; then echo "  ✓ Passed"; else echo "  ✗ Failed"; fi

echo "[TEST] Valid Comprehensive (all features)"
./TaskLang tests/valid_comprehensive.txt > /dev/null
if [ $? -eq 0 ]; then echo "  ✓ Passed"; else echo "  ✗ Failed"; fi

echo "[TEST] Valid Task with Dependencies"
./TaskLang tests/valid_dependency.txt > /dev/null
if [ $? -eq 0 ]; then echo "  ✓ Passed"; else echo "  ✗ Failed"; fi

# Error Tests
echo ""
echo "[ERROR TEST] Missing Closing Brace"
./TaskLang tests/error_missing_brace.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "  ✓ Passed (caught error)"; else echo "  ✗ Failed (did not catch error)"; fi

echo "[ERROR TEST] Invalid Keyword"
./TaskLang tests/error_invalid_keyword.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "  ✓ Passed (caught error)"; else echo "  ✗ Failed (did not catch error)"; fi

echo "[ERROR TEST] Missing RUN Statement"
./TaskLang tests/error_missing_run.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "  ✓ Passed (caught error)"; else echo "  ✗ Failed (did not catch error)"; fi

echo "[ERROR TEST] Invalid Time Format"
./TaskLang tests/error_invalid_time.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "  ✓ Passed (caught error)"; else echo "  ✗ Failed (did not catch error)"; fi

echo "[ERROR TEST] Missing Task Name"
./TaskLang tests/error_missing_name.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "  ✓ Passed (caught error)"; else echo "  ✗ Failed (did not catch error)"; fi

echo "[ERROR TEST] Undefined Character"
./TaskLang tests/error_undefined_char.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then echo "  ✓ Passed (caught error)"; else echo "  ✗ Failed (did not catch error)"; fi

echo ""
echo "Test Suite Complete!"