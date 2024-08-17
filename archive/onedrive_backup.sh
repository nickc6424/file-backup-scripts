#! /usr/bin/bash
echo "Running OneDrive backup script..."

# Set variables
today=$(date +'%Y%m%d')
source="onedrive_nc:/"
destination="/home/nick/backups/onedrive/onedrive_backup_$today"
destination_temp=$destination
counter=1

# Increment filename until it doesn't already exist
while [ -f $destination_temp".zip" ]
do
    counter=$((counter+1))
    destination_temp="${destination}_${counter}"
done

destination=$destination_temp
echo "Backup destination is: "$destination

# Copy OneDrive files to destination
echo "Copying files..."
rclone copy --progress $source $destination

# Zip OneDrive documents
echo "Zipping files..."
zip -r $destination".zip" $destination

# Delete destination folder
echo "Tidying up..."
rm -rf $destination

echo "OneDrive backup successful."
