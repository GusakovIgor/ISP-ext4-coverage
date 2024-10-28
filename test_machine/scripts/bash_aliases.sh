# !!!!!
# Those functions are added to ~/.bash_aliases file on TEST machine.
# !!!!!


# Common
alias cls=clear


# Coverage
COVERAGE_DIR="$(realpath ~/Coverage)"
LOG_DIR="$COVERAGE_DIR/logs"
CONFIG_MAPPINGS_DIR="$(realpath $COVERAGE_DIR/config-mappings)"

# SYNOPSIS
# 	execute_in_directory DIR COMMAND [ARG]...
#
# Description
# 	Executes COMMAND with ARGs in DIR.
function execute_in_directory() {
	WORKING_DIR="$PWD"
	TARGET_DIR="$1"

	COMMAND="${@:2}"
	if [ -z "$COMMAND" ]
	then
		echo "[ERROR] No command provided!"
		return -1
	fi

	if [ -d $TARGET_DIR ]
	then
		cd $TARGET_DIR
		echo "[INFO] Running \"$COMMAND\" in $TARGET_DIR"
		$COMMAND
		cd $WORKING_DIR
		return 0
	else
		echo "[ERROR] Couldn't find directory \"$TARGET_DIR\""
		return -1
	fi
}



function coverage_test_section_internal() {
	TestDir=""
	TestFile=""

    while true
	do
		option=$(getopt --longoptions "test-dir:,test-file:" --options "" -- "$@")
		eval set -- ${option}
        case "$1" in
            --test-dir)
				TestDir="$2"
				echo "[INFO] Test dir is $2"
				shift 2
                ;;

            --test-file)
				TestFile="$2"
				echo "[INFO] Test file is $2"
                shift 2
				;;

			--)
				shift 1
				break
				;;

			*)
				break
				;;
        esac
	done

	Section="$1"
	if [ -z $Section ]
	then
		return -1
	fi

	LogDir="$LOG_DIR/$Section"
	LogFile="$LogDir/output.log"
	TimeFile="$LogDir/time"

	mkdir -p $LogDir

	sudo ./check -s $Section $(cat $CONFIG_MAPPINGS_DIR/$Section) | tee $LogFile

	TimeList="$(cat $LogFile | grep -E ".*[0-9]+s" | sed -E "s/[a-z0-9]+\/[0-9]+ +([0-9]+)s.*/\1/")"
	TimeSeconds="$(printf "%d" $(echo $TimeList | sed "y/ /+/" | bc))"
	TimeHumanReadable="$(date --date=@$TimeSeconds -u +%H:%M:%S)"

	echo $TimeHumanReadable > $TimeFile
}

# SYNOPSIS
# 	coverage_test [OPTION]... SECTION
#
# Description
# 	Run xfstests for SECTION in local.config via "check" script.
#   If any OPTION given, run tests specified by it.
#	Otherwise, try to find file with tests for SECTION in CONFIG_MAPPINGS.
#   Write output to LOG_FILE.
#
#	--test-dir
#		Directory with tests for this section.
#	--test-file
#		File with test names for this section.
function coverage_test_section() {
	execute_in_directory $COVERAGE_DIR/xfstests-dev coverage_test_section_internal $@
	return $?
}

function coverage_test() {
	for section in $(ls $CONFIG_MAPPINGS_DIR)
	do
		coverage_test_section $@ "$section"
	done
}

# SYNOPSIS
# 	coverage_reset
#
# Description
# 	Reset currently collected coverage.
function coverage_reset() {
    echo "[INFO] Reset coverage in /sys/kernel/debug/gcov" | sudo tee /sys/kernel/debug/gcov/reset
	return $?
}



function coverage_gather_internal() {
    DEST_DIR="./share/$(date '+%Y_%m_%d')/$(date '+%H_%M')"

    sudo mkdir -p "$DEST_DIR" &&
	echo "[INFO] Created $DEST_DIR" &&
    sudo ./scripts/gather_on_test.sh "$DEST_DIR/ext4.tar.gz" &&
    sudo cp -r $LOG_DIR "$DEST_DIR/logs" &&
	echo "[INFO] Copied test artifacts to $DEST_DIR"

	return $?
}

# SYNOPSIS
# 	coverage_gather
#
# Description
# 	Pack current coverage, put archive and LOG_FILE
#   into shared folder COVERAGE_DIR/share/<date>/<time>.
function coverage_gather() {
	execute_in_directory $COVERAGE_DIR coverage_gather_internal
	return $?
}



# SYNOPSIS
# 	coverage_help [OPTION]...
#
# Description
# 	Print help on coverage gathering process.
#
#	-t
#		Print help for applying coverage (on test machine).
#	-b
#		Print help for gathering coverage (on build machine).
#	-h
#		Print help for this function.
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
    while getopt "tbh" opt; do
        NUM_OPTIONS=$(($NUM_OPTIONS+1))
        HELP_STRING=""

        case "$opt" in
            -t)
                HELP_STRING+="Guide for gathering coverage (on test machine).\n"
                HELP_STRING+="\n"
                HELP_STRING+="$TEST_HELP_STRING"
                ;;

            -b)
                HELP_STRING+="Guide for applying coverage (on build machine).\n"
                HELP_STRING+="\n"
                HELP_STRING+="$BUILD_HELP_STRING"
                ;;

            \?|-h)
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
