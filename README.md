# rsync-backup-scripts

## Backup naming/creation rules

New backups are named `%Y-%m-%d_%Hh` e.g. `2022-10-11_17h`. If a backup with this name already exists (i.e. there was a previous backup made in the current hour of the day) it is overwritten.

If no Backup with the name `%Y-%m-%d` exists (i.e. this is the first backup of this day) a hard linked copy (via `cp -al`) of the current backup is created in addition to the hourly backup (i.e. two folders `%Y-%m-%d` and `%Y-%m-%d_%Hh` with the same hard links are created).

The same logic applies to monthly backups - a copy with name `%Y-%m` is created for the first backup of every month.

## Backup retention/deletion rules

The backup retention is defined as the number of most recent hourly and daily backups to keep. This is handled by deleting all but the `n` latest folders matching the naming convention of hourly or daily backups respectively. 

## Error handling

The `--link-dest` flag of `rsync` always points to a symbolic link named `current` which in turn points to the latest completed backup.

If the `rsync` command fails (e.g. because of a network failure) the backup will continue on the next run. This is implemented by backing up to a folder named `incomplete` which only after successful completion will be renamed according to the hourly backup naming convention (i.e. `%Y-%m-%d_%Hh`) and the `current` symbolic link is updated to point to that backup.
