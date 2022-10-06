#! /usr/bin/bash

##### Useful docs: #####
# Tar documentation: https://www.gnu.org/software/tar/manual/html_node/tar_toc.html#SEC_Contents
# 7za https://linux.die.net/man/1/7za
#
########################

##### Main script #####
echo "Running local Ubuntu backup script..."

# Set variables
today=$(date +'%Y%m%d_%H%M%S')

files_to_backup="/home/nick/Documents/documents_backed_up/ /home/nick/Music/ /home/nick/Pictures/"

local_output_directory="/home/nick/backups/ubuntu/"
tar_file_name="ubuntu_backup_$today.tar"
zip_file_name="$tar_file_name.7z"
backup_destination="onedrive_nc:/Backups/Ubuntu"
zip_password="123test321"

# Archive specified files and then encrypt
echo "Created encrypted backup file..."
tar -c --to-stdout $files_to_backup | 7za a -si -mhe=on -p$zip_password $local_output_directory$zip_file_name


# Copy zip file to backup destination
# echo "Copying encrypted backup file to Onedrive..."
# rclone copy --progress $local_output_directory$zip_file_name $backup_destination

echo "Local backup successful."

# Unzip it again to check it's fine
# 7z x -so -p$zip_password $local_output_directory$zip_file_name | tar xf - -C $local_output_directory

########################