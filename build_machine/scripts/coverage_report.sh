#!/bin/bash -e

COVERAGE_DIR="$1"
REPORT_DIR="$COVERAGE_DIR/report"
KERNEL_DIR="~/Learning/P_Science_Paper/Ext4/Linux_Kernels/linux-6.8.5"

echo "Reporting coverage from $COVERAGE_DIR..."

mkdir -p "$REPORT_DIR" &&
lcov --directory $KERNEL_DIR/fs/ext4 --filter range --capture --output-file $REPORT_DIR/kernel.info &&
genhtml $REPORT_DIR/kernel.info -o $REPORT_DIR &&
google-chrome $REPORT_DIR/index.html