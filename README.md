# file_backup_scripts
This repository simplifies the backing up of my local filesystem, and syncs it to the Cloud.

The following software is used:
1. BorgBackup - [Docs](https://borgbackup.readthedocs.io/en/stable/index.html)
2. just - [GitHub](https://github.com/casey/just) | [Docs](https://just.systems/man/en/)
3. rClone - [Docs](https://rclone.org/) 

Ensure all of the above are installed and up to date.

## Basics
In short, Borg has _repositories_ and _archives_. A repository contains zero or many archives.

An archive can be thought of as a snapshot of your file system. They are however deduplicated, to save on storage and improve performance.


## Setup
After cloning the repository with `git clone`, look in the `justfile` and ensure all the variables at the top are set appropriately.

First, create two local borg repositories. One will serve as a "local" repository, to be copied to network storage - the other will be synced to the Cloud.
1. Create a local borg repository with `just init`. You'll be prompted to choose a password.
2. Temporarily change the recipe in the `justfile` - change `repo_path` to `repo_path_cloud`. Run `just init` again. Enter the same password as before.

Store this password in a config file like so:
1. Duplicate `local_backup_example.config`
2. Change the name of file to `local_backup.config`
3. Enter your password in the config file

Next, configure rClone to allow for Cloud syncing. See their [docs](https://rclone.org/docs/) for guidance.

Ensure the `cloud_sync_path` variable in the `justfile` refers to the name of your rClone configuration. 

## Running a backup
| Command                   | Description                 |
|---------------------------|-----------------------------|
| `just backup`             | Run local and cloud backups |
| `just backup true false`  | Run local backup only       |
| `just backup false, true` | Run cloud backup only       |

## View your repositories and archives
Your local and cloud repositories, and their respective archives, can be viewed with `just list`.

## Mount and view a specific archive
`just mount` will mount the latest archive from your local borg repository.

Optionally, you can specify another repo path, and a different archive. For example, if you want the 3rd most recent archive from another path:
```commandline
just mount 3 /new/path/
```

You should unmount when finished using `just unmount`.

## Restore from the Cloud
`just restore` will use rClone to copy your Cloud repository to the local path specified in the `justfile`.

It will then try to mount the latest archive. This can be temperamental, so you may need to run a `just mount` command manually afterwards, specifying the repo path.


# Future development
1. find Joplin's files and include them 
2. consider automating Bitwarden extract and backup? 
3. add support for a different password for the Cloud repository
4. allow mounting a specific archive by name