# Restic Backup Script

This script creates backups of Arch Linux (pacman-based) Hosts using [Restic](https://restic.net/) and transfers the data via ssh. The configuration such as include- and exclude lists is modular and can be shared to make this script usable for multiple devices and different types of devices (desktops, servers, headless).

A list of installed software (from repos and AUR as well) and LUKS headers of all connected disks are dumped as well. 

## Installation

### Backup Host

* Create a user on the server that's used to receive the backups e.g. _backup_
* Make sure the user has write access to the backup location

```bash
BACKUP_BASE=/srv/backup
mkdir -p $BACKUP_BASE/restic/.ssh
useradd -d $BACKUP_BASE/restic backup
chown backup:backup -R $BACKUP_BASE/restic

```

### Backup Client

* Generate ssh-keys for the backups
* Add host profile to ssh_config
* Create a file with the key to the restic repository
* Backup the key somewhere else!
* Write path lists ([files-from](https://restic.readthedocs.io/en/latest/040_backup.html#including-files) and [exclude-files](https://restic.readthedocs.io/en/latest/040_backup.html#excluding-files))
* Configure _backup-env.sh_  (locations, path lists, include and exclude lists)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/resticbackup.key
cat >> ~/.ssh/config << EOF
Host backuphost
    Hostname yourhostname.tld
    User backup
    IdentityFile /root/.ssh/resticbackup.key
EOF
head -c 32 /dev/random | basenc --z85 > /etc/restic-backup/restic.key
```

### Add Backup Client to Backup Host

* Add the client's public key to the backup user's  _authorized_keys_ file
* Initialize the repository

```bash
. /etc/restic-backup/backup-env.sh && ssh $BACKUP_HIST "umask 0077 && export RESTIC_REPOSITORY=\"$REPO_PATH\" && export RESTIC_PASSWORD=\"`cat $RESTIC_PASSWORD_FILE`\" && mkdir -v \"\$RESTIC_REPOSITORY\" && restic init --verbose=2"
```

## Notes

* The security could be enhanced (only allow sftp and restic commands on the server, put the server into a container, ...)
* The described setup would protect the restic repos against unauthorized access but the backup user can still simply delete the backups (use separate accounts if this is an issue)

