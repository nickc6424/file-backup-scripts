# Install Just to use this. Then run commands as you would a Makefile, but with the keyword "just".
# Install on Fedora: sudo dnf install just
# GitHub: https://github.com/casey/just
# Docs: https://just.systems/man/en/

# Set default variables
repo_path := "~/backups/fedora/borg_backups_repo"
repo_path_cloud := "~/backups/fedora/borg_backups_repo_cloud"
mount_path := "~/Downloads/mounted_borg_archive"
cloud_sync_path := "onedrive_nc:/Backups/fedora/borg_backups_repo_cloud/"
cloud_restore_path := "/home/nick/Downloads/borg_backups_repo_cloud/"
files_to_backup := "/home/nick/Documents/documents_backed_up/ /home/nick/Music/ /home/nick/Pictures/ /home/nick/.config/joplin-desktop/"


# Initialise a new borg repository
@init:
	borg init --encryption=repokey {{ repo_path }}
	# For the password chosen, put it in local_backup.config in the format:
	# password="<password>"


# Lists all archives in both local and cloud repositories
@list:
	echo "----------------------------"
	echo "Local borg repository:"
	echo "----------------------------"
	local_backups_password="$(grep -oP '(?<=password=").*(?=")' local_backup.config)" \
	BORG_PASSPHRASE=${local_backups_password} borg list {{ repo_path }}
	echo ""
	echo "----------------------------"
	echo "Cloud borg repository:"
	echo "----------------------------"
	local_backups_password="$(grep -oP '(?<=password=").*(?=")' local_backup.config)" \
	BORG_PASSPHRASE=${local_backups_password} borg list {{ repo_path_cloud }}


# Run a backup, specifying local, cloud or both
@backup local="true" cloud="true": unmount
	{{ if local == "true" { "just backup-local" } else { "" } }}
	{{ if cloud == "true" { "just backup-cloud" } else { "" } }}
	@# Backup process completed.


# Create a new archive in the local repository
@backup-local:
	local_backups_password="$(grep -oP '(?<=password=").*(?=")' local_backup.config)" \
	archive_name="fedora_backup_$(date +'%Y%m%d_%H%M%S')"; \
	BORG_PASSPHRASE=${local_backups_password} borg create {{ repo_path }}::${archive_name} {{ files_to_backup }}
	@# Local backup successful.


# Create a new archive in the cloud repository, and sync it to the cloud
@backup-cloud: && sync
	local_backups_password="$(grep -oP '(?<=password=").*(?=")' local_backup.config)" \
	archive_name="fedora_backup_$(date +'%Y%m%d_%H%M%S')"; \
	BORG_PASSPHRASE=${local_backups_password} borg create {{ repo_path_cloud }}::${archive_name} {{ files_to_backup }}
	@# Cloud backup successful.


# Sync the cloud repo to the cloud destination
@sync:
	rclone sync --progress {{ repo_path_cloud }} {{ cloud_sync_path }}
	@# Archive synced to the cloud successfully.


# Copy the cloud repo from the cloud destination to local.
@restore:
	rclone copy --progress {{ cloud_sync_path }} {{ cloud_restore_path }}
	"just mount 1 {{ cloud_restore_path }}"
	@# Archive restored successfully.


# Mount an archive
@mount mount_int="1" repo_path=repo_path: unmount
	# Params:
	#	mount_int: choose which archive to mount. 1 is the latest archive, 2 is the second-latest archive, etc.
	#	repo_path: the path of the borg repository to mount.
	mkdir {{ mount_path }} -p
	local_backups_password="$(grep -oP '(?<=password=").*(?=")' local_backup.config)" \
	archive_name=$(BORG_PASSPHRASE=${local_backups_password} borg list {{ repo_path }} | tail -{{ mount_int }} | head -1 | cut -f1 -d " "); \
	BORG_PASSPHRASE=${local_backups_password} borg mount {{ repo_path }}::${archive_name} {{ mount_path }}
	@# Archive mounted successfully.


# Unmount the mounted archive
@unmount:
	test -d {{ mount_path }} && borg umount {{ mount_path }} && rmdir {{ mount_path }} || echo ""
	@# Archive unmounted successfully.
