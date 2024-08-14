#!/bin/bash -e

COVERAGE_DIR="$1"
echo "Applying coverage from $COVERAGE_DIR..."

# Directory with kernel sources corresponding to gathered coverage
TARGET_DIR=$(find $COVERAGE_DIR -name "*.gcno" -print -quit)
TARGET_DIR=$(realpath $TARGET_DIR)
TARGET_DIR=${TARGET_DIR%/*}
echo "Kernel sources located at $TARGET_DIR"

# Removing old coverage data from kernel sources
OLD_COVERAGE=$(find $TARGET_DIR -name "*.gcda")
if [[ -n $OLD_COVERAGE ]]
then
    echo "Removing old coverage:"
    for file in $OLD_COVERAGE
    do
        echo -e "\tRemoving $file"
        rm $file
    done
else
    echo "No coverage data to cleanup"
fi


echo "Copying new coverage:"
for datafile in $(find $COVERAGE_DIR -name "*.gcda")
do
    file=${datafile%.gcda}
    filename=${file##*/}
    notesfile="$file.gcno"

    # Copying new coverage data to kernel sources
    cp "$datafile" "$TARGET_DIR/$filename.gcda"
    echo -e "\tCopying from coverage $TARGET_DIR/$filename.gcda"
done
