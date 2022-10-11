# rsync-backup-scripts

## Backup creation rules

New backups are stored at `./incomplete` until rsync exits successfully. Then the current backup `./current` is replaced by `./incomplete`.

The `--link-dest` flag of `rsync` always points to `./current`. If the `rsync` command fails (e.g. because of a network failure) the backup will continue on the next run with the files already in `./incomplete`.

If no backup exists at `./%Y-%m-%d_%Hh` (e.g. `./2022-10-11_17h`), this is the first backup of the current hour and a hard linked copy (via `cp -al`) of the `./current` backup is created.

The same logic applies to daily and monthly backups - a copy with name `%Y-%m-%d` or `%Y-%m` is created for the first backup of every day or month respectively.

## Backup retention/deletion rules

The backup retention is defined by the number of most recent hourly and daily backups to keep. This is handled by deleting all but the `n` latest folders matching the naming convention of hourly or daily backups respectively. 
