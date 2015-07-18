.SILENT:
.PHONY: help

DATE=`date +"%m-%d-%Y_%T"`
DB_FORUM_BACKUP_FILE=`ls -lrt backups | grep bepro_forum.sql | tail -n 1 | awk '{ print $$9 }'`
DB_TEAMSPEAK_BACKUP_FILE=`ls -lrt backups | grep bepro_teamspeak.sql | tail -n 1 | awk '{ print $$9 }'`
FILES_BACKUP_FILE=`ls -lrt backups | grep _files.tar.gz | tail -n 1 | awk '{ print $$9 }'`
AVATARS_BACKUP_FILE=`ls -lrt backups | grep _avatars.tar.gz | tail -n 1 | awk '{ print $$9 }'`
BACKUP_HOST = bepro.fr
BACKUP_APP_ROOT = /srv/phpBB3
RESTORE_HOST = bepro.fr
RESTORE_APP_ROOT = /srv/phpBB3

## Colors
COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m

## Help
help:
	printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	printf " make [target]\n\n"
	printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	awk '/^[a-zA-Z\-\_0-9\.]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${COLOR_INFO}%-16s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Setup production server and install applications.
setup:
	ansible-galaxy install -r ansible/roles.yml -p ansible/roles -f
	ansible-playbook -i ansible/hosts ansible/playbook_setup.yml -l env_prod
	ansible-playbook -i ansible/hosts ansible/playbook.yml -l env_prod --ask-vault

## Create virtualbox machine and install applications.
setup-dev:
	ansible-galaxy install -r ansible/roles.yml -p ansible/roles -f
	vagrant up

## Backup databases and assets from BACKUP_HOST
backup: backup-db backup-files backup-avatars
	echo backup done

backup-db: backup-db-forum backup-db-teamspeak

backup-db-forum:
	ssh -C root@$(BACKUP_HOST) mysqldump -u root --single-transaction bepro_forum > backups/$(DATE)_bepro_forum.sql
	echo dump backups/$(DATE)_bepro_forum.sql created.

backup-db-teamspeak:
	ssh -C root@$(BACKUP_HOST) mysqldump -u root --single-transaction bepro_teamspeak > backups/$(DATE)_bepro_teamspeak.sql
	echo dump backups/$(DATE)_bepro_teamspeak.sql created.

backup-files:
	ssh -C root@$(BACKUP_HOST) 'cd $(BACKUP_APP_ROOT)/files && tar -pczf - *' > backups/$(DATE)_files.tar.gz
	echo dump backups/$(DATE)_files.tar.gz created.

backup-avatars:
	ssh -C root@$(BACKUP_HOST) 'cd $(BACKUP_APP_ROOT)/images/avatars/upload && tar -pczf - *' > backups/$(DATE)_avatars.tar.gz
	echo dump backups/$(DATE)_avatars.tar.gz created.

## Restore databases and assets to RESTORE_HOST
restore: restore-db restore-files restore-avatars
	echo "restore done"

restore-db: restore-db-forum restore-db-teamspeak

restore-db-forum:
	ssh -C root@$(RESTORE_HOST) mysql -u root bepro_forum < backups/$(DB_FORUM_BACKUP_FILE)
	echo dump backups/$(DB_FORUM_BACKUP_FILE) restored.

restore-db-teamspeak:
	ssh -C root@$(RESTORE_HOST) mysql -u root bepro_teamspeak < backups/$(DB_TEAMSPEAK_BACKUP_FILE)
	echo dump backups/$(DB_TEAMSPEAK_BACKUP_FILE) restored.

restore-files:
	ssh -C root@$(RESTORE_HOST) 'cd $(RESTORE_APP_ROOT)/files && tar -xvzf -' < backups/$(FILES_BACKUP_FILE)
	echo dump backups/$(FILES_BACKUP_FILE) restored.

restore-avatars:
	ssh -C root@$(RESTORE_HOST) 'cd $(RESTORE_APP_ROOT)/images/avatars/upload && tar -xvzf -' < backups/$(AVATARS_BACKUP_FILE)
	echo dump backups/$(AVATARS_BACKUP_FILE) restored.
