#!/bin/bash
# Premise:
# There's a host configured in root's ssh_config that knows how
# to connect without interaction to the backup server
# When working with variables and special characters make sure to properly escape them if needed

# Name of the host (used for ssh connections so it's defined in ssh_config)
BACKUP_HOST=backupserver

# Directory for temporary files needed to create the backup (will be included 
# in the backup for additional information and some dumped data)
TMP_WORKING_DIR=/backupmeta

# Path of the repository on the remote host
REPO_PATH=\~/`hostname`

# Path to the restic repository
# Use sftp and
RESTIC_REPOSITORY="sftp:$BACKUP_HOST:$REPO_PATH"

# File that contains the password to the restic repository
# Make sure it's only readable by root! e.g. chmod 400
RESTIC_PASSWORD_FILE=/etc/restic-backup/restic.key

# List of files with exclude lists. These are joint together
# and passed to restic to ignore paths and patterns
EXCLUDE_FILES=(
	"$TMP_WORKING_DIR/excludes.global.lst"
	"$TMP_WORKING_DIR/excludes.desktop.lst"
)

# List of files with paths to backup. These are joint together
# and passed to restic to backup paths and patterns
PATH_LIST=(
	"$TMP_WORKING_DIR/paths.global.lst"
	"$TMP_WORKING_DIR/paths.desktop.lst"
)

# List of files to be downloaded to the local working directory
PATH_DOWNLOADS=(
        "$BACKUP_HOST:~/paths.global.lst"
        "$BACKUP_HOST:~/paths.desktop.lst"
        "$BACKUP_HOST:~/excludes.global.lst"
        "$BACKUP_HOST:~/excludes.desktop.lst"
)

