# !!!!!
# Those functions are added to ~/.bash_aliases file on TEST machine.
# !!!!!


# Common
alias cls=clear


# Coverage
COVERAGE_DIR="$(realpath ~/Coverage)"
LOG_FILE="$COVERAGE_DIR/latest.log"

function coverage_test() {
    WORKING_DIR="$PWD"

    cd $COVERAGE_DIR/xfstests-dev
    TEST_DIR=$1
    if [[ -n $TEST_DIR ]]
    then
        sudo ./check $TEST_DIR/* | tee $LOG_FILE
    else
        sudo ./check | tee $LOG_FILE
    fi
    cd $WORKING_DIR
}

function coverage_reset() {
    echo "Coverage reset" | sudo tee /sys/kernel/debug/gcov/reset
    echo "All coverage in /sys/kernel/debug/gcov should be empty"
}

function coverage_gather () {
    WORKING_DIR="$PWD"
    DEST_DIR="share/$(date '+%Y_%m_%d')/$(date '+%H_%M')"

    cd $COVERAGE_DIR
    sudo mkdir -p "$DEST_DIR" &&
    sudo ./scripts/gather_on_test.sh "$DEST_DIR/ext4.tar.gz" &&
    sudo cp $LOG_FILE "$DEST_DIR/tests.log"
    cd $WORKING_DIR
}

function coverage_help() {
    OPTIND=1

    TEST_HELP_STRING=""
    TEST_HELP_STRING+="On your TM execute:\n"
    TEST_HELP_STRING+="1. coverage_reset\n"
    TEST_HELP_STRING+="    This will reset all previously gathered coverage.\n"
    TEST_HELP_STRING+="2. coverage_test\n"
    TEST_HELP_STRING+="    This will run all suitable tests from xfstests and save output to the log file.\n"
    TEST_HELP_STRING+="    If given directory name will run tests from tests/dir/*\n"
    TEST_HELP_STRING+="3. coverage_gather\n"
    TEST_HELP_STRING+="    This will pack all the coverage and log file into archive named\n"
    TEST_HELP_STRING+="    ~/Coverage/share/curr_date/curr_time/ext4.tar.gz\n"

    BUILD_HELP_STRING=""
    BUILD_HELP_STRING+="On your BM execute:\n"
    BUILD_HELP_STRING+="1. Unpack archive with coverage from shared folder.\n"
    BUILD_HELP_STRING+="2. coverage_apply\n"
    BUILD_HELP_STRING+="    This will copy all coverage data from latest coverage dir to kernel.\n"
    BUILD_HELP_STRING+="    If given path, takes coverage data from there.\n"
    BUILD_HELP_STRING+="3. coverage_report\n"
    BUILD_HELP_STRING+="    This will generate report of coverage located in kernel to latest coverage dir.\n"
    BUILD_HELP_STRING+="    If given path, puts report there.\n"

    NUM_OPTIONS=0
    while getopts "tbh" opt; do
        NUM_OPTIONS=$(($NUM_OPTIONS+1))
        HELP_STRING=""

        case "$opt" in
            t)
                HELP_STRING+="Guide for gathering coverage (on test machine).\n"
                HELP_STRING+="\n"
                HELP_STRING+="$TEST_HELP_STRING"
                ;;

            b)
                HELP_STRING+="Guide for applying coverage (on build machine).\n"
                HELP_STRING+="\n"
                HELP_STRING+="$BUILD_HELP_STRING"
                ;;

            \?|h)
                HELP_STRING+="Usage: coverage_help [OPTIONS]\n"
                HELP_STRING+="\n"
                HELP_STRING+="If no options given, displays help for both build and test machines\n"
                HELP_STRING+="\n"
                HELP_STRING+="Available options are:\n"
                HELP_STRING+="    -b    Display help for gathering coverage (on build machine)\n"
                HELP_STRING+="    -t    Display help for applying coverage (on test machine)\n"
                HELP_STRING+="    -h    Display this help and exit\n"
                ;;
        esac

      echo -ne "$HELP_STRING"
    done

    if [[ $NUM_OPTIONS -eq 0 ]]
    then
        HELP_STRING=""
        HELP_STRING+="Guide for for full coverage cycle (on both TM and BM).\n"
        HELP_STRING+="\n"
        HELP_STRING+="$TEST_HELP_STRING"
        HELP_STRING+="\n"
        HELP_STRING+="$BUILD_HELP_STRING"
        echo -ne "$HELP_STRING"
    fi

    shift $((OPTIND-1))
}