#!/bin/bash
errcho() { echo "$@" 1>&2; }
die() { errcho "$@"; exit 1; }

function join_by {
	local d=${1-} f=${2-}
	if shift 2; then
		printf %s "$f" "${@/#/$d}"
	fi
}

BACKUP_ENV_FILE=/etc/restic-backup/backup-env.sh
source $BACKUP_ENV_FILE || die "$BACKUP_ENV_FILE missing"

errcho "###### Starting Backup on $(date) ######"

# Validations
[ -n "$RESTIC_REPOSITORY" ] || die "Variable RESTIC_REPOSITORY is not set"
[ -e "$RESTIC_PASSWORD_FILE" ] || die "Variable RESTIC_PASSWORD_FILE is not set or file does not exist"
[ -n "$TMP_WORKING_DIR" ] || die "Variable TMP_WORKING_DIR is not set or file does not exist"

# Create temp dir and create tmpfs so meta data about the backup can be added later
mkdir $TMP_WORKING_DIR 2>/dev/null || test -e $TMP_WORKING_DIR || die "Could not create $TMP_WORKING_DIR"
mount -t tmpfs -o size=100M none $TMP_WORKING_DIR

errcho "Downloading file lists"
for source_path in "${PATH_DOWNLOADS[@]}"; do
    scp "$source_path" "$TMP_WORKING_DIR" || die "A file could not be downloaded"
done
errcho
errcho "Dumping software list"
if [[ -e "`which pacman`" ]]; then
    pacman -Qn > $TMP_WORKING_DIR/software.list \
        && pacman -Qm > $TMP_WORKING_DIR/software-aur.list
elif [[ -e "`which apt`" ]]; then
    apt list --installed | cut -d '/' -f 1 > $TMP_WORKING_DIR/software.list || die "Could not dump package list"
else
    die "Unknown package manager/distribution"
fi

if [[ -e "`which cryptsetup`" ]]; then
    errcho "Backing up Luks Header"
    for dev in /dev/nvme*; do
        devname=`basename $dev`
        backupfile="$TMP_WORKING_DIR/luksHeader-$devname.dump"
        echo -n "$dev: " >&2
        if `cryptsetup isLuks $dev`; then
            errcho LUKS
            cryptsetup luksDump $dev >$TMP_WORKING_DIR/luks-$devname.txt
            rm $backupfile 2>/dev/null; cryptsetup luksHeaderBackup $dev --header-backup-file $backupfile
        else
            errcho Plain
        fi
    done
else
    errcho "Cryptsetup seems not to be installed."
    errcho "Assuming this system does not have any encrypted block devices."
fi

files_from_args="`join_by " --files-from " ${PATH_LIST[@]}`"
exclude_files_arg="`join_by " --exclude-file " ${EXCLUDE_FILES[@]}`"

export RESTIC_REPOSITORY
export RESTIC_PASSWORD_FILE

errcho "Backing up fs"
restic backup --verbose --exclude-file $exclude_files_arg --files-from $files_from_args "$TMP_WORKING_DIR"
errcho "###### Finished Backup on $(date) ######"

umount $TMP_WORKING_DIR && rmdir "$TMP_WORKING_DIR"
