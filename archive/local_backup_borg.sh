#! /usr/bin/bash

# Path to config file
. ./local_backup.config

# Set variables
path_to_borg_repo="/home/nick/backups/fedora/borg_repo"
today=$(date +'%Y%m%d_%H%M%S')
archive_name="fedora_backup_$today"
files_to_backup="/home/nick/Documents/documents_backed_up/ /home/nick/Music/ /home/nick/Pictures/"

borg init --encryption=repokey $path_to_borg_repo
BORG_PASSPHRASE=$password borg create $path_to_borg_repo::$archive_name $files_to_backup
