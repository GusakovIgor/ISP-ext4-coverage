# !!!!!
# Those functions are added to ~/.bash_aliases file on TEST machine.
# !!!!!

function atstartup() {
        sudo mount -t vboxsf linux-6.8.5 ~/linux-6.8.5 && echo "Linux kernel src mounted"
        sudo mount -t vboxsf coverage ~/ext4-coverage/share && echo "Coverage share mounted"
        sudo mount -t debugfs none /sys/kernel/debug && echo "Debugfs mounted"
}

function coverage_reset() {
        echo "Coverage reset" | sudo tee /sys/kernel/debug/gcov/reset
}

function coverage_gather () {
        WORKING_DIR="$PWD"
        COVERAGE_DIR="~/ext4-coverage"
        DEST_DIR="share/$(date '+%Y_%m_%d')/$(date '+%H_%M')"

        cd $COVERAGE_DIR
        sudo mkdir -p "$DEST_DIR" &&
        sudo ./scripts/gather_on_test.sh "$DEST_DIR/ext4.tar.gz" &&
        sudo cp "$DEST_DIR/../../latest.log" "$DEST_DIR/tests.log"
        cd $WORKING_DIR
}