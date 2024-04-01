# Install Just to use this. Then run commands as you would a Makefile, but with the keyword "just".
# Install on Fedora: sudo dnf install just
# GitHub: https://github.com/casey/just
# Docs: https://just.systems/man/en/

# Set default variables
repo_path := "~/backups/fedora/borg_backups_repo"
mount_path := "~/Downloads/mounted_borg_archive"
mount_int := "1"

# Initialise a new borg repository
init:
	-borg init --encryption=repokey {{ repo_path }}
	# For the password chosen, set it as an environment variable with:
	# export local_backups_password=<password>

# Creates a new archive within the repository
backup:
	archive_name="fedora_backup_$(date +'%Y%m%d_%H%M%S')"; \
	files_to_backup="/home/nick/Documents/documents_backed_up/ /home/nick/Music/ /home/nick/Pictures/"; \
	BORG_PASSPHRASE=${local_backups_password} borg create {{ repo_path }}::${archive_name} ${files_to_backup}

# Lists all archives in the repository
list:
	BORG_PASSPHRASE=${local_backups_password} borg list {{ repo_path }}

# Mount an archive, defaulting to the most recent. Mount the nth most recent with 'just mount_int="n" mount'
mount: unmount
	-mkdir {{ mount_path }} -p
	archive_name=$(BORG_PASSPHRASE=${local_backups_password} borg list {{ repo_path }} | tail -{{ mount_int }} | head -1 | cut -f1 -d " "); \
	BORG_PASSPHRASE=${local_backups_password} borg mount {{ repo_path }}::${archive_name} {{ mount_path }}

# Unmount the mounted archive
unmount:
	-borg umount {{ mount_path }}
	-rmdir {{ mount_path }}
