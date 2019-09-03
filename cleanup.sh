#!/bin/bash

clear

echo "Cleanup Script"
echo "--------------"
sleep 3s

export BORG_PASSCOMMAND="cat /etc/borg.d/.borg-passphrase"

RESET='\e[0m'
RED='\e[31m'
GREEN='\e[32m'

while [[ $yn != y ]]
	do
		PS3="Please select what you want to remove: "
		select WHAT in Archive Repository EveryRepo Everything
			do
				# case statement to compare the first menu items
				case $WHAT in
					[Archive]*) sleep 2s;break;;
					[Repository]*) sleep 2s;break;;
					[EveryRepo]*) sleep 2s;break;;
					[Everything]*) sleep 2s;break;;
								*) echo -e "${RED}Invalid Option${RESET}";;
				esac
		done
		while true
			do
				echo "You selected $WHAT."
				read -p "Are you sure? (y/n)" yn
					case $yn in
						[Yy]* ) break;;
						[Nn]* ) echo -e "${RED}Please choose again.${RESET}";sleep 2s;break;;
							* ) echo -e "${RED}Please answer yes or no.${RESET}";;
					esac
			done
done

unset yn
# Parent menu items declared here
if [[ "$WHAT" == Repository ]]
	then 
		readarray -t REPOS < <(ls ${MNT})
		if [ -z "$REPOS" ]
			then
				echo -e "${RED}No repositories found${RESET}"
				sleep 3s
				exit 0
		fi
		# Prompt the user to select one of the lines.
		while [[ $yn != y ]]
			do
				echo "Please select a repository to delete:"
				select REMOVE in "${REPOS[@]}"
					do
						[[ -n $REMOVE ]] || { echo -e "${RED}Invalid choice. Please try again.${RESET}" >&2; continue; }
						break # valid choice was made; exit prompt.
				done
				while true 
					do
						read -p "You are going to remove the repository $REMOVE. This can not be undone. Are you sure?(y/n)" yn
						case $yn in
							[Yy]* ) break;;
							[Nn]* ) break;;
								* ) echo -e "${RED}Please answer yes or no.${RESET}";;
						esac
				done
			done
				borg delete ${MNT}/$REMOVE
				echo -e "${GREEN}The repository was removed successfully.${RESET}"
				sleep 5s
				exit 0
				
elif [[ "$WHAT" == Archive ]]
	then
		readarray -t REPOS < <(ls ${MNT})
		if [ -z "$REPOS" ]
			then
				echo -e "${RED}No repositories found${RESET}"
				sleep 3s
				exit 0
		fi
		# Prompt the user to select one of the lines.
	    while [[ $yn != y ]]
			do
				echo "Please select the repository of the archive you wish to delete:"
				select REMOVE in "${REPOS[@]}"
					do
						[[ -n $REMOVE ]] || { echo -e "${RED}Invalid choice. Please try again.${RESET}" >&2; continue; }
						break # valid choice was made; exit prompt.
				done
				read -p "You selected the repository $REMOVE. Are you sure?(y/n)" yn
						case $yn in
							[Yy]* ) break;;
							[Nn]* ) echo -e "${RED}Please choose again${RESET}";sleep 2s;;
								* ) echo -e "${RED}Please answer yes or no.${RESET}";sleep 2s;;
						esac
		done
		unset yn				
		readarray -t ARCHIVES < <(borg list ${MNT}/$REMOVE)
		if [ -z "$ARCHIVES" ]
			then
				echo -e "${RED}No archives found on the repository $REMOVE${RESET}"
				sleep 3s
				exit 0
		fi
		while [[ $yn != y ]]
			do
				echo "Please select the archive you wish to delete:"
				select ARCHIVE in "${ARCHIVES[@]}"
					do
						[[ -n $ARCHIVE ]] || { echo -e "${RED}Invalid choice. Please try again.${RESET}" >&2; continue; }
						break # valid choice was made; exit prompt.
				done
				read -p "You selected the archive $ARCHIVE. Are you sure?(y/n)" yn
						case $yn in
							[Yy]* ) break;;
							[Nn]* ) echo -e "${RED}Please choose again${RESET}";sleep 2s;;
								* ) echo -e "${RED}Please answer yes or no.${RESET}";sleep 2s;;
						esac
			done
				ARCHIVE=$(echo $ARCHIVE | cut -d' ' -f1)
				borg delete ${MNT}/$REMOVE::$ARCHIVE
				echo -e "${GREEN}The archive was removed successfully.${RESET}"
				sleep 5s
				exit 0
				
elif [[ "$WHAT" == EveryRepo ]] 
	then
		echo -e "${RED}-----------------------------------------------------------${RESET}"
		echo -e "${RED}WARNING: This will remove all your backups and repositories${RESET}"
		echo -e "${RED}-----------------------------------------------------------${RESET}"
		printf "\n"
		printf "\n"
		while [[ $yn != y ]]
			do
				read -p "Do you wish to continue? (y/n)" yn
				case $yn in
					[Yy]* ) break;;
					[Nn]* ) echo -e "${RED}Terminating Script.${RESET}";sleep 2s;exit 1;;
						* ) echo -e "${RED}Please answer yes or no.${RESET}";;
				esac
			done
		
		cd ${MNT}
		for i in *
			do
				borg delete ${MNT}/$i
		done
		echo -e "${GREEN}All Repositories have been removed.${RESET}"
		sleep 5s
		exit 0

elif [[ "$WHAT" == Everything ]]
	then
		echo -e "${RED}------------------------------------------------------------------------------------------${RESET}"
		echo -e "${RED}WARNING: This will remove all backups, repositories and everything related to this script.${RESET}"
		echo -e "${RED}------------------------------------------------------------------------------------------${RESET}"
		printf "\n"
		printf "\n"
		while [[ $yn != y ]]
			do
				read -p "Do you wish to continue? (y/n)" yn
				case $yn in
					[Yy]* ) break;;
					[Nn]* ) echo -e "${RED}Terminating Script.${RESET}";sleep 2s;exit 1;;
						* ) echo -e "${RED}Please answer yes or no.${RESET}";;
				esac
			done
		cd ${MNT}
		for i in *
			do
				borg delete ${MNT}/$i
		done
		echo -e "${GREEN}All Repositories have been removed.${RESET}"
		sleep 3s
		rm ~/.muttrc
		rm -rf /var/log/backup
		rm /etc/systemd/system/backup*
		rm -rf /etc/borg.d
		rm ~/.passwd-s3fs 2>/dev/null >/dev/null
		
		while true 
			do
				read -p "Do you wish to remove packages installed by the script?(y/n)" yn
				case $yn in
					[Yy]* ) echo -e "${RED}Removing installed packages.${RESET}"; break;;
					[Nn]* ) echo -e "${GREEN}Everything was removed successfully.${RESET}";sleep 4s;exit 1;;
						* ) echo -e "${RED}Please answer yes or no.${RESET}";;
			esac          
		done
		
		
		# Removal of installed packages
		
		BORG='borgbackup'     
		echo "Checking to see if '$BORG' is installed on your system."
		printf "\n"
		sleep 2s

		dpkg -s $BORG 2>/dev/null >/dev/null

		if [ $? -ne 0 ]
			# If success
			then
				echo "The '$BORG' package is not installed on your system."
				printf "\n"
				sleep 2s
			else
				echo "The '$BORG' package is installed on your system."
				echo "Removing..."
				set -x                               #Sends output to terminal
				(apt purge $BORG -y) 
				{ set +x; } 2>/dev/null              #Stops output to terminal and hides set+x from output
				printf "\n"
				sleep 2s
				if [ $? -eq 0 ]
					# If success
					then
						echo -e "${GREEN}The '$BORG' package was removed successfully.${RESET}"
						printf "\n"
						sleep 2s
					# If failure
					else
						echo -e "${RED}Couldn't remove '$BORG' package.${RESET}"
						printf "\n"
						echo -e "${RED}Please try removing it manually.${RESET}"
						printf "\n"
						sleep 5s
						exit 1 # Exit with general error
				fi
		fi

		printf "\n"
		
		MUTT='mutt'     
		echo "Checking to see if '$MUTT' is installed on your system."
		printf "\n"
		sleep 2s

		dpkg -s $MUTT 2>/dev/null >/dev/null

		if [ $? -ne 0 ]
			# If success
			then
				echo "The '$MUTT' package is not installed on your system."
				printf "\n"
				sleep 2s
			else
				echo "The '$MUTT' package is installed on your system."
				echo "Removing..."
				set -x                               #Sends output to terminal
				(apt purge $MUTT -y) 
				{ set +x; } 2>/dev/null              #Stops output to terminal and hides set+x from output
				printf "\n"
				sleep 2s
				if [ $? -eq 0 ]
					# If success
					then
						echo -e "${GREEN}The '$MUTT' package was removed successfully.${RESET}"
						printf "\n"
						sleep 2s
					# If failure
					else
						echo -e "${RED}Couldn't remove '$MUTT' package.${RESET}"
						printf "\n"
						echo -e "${RED}Please try removing it manually.${RESET}"
						printf "\n"
						sleep 5s
						exit 1 # Exit with general error
				fi
		fi
		
		S3FS='s3fs'     
		echo "Checking to see if '$S3FS' is installed on your system."
		printf "\n"
		sleep 2s

		dpkg -s $S3FS 2>/dev/null >/dev/null

		if [ $? -ne 0 ]
			# If success
			then
				echo "The '$S3FS' package is not installed on your system."
				printf "\n"
				sleep 2s
			else
				echo "The '$S3FS' package is installed on your system."
				echo "Removing..."
				set -x                               #Sends output to terminal
				(apt purge $S3FS -y) 
				{ set +x; } 2>/dev/null              #Stops output to terminal and hides set+x from output
				printf "\n"
				sleep 2s
				if [ $? -eq 0 ]
					# If success
					then
						echo -e "${GREEN}The '$S3FS' package was removed successfully.${RESET}"
						printf "\n"
						sleep 2s
					# If failure
					else
						echo -e "${RED}Couldn't remove '$S3FS' package.${RESET}"
						printf "\n"
						echo -e "${RED}Please try removing it manually.${RESET}"
						printf "\n"
						sleep 5s
						exit 1 # Exit with general error
				fi
		fi
		
		FUSE='fuse'     
		echo "Checking to see if '$FUSE' is installed on your system."
		printf "\n"
		sleep 2s

		dpkg -s $FUSE 2>/dev/null >/dev/null

		if [ $? -ne 0 ]
			# If success
			then
				echo "The '$FUSE' package is not installed on your system."
				printf "\n"
				sleep 2s
			else
				echo "The '$FUSE' package is installed on your system."
				echo "Removing..."
				set -x                               #Sends output to terminal
				(apt purge $FUSE -y) 
				{ set +x; } 2>/dev/null              #Stops output to terminal and hides set+x from output
				printf "\n"
				sleep 2s
				if [ $? -eq 0 ]
					# If success
					then
						echo -e "${GREEN}The '$FUSE' package was removed successfully.${RESET}"
						printf "\n"
						sleep 2s
					# If failure
					else
						echo -e "${RED}Couldn't remove '$FUSE' package.${RESET}"
						printf "\n"
						echo -e "${RED}Please try removing it manually.${RESET}"
						printf "\n"
						sleep 5s
						exit 1 # Exit with general error
				fi
		fi
		echo -e "${GREEN}Everything was removed successfully.${RESET}"
		sleep 4s
fi
