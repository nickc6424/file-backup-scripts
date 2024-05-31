# Install Just to use this. Then run commands as you would a Makefile, but with the keyword "just".
# Install on Fedora: sudo dnf install just
# GitHub: https://github.com/casey/just
# Docs: https://just.systems/man/en/

# Set default variables
repo_path := "~/backups/fedora/borg_backups_repo"
repo_path_cloud := "~/backups/fedora/borg_backups_repo_cloud"
mount_path := "~/Downloads/mounted_borg_archive"
cloud_sync_path := "onedrive_nc:/Backups/Fedora/borg_backups_repo_cloud/"
files_to_backup := "/home/nick/Documents/documents_backed_up/ /home/nick/Music/ /home/nick/Pictures/"
# TODO: find Joplin's files and include them
# TODO: consider automating Bitwarden extract and backup?

init:
	# Initialise a new borg repository
	borg init --encryption=repokey {{ repo_path }}
	# For the password chosen, put it in local_backup.config in the format:
	# password="<password>"


# TODO combine list commands with a parameter for local/cloud
list:
	# Lists all archives in the local repository
	local_backups_password="$(grep -oP '(?<=password=").*(?=")' local_backup.config)" \
	BORG_PASSPHRASE=${local_backups_password} borg list {{ repo_path }}


list-cloud:
	# Lists all archives in the cloud repository
	local_backups_password="$(grep -oP '(?<=password=").*(?=")' local_backup.config)" \
	BORG_PASSPHRASE=${local_backups_password} borg list {{ repo_path_cloud }}


# TODO: test this
backup sync_to_cloud="false":
	# Run a local backup, and a cloud backup if specified
	just backup-local
	{{ if sync_to_cloud == "true" { "just backup-cloud" } else { "" } }}


backup-local:
	# Create a new archive in the local repository
	local_backups_password="$(grep -oP '(?<=password=").*(?=")' local_backup.config)" \
	archive_name="fedora_backup_$(date +'%Y%m%d_%H%M%S')"; \
	BORG_PASSPHRASE=${local_backups_password} borg create {{ repo_path }}::${archive_name} {{ files_to_backup }}


backup-cloud: && sync
	# Create a new archive in the cloud repository, and sync it
	local_backups_password="$(grep -oP '(?<=password=").*(?=")' local_backup.config)" \
	archive_name="fedora_backup_$(date +'%Y%m%d_%H%M%S')"; \
	BORG_PASSPHRASE=${local_backups_password} borg create {{ repo_path_cloud }}::${archive_name} {{ files_to_backup }}

# TODO - is rclone doing a full copy each time? Find a way to only sync changes instead?
sync:
	# Copy the cloud repo to the cloud destination
	rclone copy --progress {{ repo_path_cloud }} {{ cloud_sync_path }}


mount mount_int="1":
	# Unmount the mounted archive if there is one
	test -d {{ mount_path }} && just unmount || echo ""
	# Mount an archive, defaulting to the most recent. Mount the nth most recent with 'just mount n'
	mkdir {{ mount_path }} -p
	local_backups_password="$(grep -oP '(?<=password=").*(?=")' local_backup.config)" \
	archive_name=$(BORG_PASSPHRASE=${local_backups_password} borg list {{ repo_path }} | tail -{{ mount_int }} | head -1 | cut -f1 -d " "); \
	BORG_PASSPHRASE=${local_backups_password} borg mount {{ repo_path }}::${archive_name} {{ mount_path }}


unmount:
	# Unmount the mounted archive
	test -d {{ mount_path }} && borg umount {{ mount_path }} && rmdir {{ mount_path }} || echo ""
