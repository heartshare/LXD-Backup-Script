#!/bin/bash

# Read command output line by line into array ${lines [@]}
# Bash 3.x: use the following instead:
#   IFS=$'\n' read -d '' -ra lines < <(lsblk --nodeps -no name,serial,size | grep "sd")

clear

echo "Cleanup Script"
echo "--------------"
sleep 3s

export BORG_PASSCOMMAND="cat /etc/borg.d/.borg-passphrase"



while [[ $yn != y ]]
	do
		PS3="Please select what you want to remove: "
		select WHAT in Archive Repository EveryRepo Everything
			do
				# case statement to compare the first menu items
				case $WHAT in
					[Archive]*) echo "You selected Archive";sleep 2s;break;;
					[Repository]*) echo "You selected Repository";sleep 2s;break;;
					[EveryRepo]*) echo "You selected EveryRepo";sleep 2s;break;;
					[Everything]*) echo "You selected Everything";sleep 2s;break;;
								*) echo "Invalid Option";;
				esac
		done
		while true
			do
				echo "You selected $WHAT."
				read -p "Are you sure? (y/n)" yn
					case $yn in
						[Yy]* ) break;;
						[Nn]* ) echo "Please choose again.";sleep 2s;break;;
							* ) echo "Please answer yes or no.";;
					esac
			done
done


# Parent menu items declared here


if [[ $WHAT = Repository ]]
	then 
		readarray -t REPOS < <(ls ${MNT})
		# Prompt the user to select one of the lines.
		while [[ $yn != y ]]
			do
				echo "Please select a repository to delete:"
				select REMOVE in "${REPOS[@]}"
					do
						[[ -n $REMOVE ]] || { echo "Invalid choice. Please try again." >&2; continue; }
						break # valid choice was made; exit prompt.
				done
				while true 
					do
						read -p "You are going to remove the repository $REMOVE. This can not be undone. Are you sure?(y/n)" yn
						case $yn in
							[Yy]* ) break;;
							[Nn]* ) break;;
								* ) echo "Please answer yes or no.";;
						esac
				done
			done
				borg delete ${MNT}/$REMOVE
				echo "The repository was removed successfully."
				sleep 5s
				exit 0
				
elif [[ $WHAT = Archive ]]
	then
		readarray -t REPOS < <(ls ${MNT})
		# Prompt the user to select one of the lines.
	    while [[ $yn != y ]]
			do
				echo "Please select the repository of the archive you wish to delete:"
				select REMOVE in "${REPOS[@]}"
					do
						[[ -n $REMOVE ]] || { echo "Invalid choice. Please try again." >&2; continue; }
						break # valid choice was made; exit prompt.
				done
				read -p "You selected the repository $REMOVE. Are you sure?(y/n)" yn
						case $yn in
							[Yy]* ) break;;
							[Nn]* ) break;;
								* ) echo "Please answer yes or no.";;
						esac
		done
						
		readarray -t ARCHIVES < <(borg list ${MNT}/$REMOVE)
		 while [[ $yn != y ]]
			do
				echo "Please select the archive you wish to delete:"
				select ARCHIVE in "${ARCHIVES[@]}"
					do
						[[ -n $ARCHIVE ]] || { echo "Invalid choice. Please try again." >&2; continue; }
						break # valid choice was made; exit prompt.
				done
				read -p "You selected the archive $ARCHIVE. Are you sure?(y/n)" yn
						case $yn in
							[Yy]* ) break;;
							[Nn]* ) break;;
								* ) echo "Please answer yes or no.";;
						esac
			done
				borg delete ${MNT}/$REMOVE::$ARCHIVE
				echo "The archive was removed successfully."
				sleep 5s
				exit 0
				
elif [[ $WHAT = EveryRepo ]] 
	then
		echo "-----------------------------------------------------------"
		echo "WARNING: This will remove all your backups and repositories"
		echo "-----------------------------------------------------------"
		printf "\n"
		printf "\n"
		while [[ $yn != y ]]
			do
				read -p "Do you wish to continue? (y/n)" yn
				case $yn in
					[Yy]* ) break;;
					[Nn]* ) echo "Terminating Script.";sleep 2s;exit 1;;
						* ) echo "Please answer yes or no.";;
				esac
			done
		
		cd ${MNT}
		for i in *
			do
				borg delete ${MNT}/$i
		done
		echo "All Repositories have been removed."
		sleep 5s
		exit 0

elif [[ $WHAT = Everything ]]
	then
		echo "------------------------------------------------------------------------------------------"
		echo "WARNING: This will remove all backups, repositories and everything related to this script."
		echo "------------------------------------------------------------------------------------------"
		printf "\n"
		printf "\n"
		while [[ $yn != y ]]
			do
				read -p "Do you wish to continue? (y/n)" yn
				case $yn in
					[Yy]* ) break;;
					[Nn]* ) echo "Terminating Script.";sleep 2s;exit 1;;
						* ) echo "Please answer yes or no.";;
				esac
			done
		cd ${MNT}
		for i in *
			do
				borg delete ${MNT}/$i
		done
		echo "All Repositories have been removed."
		sleep 3s
		rm ~/.muttrc
		rm /var/log/backup*
		rm /systemd/system/backup*
		rm -rf /etc/borg.d
		echo "Everything was removed successfully."
fi
