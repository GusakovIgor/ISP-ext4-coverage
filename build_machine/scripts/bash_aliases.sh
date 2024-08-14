# !!!!!
# Those functions are added to ~/.bash_aliases file on BUILD machine.
# !!!!!

COVERAGE_PROJECT_DIR="$(realpath ~/Learning/P_Science_Paper/Ext4)"

function latest_subdir() {
    SUBDIRS=( $(find $1 -maxdepth 1 -type d -printf "%P\n" | sort -) )
    echo ${SUBDIRS[-1]}
}

function latest_coverage_dir() {
    LATEST_COVERAGE_DATE=$(latest_subdir $COVERAGE_PROJECT_DIR/coverage)
    LATEST_COVERAGE_TIME=$(latest_subdir $COVERAGE_PROJECT_DIR/coverage/$LATEST_COVERAGE_DATE)

    echo "$COVERAGE_PROJECT_DIR/coverage/$LATEST_COVERAGE_DATE/$LATEST_COVERAGE_TIME"
}

function coverage_apply() {

    COVERAGE_DIR=""

    if [[ -n $1 ]]
    then
        COVERAGE_DIR="$(realpath $1)"
    else
        COVERAGE_DIR="$(latest_coverage_dir)"
    fi

    WORKING_DIR="$PWD"
    cd $COVERAGE_PROJECT_DIR

    tar xzf $COVERAGE_DIR/ext4.tar.gz

    ./scripts/coverage_apply.sh $COVERAGE_DIR
    cd $WORKING_DIR
}

function coverage_report() {
    COVERAGE_DIR=""

    if [[ -n $1 ]]
    then
        COVERAGE_DIR="$(realpath $1)"
    else
        COVERAGE_DIR="$(latest_coverage_dir)"
    fi

    WORKING_DIR="$PWD"
    cd $COVERAGE_PROJECT_DIR
    ./scripts/coverage_report.sh $COVERAGE_DIR
    cd $WORKING_DIR
}