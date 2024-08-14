#!/bin/bash -e

COVERAGE_DIR="$1"
echo "Reporting coverage from $COVERAGE_DIR..."


# Directory with kernel sources corresponding to gathered coverage
TARGET_DIR=$(find $COVERAGE_DIR -name "*.gcno" -print -quit)
TARGET_DIR=$(realpath $TARGET_DIR)
TARGET_DIR=${TARGET_DIR%/*}
echo "Kernel sources located at $TARGET_DIR"


# Directory with coverage report
REPORT_DIR="$COVERAGE_DIR/report"
mkdir -p "$REPORT_DIR"
echo "Coverage report will be located at $REPORT_DIR"


# Generating report
lcov --directory $TARGET_DIR --ignore-errors negative --capture --output-file $REPORT_DIR/kernel.info &&
genhtml -o $REPORT_DIR $REPORT_DIR/kernel.info  &&
google-chrome $REPORT_DIR/index.html