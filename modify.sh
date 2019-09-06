#!/usr/bin/env bash

clear

#Check if running as root
if [ "$EUID" -ne 0 ]
	then
		echo -e "${RED}Please run this script as root${RESET}"
		exit 1     # Exit with General Error
fi

echo "Modify/Migration Script"
echo "-----------------------"

source /etc/borg.d/env
RESET='\e[0m'
RED='\e[31m'
GREEN='\e[32m'
while [[ $yn != y ]]
	do
		# Parent menu items declared here
		PS3="Please choose what you want to change: "
		select FIRST in "Auto Backup Settings" "Notification Settings" "General Settings" "Wasabi Settings" Exit
			do
				# case statement to compare the first menu items
				case $FIRST in
					["Auto Backup Settings"]*) break;;
					["Notification Settings"]*) break;;
					["General Settings"]*) break;;
					["Wasabi Settings"]*) break;;
												[Exit]*) exit 0;;
										*) echo -e "${RED}Invalid Option${RESET}";;
				esac
		done
		while true
			do
				read -r -p "You chose $FIRST. Is this correct?(y/n)" yn
					case $yn in
						[Yy]* ) echo "${GREEN}Proceeding...${RESET}";sleep 3s;break;;
						[Nn]* ) echo -e "${RED}Please choose again.${RESET}";sleep 3s;break;;
							* ) echo -e "${RED}Please answer yes or no.${RESET}";;
					esac
		done
done

if [[ "$FIRST" == "Auto Backup Settings" ]]
	then
		while [[ $yn != y ]]
			do
				# Parent menu items declared here
				PS3="Please choose what you want to change: "
				select SECOND in "Backup Hour" "Backup Location" Compression "Retention Settings" Exit
					do
						# case statement to compare the first menu items
						case $SECOND in
							["Backup Hour"]*) break;;
							["Backup Location"]*) break;;
							["Compression"]*) break;;
							["Retention Settings"]*) break;;
															[Exit]*) exit 0;;
												*) echo -e "${RED}Invalid Option.${RESET}";;
						esac
				done
				while true
					do
						read -r -p "You chose $SECOND. Is this correct?(y/n)" yn
							case $yn in
								[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 3s;break;;
								[Nn]* ) echo -e "${RED}Please choose again.${RESET}";sleep 3s;break;;
									* ) echo "${RED}Please answer yes or no.${RESET}";;
							esac
				done
		done
		if [[ "$SECOND" == "Backup Hour" ]]
			then
				while true
					do
						read -r -p "Please select the new hour for the automatic backup to run (24h format) $(echo $'\n> ')" HOUR
							case $HOUR in
								(0[0-9] ) echo -e "${GREEN}Proceeding...${RESET}";sleep 2s;break;;
								(1[0-9] ) echo "${GREEN}Proceeding...${RESET}";sleep 2s;break;;
								(2[0-3] ) echo "${GREEN}Proceeding...${RESET}";sleep 2s;break;;
										* ) echo -e "${RED}Please input valid hour.${RESET}";sleep 2s;;
							esac
				done
				systemctl disable backup.timer
				rm /etc/systemd/system/backup.timer
				set -x                               #Sends output to terminal
				(wget -P "$TEMP" https://raw.githubusercontent.com/The-Inamati/LXD-Backup-Script/master/backup.timer)
				{ set +x; } 2>/dev/null              #Stops output to terminal and hides set+x from output
				mv "$TEMP"/backup.timer /etc/systemd/system/
				sed -i -e 's|${HOUR}|'"$HOUR"'|' /etc/systemd/system/backup.timer
				if [ $? -ne 0 ]
					then
						echo -e "${RED}Something went wrong and the hour was not changed.${RESET}"
						exit 1
					else
						systemctl enable backup.timer
						systemctl start backup.timer
						systemctl daemon-reload
						echo -e "${GREEN}Hour changed successfully.${RESET}"
						exit 0
				fi
		elif [[ "$SECOND" == "Backup Location" ]]
			then
				while true
					do
						echo "WARNING: This will only change the backup location it will not migrate existing repositories."
						read -r -p "Do you wish to proceed?(y/n)" yn
							case $yn in
								[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 3s;break;;
								[Nn]* ) echo -e "${RED}Terminating Script.${RESET}";sleep 3s;exit 1;;
									* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
				done
				unset yn
				while [[ $yn != y ]]
					do
						# Parent menu items declared here
						PS3="Please choose the backup type you are currently using: "
						select BACKUP_TYPE in Wasabi Local
							do
								# case statement to compare the first menu items
								case $BACKUP_TYPE in
									["Wasabi"]*) break;;
									["Local"]*) break;;
											*) echo -e "${RED}Invalid Option.${RESET}";;
								esac
						done
						while true
							do
								read -r -p "You chose $BACKUP_TYPE. Is this correct?(y/n)" yn
									case $yn in
										[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 3s;break;;
										[Nn]* ) echo -e "${RED}Please choose again.${RESET}";sleep 3s;break;;
											* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done
				done
				if [[ "$BACKUP_TYPE" == Wasabi ]]
					then
						echo "Checking for Mounted Buckets"
						sleep 3s
						while true
							do
								read -r -p "The bucket is mounted at $MNT. Do you wish to proceed?(y/n)" yn
									case $yn in
										[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 3s;break;;
										[Nn]* ) echo -e "${RED}Terminating Script.${RESET}";sleep 3s;exit 1;;
											* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done
						#Check to see if Bucket is mounted
						mount -l | grep "${MNT}"
						if [ $? -eq 0 ]
							# If success
							then
								umount "${MNT}"
								sed -i '/${MNT}/d' /etc/fstab
								if [ $? -ne 0 ]
									then
										echo -e "${RED}Error unmounting the bucket. Please try manually.${RESET}"
										exit 1
									else
										echo -e "${GREEN}Bucket unmounted sucessfully.${RESET}"
								fi
						fi
						unset yn
						while [[ $yn != y ]]
							do
								# Parent menu items declared here
								PS3="Please choose what to do with current Wasabi settings: "
								select WASABI in Keep Change
									do
										# case statement to compare the first menu items
										case $WASABI in
											["Keep"]*) break;;
											["Change"]*) break;;
													*) echo -e "${RED}Invalid Option.${RESET}";;
										esac
								done
								while true
									do
										read -r -p "You chose $WASABI. Is this correct?(y/n)" yn
										case $yn in
											[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 3s;break;;
											[Nn]* ) echo -e "${RED}Please choose again.${RESET}";sleep 3s;break;;
												* ) echo -e "${RED}Please answer yes or no.${RESET}";;
										esac
								done
						done
						if [[ "$WASABI" == Change ]]
							then
								while true
									do
										read -r -p "Please enter your Wasabi Access Key: $(echo $'\n> ')" ACCESS_KEY
										read -r -p "You entered '$ACCESS_KEY' is this correct?(y/n)" yn
										case $yn in
											[Yy]* ) break;;
											[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
												* ) echo -e "${RED}Please answer yes or no.${RESET}";;
										esac
								done
								sed -i '/ACCESS_KEY/d' /etc/borg.d/env
								if [ $? -ne 0 ]
									then
										echo -e "${RED}Can't change Wasabi parameters please check if your env file is still at /etc/borg.d/${RESET}"
										exit 1
								fi
								echo ACCESS_KEY=\$"\"$ACCESS_KEY\"" >> /etc/borg.d/env

								#Prompt to define wasabi secret key
								while true
									do
										read -r -p "Please enter your Wasabi Secret Key: $(echo $'\n> ')" SECRET_KEY
										read -r -p "You entered '$SECRET_KEY' is this correct?(y/n)" yn
											case $yn in
												[Yy]* ) break;;
												[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
													* ) echo -e "${RED}Please answer yes or no.${RESET}";;
											esac
								done

								sed -i '/SECRET_KEY/d' /etc/borg.d/env
								if [ $? -ne 0 ]
									then
										echo -e "${RED}Can't change Wasabi parameters please check if your env file is still at /etc/borg.d/${RESET}"
										exit 1
								fi
								echo SECRET_KEY=\$"\"$SECRET_KEY\"" >> /etc/borg.d/env

								#Prompt to define bucket region
								while true
									do
										read -r -p "Please enter the region selected when creating the bucket [eu-central-1]: $(echo $'\n> ')" BUCKET_LOC
										BUCKET_LOC=${BUCKET_LOC:-eu-central-1}                                                          #Used to provide default option
										read -r -p "You selected '$BUCKET_LOC' is this correct?(y/n)" yn
											case $yn in
												[Yy]* ) break;;
												[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
													* ) echo -e "${RED}Please answer yes or no.${RESET}";;
											esac
								done

								sed -i '/BUCKET_LOC/d' /etc/borg.d/env
								if [ $? -ne 0 ]
									then
										echo -e "${RED}Can't change Wasabi parameters please check if your env file is still at /etc/borg.d/${RESET}"
										exit 1
								fi
								echo BUCKET_LOC=\$"\"$BUCKET_LOC\"" >> /etc/borg.d/env

								#Prompt to define bucket name
								while true
									do
										read -r -p "Please enter the name of the bucket you created: $(echo $'\n> ')" BUCKET
										read -r -p "You entered '$BUCKET' is this correct?(y/n)" yn
											case $yn in
												[Yy]* ) break;;
												[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
													* ) echo -e "${RED}Please answer yes or no.${RESET}";;
											esac
								done

								sed -i '/BUCKET/d' /etc/borg.d/env
								if [ $? -ne 0 ]
									then
										echo -e "${RED}Can't change Wasabi parameters please check if your env file is still at /etc/borg.d/${RESET}"
										exit 1
								fi
								echo BUCKET=\$"\"$BUCKET\"" >> /etc/borg.d/env

								#Prompt to define repo location
								while true
									do
										read -r -p "Please enter the new location for the backup repository. Your S3 storage will be mounted to this location. The folder has to be empty. If it does not exist it will be created automatically. [/BACKUP]: $(echo $'\n> ')" MNT
										MNT=${MNT:-/BACKUP}                                                          #Used to provide default option
										read -r -p "You selected '$MNT' is this correct?(y/n)" yn
											case $yn in
												[Yy]* ) break;;
												[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
													* ) echo -e "${RED}Please answer yes or no.${RESET}";;
											esac
								done

								mkdir "$MNT" 2>/dev/null >/dev/null
								chmod 777 "$MNT"

								if [ "${MNT: -1}" == "/" ]  #Checks if there is a forward slash in the path and if there is removes it
									then
										MNT=${MNT%?}
								fi

								sed -i '/MNT/d' /etc/borg.d/env
								if [ $? -ne 0 ]
									then
										echo -e "${RED}Can't change mount parameters please check if your env file is still at /etc/borg.d/${RESET}"
										exit 1
								fi
								echo MNT=\$"\"$MNT\"" >> /etc/borg.d/env

								rm ~/.passwd-s3fs 2>/dev/null >/dev/null
								echo "$ACCESS_KEY":"$SECRET_KEY" > ~/.passwd-s3fs
								chmod 600 ~/.passwd-s3fs
								echo "Your keys were saved in ~/.passwd-s3fs"

								#If unsure of what failed comment the first line and uncomment the second line to enable debug mode
								echo "Mounting Wasabi Bucket"
								s3fs "$BUCKET" "$MNT" -o passwd_file="${HOME}"/.passwd-s3fs -o url=https://s3."$BUCKET_LOC".wasabisys.com
								#s3fs $BUCKET $MNT -o passwd_file=${HOME}/.passwd-s3fs -o url=https://s3.$BUCKET_LOC.wasabisys.com -o dbglevel=info -f -o rldbg

								echo "Verifying Mount"

								mount -l | grep "$MNT"

								if [ $? -ne 0 ]
									# If success
									then
										echo -e "${RED}Mounting has failed. Please try doing it manually.${RESET}"
										printf "\n"
										sleep 3s
										exit 1 # Exit with general error
									# If failure
									else
										echo -e "${GREEN}Bucket mounted successfully.${RESET}"
										printf "\n"
										sleep 3s
								fi

								#Option to mount bucket at boot
								while true;
									do
										read -r -p "Do you wish to mount the bucket at boot?(yn)" yn
											case $yn in
											[Yy]* ) echo "s3fs#$BUCKET $MNT fuse _netdev,allow_other,use_path_request_style,url=https://s3.$BUCKET_LOC.wasabisys.com/ 0 0" >> /etc/fstab;break;;
											[Nn]* ) break;;
												* ) echo -e "${RED}Please answer yes or no.${RESET}";;
											esac
								done
								echo -e "${GREEN}Backup Location changed succesfully.${RESET}"
								exit 0
						elif [[ "$WASABI" == Keep ]]
							then
								umount "${MNT}"
								sed -i '/${MNT}/d' /etc/fstab
								#Prompt to define repo location
								while true
									do
										read -r -p "Please enter the new location for the backup repository. Your S3 storage will be mounted to this location. The folder has to be empty. If it does not exist it will be created automatically. [/BACKUP]: $(echo $'\n> ')" MNT
										MNT=${MNT:-/BACKUP}                                                          #Used to provide default option
										read -r -p "You selected '$MNT' is this correct?(y/n)" yn
											case $yn in
												[Yy]* ) break;;
												[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
													* ) echo -e "${RED}Please answer yes or no.${RESET}";;
											esac
								done
								mkdir "$MNT" 2>/dev/null >/dev/null
								chmod 777 "$MNT"

								if [ "${MNT: -1}" == "/" ]  #Checks if there is a forward slash in the path and if there is removes it
									then
										MNT=${MNT%?}
								fi

								sed -i '/MNT/d' /etc/borg.d/env
								if [ $? -ne 0 ]
									then
										echo -e "${RED}Can't change mount parameters please check if your env file is still at /etc/borg.d/${RESET}"
										exit 1
								fi
								echo MNT=\$"\"$MNT\"" >> /etc/borg.d/env
								rm ~/.passwd-s3fs 2>/dev/null >/dev/null
								echo "$ACCESS_KEY":"$SECRET_KEY" > ~/.passwd-s3fs
								chmod 600 ~/.passwd-s3fs
								echo "Your keys were saved in ~/.passwd-s3fs"

								#If unsure of what failed comment the first line and uncomment the second line to enable debug mode
								echo "Mounting Wasabi Bucket"
								s3fs "$BUCKET" "$MNT" -o passwd_file="${HOME}"/.passwd-s3fs -o url=https://s3."$BUCKET_LOC".wasabisys.com
								#s3fs $BUCKET $MNT -o passwd_file=${HOME}/.passwd-s3fs -o url=https://s3.$BUCKET_LOC.wasabisys.com -o dbglevel=info -f -o rldbg

								echo "Verifying Mount"

								mount -l | grep "$MNT"

								if [ $? -ne 0 ]
									# If success
									then
										echo -e "${RED}Mounting has failed. Please try doing it manually.${RESET}"
										printf "\n"
										sleep 3s
										exit 1 # Exit with general error
									# If failure
									else
										echo -e "${GREEN}Bucket mounted successfully.${RESET}"
										printf "\n"
										sleep 3s
								fi

								#Option to mount bucket at boot
								while true;
									do
										read -r -p "Do you wish to mount the bucket at boot?(yn)" yn
											case $yn in
												[Yy]* ) echo "s3fs#$BUCKET $MNT fuse _netdev,allow_other,use_path_request_style,url=https://s3.$BUCKET_LOC.wasabisys.com/ 0 0" >> /etc/fstab;break;;
												[Nn]* ) break;;
														* ) echo -e "${RED}Please answer yes or no.${RESET}";;
											esac
								done
								echo -e "${GREEN}Backup Location changed succesfully.${RESET}"
								exit 0
						fi
				elif [[ "$BACKUP_TYPE" == Local ]]
					then
						while true
							do
								read -r -p "Please enter the new location for the backup repository. The folder has to be empty. If it does not exist it will be created automatically. [/BACKUP]: $(echo $'\n> ')" MNT
								MNT=${MNT:-/BACKUP}                                                          #Used to provide default option
								read -r -p "You selected '$MNT' is this correct?(y/n)" yn
									case $yn in
										[Yy]* ) break;;
										[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
											* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done
						mkdir "$MNT" 2>/dev/null >/dev/null
						chmod 777 "$MNT"
						if [ "${MNT: -1}" == "/" ]  #Checks if there is a forward slash in the path and if there is removes it
							then
								MNT=${MNT%?}
						fi
						sed -i '/MNT/d' /etc/borg.d/env
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Can't change mount parameters please check if your env file is still at /etc/borg.d/${RESET}"
								exit 1
						fi
						echo MNT=\$"\"$MNT\"" >> /etc/borg.d/env
						echo -e "${GREEN}Backup Location changed succesfully.${RESET}"
						exit 0
				fi
		elif [[ "$SECOND" == Compression ]]
			then
				echo "Your current compression setting is $COMPRESSION"
				sleep 3s
				while true
					do
						read -r -p "Do you wish to change it?(y/n)" yn
							case $yn in
								[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 3s;break;;
								[Nn]* ) exit 1;;
								* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
				done
				while [[ $yn != y ]]
					do
						# Parent menu items declared here
						echo "You can now select the compression you want for the backups from the following:"
						echo "LZ4  - Super Fast, Low Compression"
						echo "ZLIB - Less fast, Higher Compression"
						echo "ZSTD - Slower, Higher Compression"
						echo "LZMA - Even Slower, Even Higher Compression"
						printf "\n"
						echo "Beware that all compression algorithms will be at their maximum compression setting."
						PS3="Please select your compression preference: "
						select COMPRESSION in LZ4 ZLIB ZSTD LZMA
							do
								case $COMPRESSION in
									[LZ4]*)  break;;
									[ZLIB]*) break;;
									[ZSTD]*) break;;
									[LZMA]*) break;;
											*) echo -e "${RED}Invalid Option.${RESET}";;
								esac
						done
						while true;
							do
								read -r -p "You chose $COMPRESSION. Is this correct?(yn)" yn
								case $yn in
									[Yy]* ) break;;
									[Nn]* ) echo -e "${RED}Please choose again.${RESET}";break;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
								esac
						done
				done

				if [[ $COMPRESSION = LZ4 ]]
					then
						COMPRESSION="lz4"
				elif [[ $COMPRESSION = ZLIB ]]
					then
						COMPRESSION="zlib,9"
				elif [[ $COMPRESSION = ZSTD ]]
					then
						COMPRESSION="zstd,22"
				elif [[ $COMPRESSION = LZMA ]]
					then
						COMPRESSION="lzma,9"
				fi

				sed -i '/COMPRESSION/d' /etc/borg.d/env
				if [ $? -ne 0 ]
					then
						echo -e "${RED}Can't change compression parameters please check if your env file is still at /etc/borg.d/${RESET}"
						exit 1
				fi
				echo COMPRESSION=\$"\"$COMPRESSION\"" >> /etc/borg.d/env
				echo -e "${GREEN}Compression changed successfully.${RESET}"
		elif [[ "$SECOND" == "Retention Settings" ]]
			then
				while [[ $yn != y ]]
					do
						PS3="Please choose which retention setting you wish to change: "
						select RETENTION in Daily Weekly Monthly All
							do
								case $RETENTION in
									["Daily"]*) break;;
									["Weekly"]*) break;;
									["Monthly"]*) break;;
									["All"]*) break;;
											*) echo -e "${RED}Invalid Option.${RESET}";;
								esac
						done
						while true
							do
								read -r -p "You chose $RETENTION. Are you sure?(y/n)" yn
									case $yn in
										[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 3s;break;;
										[Nn]* ) echo -e "${RED}Please choose again.${RESET}";;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done
				done
				if [[ "$RETENTION" == Daily ]]
					then
						#Prompt for daily retention of automatic backup
						while true
							do
						  	read -r -p "Please select how many daily backups you wish to have $(echo $'\n> ')" DAILY
						    	case $DAILY in
						      	([0-7] ) echo "Proceeding...";sleep 2s;break;;
						        		* ) echo "Please input valid number.";sleep 2s;;
						    	esac
						done
						sed -i '/DAILY/d' /etc/borg.d/env
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Can't change retention parameters please check if your env file is still at /etc/borg.d/${RESET}"
								exit 1
						fi
						echo DAILY=\$"\"$DAILY\"" >> /etc/borg.d/env
						echo -e "${GREEN}Daily Retention Changed Successfully.${RESET}"
						sleep 3s
						exit 0
				elif [[ "$RETENTION" == Weekly ]]
					then
						#Prompt for daily retention of automatic backup
						while true
							do
								read -r -p "Please select how many weekly backups you wish to have $(echo $'\n> ')" WEEKLY
								case $WEEKLY in
									([0-4] ) echo -e "${GREEN}Proceeding...${RESET}";sleep 2s;break;;
												* ) echo -e "${RED}Please input valid number.${RESET}";sleep 2s;;
								esac
						done
						sed -i '/WEEKLY/d' /etc/borg.d/env
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Can't change retention parameters please check if your env file is still at /etc/borg.d/${RESET}"
								exit 1
						fi
						echo WEEKLY=\$"\"$WEEKLY\"" >> /etc/borg.d/env
						echo -e "${GREEN}Weekly Retention Changed Successfully.${RESET}"
						sleep 3s
						exit 0
				elif [[ "$RETENTION" == Monthly ]]
					then
						#Prompt for daily retention of automatic backup
						while true
							do
								read -r -p "Please select how many monthly backups you wish to have $(echo $'\n> ')" MONTHLY
									case $MONTHLY in
										([0-9] ) echo -e "${GREEN}Proceeding...${RESET}";sleep 2s;break;;
										(1[0-2] ) echo -e "${GREEN}Proceeding...${RESET}";sleep 2s;break;;
													* ) echo -e "${RED}Please input valid number.${RESET}";sleep 2s;;
									esac
						done
						sed -i '/MONTHLY/d' /etc/borg.d/env
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Can't change retention parameters please check if your env file is still at /etc/borg.d/${RESET}"
								exit 1
						fi
						echo MONTHLY=\$"\"$MONTHLY\"" >> /etc/borg.d/env
						echo -e "${GREEN}Monthly Retention Changed Successfully.${RESET}"
						sleep 3s
						exit 0
				elif [[ "$RETENTION" == All ]]
					then
						while true
							do
				        read -r -p "Please select how many daily backups you wish to have $(echo $'\n> ')" DAILY
				        	case $DAILY in
				      			([0-7] ) echo -e "${GREEN}Proceeding...${RESET}";sleep 2s;break;;
				           				* ) echo -e "${RED}Please input valid number.${RESET}";sleep 2s;;
				    			esac
						done
						while true
							do
				        read -r -p "Please select how many weekly backups you wish to have $(echo $'\n> ')" WEEKLY
				        	case $WEEKLY in
				      			([0-4] ) echo -e "${GREEN}Proceeding...${RESET}";sleep 2s;break;;
				             		* ) echo -e "${RED}Please input valid hour.${RESET}";sleep 2s;;
				    			esac
						done
						while true
							do
				        read -r -p "Please select how many monthly backups you wish to have $(echo $'\n> ')" MONTHLY
				        	case $MONTHLY in
				      			([0-9] ) echo -e "${GREEN}Proceeding...${RESET}";sleep 2s;break;;
				      			(1[0-2] ) echo -e "${GREEN}Proceeding...${RESET}";sleep 2s;break;;
				             			* ) echo -e "${RED}Please input valid hour.${RESET}";sleep 2s;;
				    			esac
						done
						sed -i '/DAILY/d' /etc/borg.d/env
						sed -i '/WEEKLY/d' /etc/borg.d/env
						sed -i '/MONTHLY/d' /etc/borg.d/env
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Can't change retention parameters please check if your env file is still at /etc/borg.d/${RESET}"
								exit 1
						fi
						echo DAILY=\$"\"$DAILY\"" >> /etc/borg.d/env
						echo WEEKLY=\$"\"$WEEKLY\"" >> /etc/borg.d/env
						echo MONTHLY=\$"\"$MONTHLY\"" >> /etc/borg.d/env
						echo -e "${GREEN}Retention Changed Successfully.${RESET}"
						sleep 3s
						exit 0
			  fi
	fi
elif [[ "$FIRST" == "Notification Settings" ]]
 	then
		while [[ $yn != y ]]
			do
				# Parent menu items declared here
				PS3="Please choose what you want to change: "
				select THIRD in "Mail Settings" "Notification Type(PlaceHolder)" Exit
					do
						# case statement to compare the first menu items
						case $THIRD in
							["Mail Settings"]*) break;;
													[Exit]*) exit 0;;
															*) echo -e "${RED}Invalid Option.${RESET}";;
						esac
				done
				while true
					do
						read -r -p "You chose $THIRD. Is this correct?(y/n)" yn
							case $yn in
								[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 3s;break;;
								[Nn]* ) echo -e "${RED}Please choose again.${RESET}";sleep 3s;break;;
									* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
				done
		done
		unset yn
		if [[ "$THIRD" == "Mail Settings" ]]
			then
				while [[ $yn != y ]]
					do
						PS3="Please Choose the Mail Setting you Wish to Change: "
						select EMAIL_SETTING in "SMTP Password" "SMTP URL" "Notification Email" "Sender Email" "Sender Name" All
							do
								case $EMAIL_SETTING in
									["SMTP Password"]*) break;;
									["SMTP URL"]*) break;;
									["Notification Email"]*) break;;
									["Sender Email"]*) break;;
									["Sender Name"]*) break;;
									["All"]*) break;;
															*) echo -e "${RED}Invalid Option.${RESET}";;
								esac
						done
						while true
							do
								read -r -p "You chose to change $EMAIL_SETTING. Is this correct?(y/n)" yn
									case $yn in
										[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 3s;break;;
										[Nn]* ) exit 1;;
												* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done
				done
				if [[ "$EMAIL_SETTING" == "SMTP Password" ]]
					then
						read -r -s -p "Please enter the new SMTP password for your server: $(echo $'\n> ')" SMTP_PASS1
						read -r -s -p "Please confirm your SMTP password: $(echo $'\n> ')" SMTP_PASS2

						while [ "$SMTP_PASS1" != "$SMTP_PASS2" ];
							do
								echo -e "${RED}Password Mismatch. Please try again.${RESET}"
								read -r -s -p "Please enter the new SMTP password for your server: $(echo $'\n> ')" SMTP_PASS1
								read -r -s -p "Please confirm your SMTP password: $(echo $'\n> ')" SMTP_PASS2
						done

						SMTP_PASS="$SMTP_PASS2"

						sed -i '/SMTP_PASS/d' /etc/borg.d/env
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Can't change mail parameters please check if your env file is still at /etc/borg.d/${RESET}"
								exit 1
						fi
						echo SMTP_PASS=\$"\"$SMTP_PASS\"" >> /etc/borg.d/env
						rm ~/.muttrc
						set -x                               #Sends output to terminal
						(wget -P "$TEMP" https://raw.githubusercontent.com/The-Inamati/LXD-Backup-Script/master/Mutt_Config_File)
						mv "$TEMP"/Mutt_Config_File ~/.muttrc
						{ set +x; } 2>/dev/null              #Stops output to terminal and hides set+x from output
						sed -i -e 's|${FROM_MAIL}|'"$FROM_MAIL"'|' -e "s/\${FROM_NAME}/$FROM_NAME/" -e 's|${SMTP_PASS}|'"$SMTP_PASS"'|' -e 's|${SMTP_URL}|'"$SMTP_URL"'|'  ~/.muttrc
						echo -e "${GREEN}Your SMTP Password was changed successfully.${RESET}"
						sleep 3s
						exit 0
				elif [[ "$EMAIL_SETTING" == "SMTP URL" ]]
					then
						while true
							do
								read -r -p "Please input the new URL to your SMTP server in the following format (mail.domain.com:587): $(echo $'\n> ')" SMTP_URL
								read -r -p "You entered '$SMTP_URL' is this correct?(y/n)" yn
									case $yn in
									[Yy]* ) break;;
									[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done

						sed -i '/SMTP_URL/d' /etc/borg.d/env
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Can't change mail parameters please check if your env file is still at /etc/borg.d/${RESET}"
								exit 1
						fi
						echo SMTP_URL=\$"\"$SMTP_URL\"" >> /etc/borg.d/env
						rm ~/.muttrc
						set -x                               #Sends output to terminal
						(wget -P "$TEMP" https://raw.githubusercontent.com/The-Inamati/LXD-Backup-Script/master/Mutt_Config_File)
						mv "$TEMP"/Mutt_Config_File ~/.muttrc
						{ set +x; } 2>/dev/null              #Stops output to terminal and hides set+x from output
						sed -i -e 's|${FROM_MAIL}|'"$FROM_MAIL"'|' -e "s/\${FROM_NAME}/$FROM_NAME/" -e 's|${SMTP_PASS}|'"$SMTP_PASS"'|' -e 's|${SMTP_URL}|'"$SMTP_URL"'|'  ~/.muttrc
						echo -e "${GREEN}Your SMTP URL was changed successfully.${RESET}"
						sleep 3s
						exit
				elif [[ "$EMAIL_SETTING" == "Notification Email" ]]
					then
						while true
							do
								read -r -p "Please define the new email to receive backup notifications: $(echo $'\n> ')" EMAIL
								read -r -p "You entered '$EMAIL' is this correct?(y/n)" yn
									case $yn in
									[Yy]* ) break;;
									[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done

						sed -i '/EMAIL/d' /etc/borg.d/env
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Can't change mail parameters please check if your env file is still at /etc/borg.d/${RESET}"
								exit 1
						fi
						echo EMAIL=\$"\"$EMAIL\"" >> /etc/borg.d/env
						echo -e "${GREEN}Your notification email was changed successfully.${RESET}"
						sleep 3s
						exit 0
				elif [[ "$EMAIL_SETTING" == "Sender Email" ]]
					then
						while true
							do
								read -r -p "Please define the new email sender for backup notifications.	This email has to be configured on your SMTP server:$(echo $'\n> ')" FROM_MAIL
								read -r -p "You entered '$FROM_MAIL' is this correct?(y/n)" yn
									case $yn in
									[Yy]* ) break;;
									[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
						                * ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done

						sed -i '/FROM_MAIL/d' /etc/borg.d/env
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Can't change mail parameters please check if your env file is still at /etc/borg.d/${RESET}"
								exit 1
						fi
						echo FROM_MAIL=\$"\"$FROM_MAIL\"" >> /etc/borg.d/env
						rm ~/.muttrc
						set -x                               #Sends output to terminal
						(wget -P "$TEMP" https://raw.githubusercontent.com/The-Inamati/LXD-Backup-Script/master/Mutt_Config_File)
						mv "$TEMP"/Mutt_Config_File ~/.muttrc
						{ set +x; } 2>/dev/null              #Stops output to terminal and hides set+x from output
						sed -i -e 's|${FROM_MAIL}|'"$FROM_MAIL"'|' -e "s/\${FROM_NAME}/$FROM_NAME/" -e 's|${SMTP_PASS}|'"$SMTP_PASS"'|' -e 's|${SMTP_URL}|'"$SMTP_URL"'|'  ~/.muttrc
						echo -e "${GREEN}Your sender email was changed successfully.${RESET}"
						sleep 3s
						exit 0
				elif [[ "$EMAIL_SETTING" == "Sender Name" ]]
					then
						while true
							do
								read -r -p "Please define the new sender name for backup notifications: $(echo $'\n> ')" FROM_NAME
								read -r -p "You entered '$FROM_NAME' is this correct?(y/n)" yn
									case $yn in
									[Yy]* ) break;;
									[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done
						sed -i '/FROM_MAIL/d' /etc/borg.d/env
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Can't change mail parameters please check if your env file is still at /etc/borg.d/${RESET}"
								exit 1
						fi
						echo FROM_NAME=\$"\"$FROM_NAME\"" >> /etc/borg.d/env
						rm ~/.muttrc
						set -x                               #Sends output to terminal
						(wget -P "$TEMP" https://raw.githubusercontent.com/The-Inamati/LXD-Backup-Script/master/Mutt_Config_File)
						mv "$TEMP"/Mutt_Config_File ~/.muttrc
						{ set +x; } 2>/dev/null              #Stops output to terminal and hides set+x from output
						sed -i -e 's|${FROM_MAIL}|'"$FROM_MAIL"'|' -e "s/\${FROM_NAME}/$FROM_NAME/" -e 's|${SMTP_PASS}|'"$SMTP_PASS"'|' -e 's|${SMTP_URL}|'"$SMTP_URL"'|'  ~/.muttrc
						echo -e "${GREEN}Your sender name was changed successfully.${RESET}"
						sleep 3s
						exit 0
				elif [[ "$EMAIL_SETTING" == All ]]
					then
						while true
							do
								read -r -p "Please define the new email to receive backup notifications: $(echo $'\n> ')" EMAIL
								read -r -p "You entered '$EMAIL' is this correct?(y/n)" yn
									case $yn in
									[Yy]* ) break;;
									[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done

						sed -i '/EMAIL/d' /etc/borg.d/env
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Can't change mail parameters please check if your env file is still at /etc/borg.d/${RESET}"
								exit 1
						fi
						echo EMAIL=\$"\"$EMAIL\"" >> /etc/borg.d/env

						while true
							do
								read -r -p "Please define the new email sender for backup notifications.This email has to be configured on your SMTP server:$(echo $'\n> ')" FROM_MAIL
								read -r -p "You entered '$FROM_MAIL' is this correct?(y/n)" yn
									case $yn in
									[Yy]* ) break;;
									[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
						                * ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done

						sed -i '/FROM_MAIL/d' /etc/borg.d/env
						echo FROM_MAIL=\$"\"$FROM_MAIL\"" >> /etc/borg.d/env

						read -r -s -p "Please enter the new SMTP password for your server: $(echo $'\n> ')" SMTP_PASS1
						read -r -s -p "Please confirm your SMTP password: $(echo $'\n> ')" SMTP_PASS2

						while [ "$SMTP_PASS1" != "$SMTP_PASS2" ];
							do
								echo -e "${RED}Password Mismatch. Please try again.${RESET}"
								read -r -s -p "Please enter the SMTP password for your server: $(echo $'\n> ')" SMTP_PASS1
								read -r -s -p "Please confirm your SMTP password: $(echo $'\n> ')" SMTP_PASS2
						done

						SMTP_PASS="$SMTP_PASS2"

						sed -i '/SMTP_PASS/d' /etc/borg.d/env
						echo SMTP_PASS=\$"\"$SMTP_PASS\"" >> /etc/borg.d/env

						while true
							do
								read -r -p "Please define the new sender name for backup notifications: $(echo $'\n> ')" FROM_NAME
								read -r -p "You entered '$FROM_NAME' is this correct?(y/n)" yn
									case $yn in
									[Yy]* ) break;;
									[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done

						sed -i '/FROM_NAME/d' /etc/borg.d/env
						echo FROM_NAME=\$"\"$FROM_NAME\"" >> /etc/borg.d/env

						while true
							do
								read -r -p "Please indicate the new URL to your SMTP server in the following format (mail.domain.com:587): $(echo $'\n> ')" SMTP_URL
								read -r -p "You entered '$SMTP_URL' is this correct?(y/n)" yn
									case $yn in
									[Yy]* ) break;;
									[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done

						sed -i '/SMTP_URL/d' /etc/borg.d/env
						echo SMTP_URL=\$"\"$SMTP_URL\"" >> /etc/borg.d/env

						set -x                               #Sends output to terminal
						(wget -P "$TEMP" https://raw.githubusercontent.com/The-Inamati/LXD-Backup-Script/master/Mutt_Config_File)
						mv "$TEMP"/Mutt_Config_File ~/.muttrc
						{ set +x; } 2>/dev/null              #Stops output to terminal and hides set+x from output
						sed -i -e 's|${FROM_MAIL}|'"$FROM_MAIL"'|' -e "s/\${FROM_NAME}/$FROM_NAME/" -e 's|${SMTP_PASS}|'"$SMTP_PASS"'|' -e 's|${SMTP_URL}|'"$SMTP_URL"'|'  ~/.muttrc
						echo -e "${GREEN}Your email settings were changed successfully.${RESET}"
						sleep 3s
						exit 0
				fi
		fi
elif [[ "$FIRST" == "General Settings" ]]
	then
		while [[ $yn != y ]]
			do
				PS3="Please choose what you want to change: "
				select FOURTH in "Borg Encryption Key" "Get Repo Keys" "Container Location" "Wasabi Settings" Exit
					do
						case $FOURTH in
							["Borg Encryption Key"]*) break;;
							["Get Repo Keys"]*) break;;
							["Container Location"]*) break;;
													[exit]*) exit 0;;
													*) echo -e "${RED}Invalid Option.${RESET}";;
						esac
				done
				while true
					do
						read -r -p "You chose $FOURTH. Is this correct?(y/n)" yn
							case $yn in
								[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 5s;break;;
								[Nn]* ) exit 1;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
				done
		done
		if [[ "$FOURTH" == "Borg Encryption Key" ]]
			then
				 while [[ $yn != y ]]
					do
						read -r -p "This will change the encryption key for all repositories. Do you wish to continue?(y/n)" yn
							case $yn in
								[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 5s;break;;
								[Nn]* ) exit 1;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
					done
					read -r -s -p "Please enter the new passphrase for your backup repositories: $(echo $'\n> ')" ENCRYPT1
					read -r -s -p "Please confirm the passphrase: $(echo $'\n> ')" ENCRYPT2

					while [ "$ENCRYPT1" != "$ENCRYPT2" ];
						do
							echo -e "${RED}Key Mismatch. Please try again.${RESET}"
							read -r -s -p "Please enter the passphrase for your backup repositories: $(echo $'\n> ')" ENCRYPT1
							read -r -s -p "Please confirm the passphrase: $(echo $'\n> ')" ENCRYPT2
					done

					ENCRYPT="$ENCRYPT2"

					mv /etc/borg.d/.borg-passphrase /etc/borg.d/.oldpassphrase
					echo "$ENCRYPT" >> /etc/borg.d/.borg-passphrase
					chmod 400 /etc/borg.d/.borg-passphrase

					OLD_PASS=$(</etc/borg.d/.oldpassphrase)

					cd "$MNT" || exit
					for i in *
						do
							BORG_PASSPHRASE="$OLD_PASS"  BORG_NEW_PASSPHRASE="$ENCRYPT" borg key change-passphrase "$MNT"/"$i"
					done

					rm /etc/borg.d/.oldpassphrase

					echo -e "${GREEN}Encryption Key Changed Successfully.${RESET}"
					exit 0

		elif [[ "$FOURTH" == "Get Repo Keys" ]]
			then
				cd "$MNT" || exit

				for i in *
					do
						printf "\n"
						echo "Your encryption key for the repo $i is:"
						printf "\n"
						printf "\n"
						cat /etc/borg.d/keys/"$i"-key.txt
						printf "\n"
						echo "Please save the key or the file with it located in /etc/borg.d/keys/$i-key.txt"
						echo "Key for $i exported successfully" | mutt -s "Repo key for $i" "$EMAIL" -a /etc/borg.d/keys/"$i"-key.txt
						echo "This key was also sent to you by email"
						printf "\n"
						read -r -p "Press enter to continue"
				done

				echo -e "${GREEN}All keys exported successfully.${RESET}"

		elif [[ "$FOURTH" == "Container Location" ]]
			then
				while true
					do
						echo -e "${RED}WARNING:The old container location will no longer be backed up.${RESET}"
						while true
							do
								read -r -p "Do you wish to continue?(y/n)" yn
									case $yn in
										[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 5s;break;;
										[Nn]* ) exit 1;;
												* ) echo -e "${RED}Please answer yes or no.${RESET}";;
									esac
						done
						read -r -p "Please enter the new location of your LXD containers: $(echo $'\n> ')" LXD
						read -r -p "You selected '$LXD' is this correct?(y/n)" yn
							case $yn in
								[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";break;;
							[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
								* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
				done
				echo -e "${GREEN}Container Location changed successfully.${RESET}"

		elif [[ "$FOURTH" == "Wasabi Settings" ]]
			then
				echo "Checking for Mounted Buckets"
				sleep 3s
				while true
					do
						read -r -p "The bucket is mounted at $MNT. Do you wish to proceed?(y/n)" yn
							case $yn in
								[Yy]* ) echo -e "${GREEN}Proceeding...${RESET}";sleep 3s;break;;
								[Nn]* ) echo -e "${RED}Terminating Script.${RESET}";sleep 3s;exit 1;;
									* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
				done
				mount -l | grep "${MNT}"
				if [ $? -eq 0 ]
					then
						umount "${MNT}"
						sed -i '/${MNT}/d' /etc/fstab
						if [ $? -ne 0 ]
							then
								echo -e "${RED}Error unmounting the bucket. Please try manually.${RESET}"
								exit 1
							else
								echo -e "${GREEN}Bucket unmounted sucessfully.${RESET}"
						fi
				fi
				while true
					do
						read -r -p "Please enter your Wasabi Access Key: $(echo $'\n> ')" ACCESS_KEY
						read -r -p "You entered '$ACCESS_KEY' is this correct?(y/n)" yn
							case $yn in
								[Yy]* ) break;;
								[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
				done
				sed -i '/ACCESS_KEY/d' /etc/borg.d/env
				if [ $? -ne 0 ]
					then
						echo -e "${RED}Can't change Wasabi parameters please check if your env file is still at /etc/borg.d/${RESET}"
						exit 1
				fi
				echo ACCESS_KEY=\$"\"$ACCESS_KEY\"" >> /etc/borg.d/env
				while true
					do
						read -r -p "Please enter your Wasabi Secret Key: $(echo $'\n> ')" SECRET_KEY
						read -r -p "You entered '$SECRET_KEY' is this correct?(y/n)" yn
							case $yn in
								[Yy]* ) break;;
								[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
				done
				sed -i '/SECRET_KEY/d' /etc/borg.d/env
				if [ $? -ne 0 ]
					then
						echo -e "${RED}Can't change Wasabi parameters please check if your env file is still at /etc/borg.d/${RESET}"
						exit 1
				fi
				echo SECRET_KEY=\$"\"$SECRET_KEY\"" >> /etc/borg.d/env
				while true
					do
						read -r -p "Please enter the region selected when creating the bucket [eu-central-1]: $(echo $'\n> ')" BUCKET_LOC
						BUCKET_LOC=${BUCKET_LOC:-eu-central-1}                                                          #Used to provide default option
						read -r -p "You selected '$BUCKET_LOC' is this correct?(y/n)" yn
							case $yn in
								[Yy]* ) break;;
								[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
				done
				sed -i '/BUCKET_LOC/d' /etc/borg.d/env
				if [ $? -ne 0 ]
					then
						echo -e "${RED}Can't change Wasabi parameters please check if your env file is still at /etc/borg.d/${RESET}"
						exit 1
				fi
				echo BUCKET_LOC=\$"\"$BUCKET_LOC\"" >> /etc/borg.d/env
				while true
					do
						read -r -p "Please enter the name of the bucket you created: $(echo $'\n> ')" BUCKET
						read -r -p "You entered '$BUCKET' is this correct?(y/n)" yn
							case $yn in
								[Yy]* ) break;;
								[Nn]* ) echo -e "${RED}Please try again:${RESET}";sleep 2s;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
				done
				sed -i '/BUCKET/d' /etc/borg.d/env
				if [ $? -ne 0 ]
					then
						echo -e "${RED}Can't change Wasabi parameters please check if your env file is still at /etc/borg.d/${RESET}"
						exit 1
				fi
				echo BUCKET=\$"\"$BUCKET\"" >> /etc/borg.d/env
				rm ~/.passwd-s3fs 2>/dev/null >/dev/null
				echo "$ACCESS_KEY":"$SECRET_KEY" > ~/.passwd-s3fs
				chmod 600 ~/.passwd-s3fs
				echo "Your keys were saved in ~/.passwd-s3fs"
				echo "Mounting Wasabi Bucket"
				s3fs "$BUCKET" "$MNT" -o passwd_file="${HOME}"/.passwd-s3fs -o url=https://s3."$BUCKET_LOC".wasabisys.com
				echo "Verifying Mount"
				mount -l | grep "$MNT"
				if [ $? -ne 0 ]
					then
						echo -e "${RED}Mounting has failed. Please try doing it manually.${RESET}"
						printf "\n"
						sleep 3s
						exit 1
					else
						echo -e "${GREEN}Bucket mounted successfully.${RESET}"
						printf "\n"
						sleep 3s
				fi
				while true;
					do
						read -r -p "Do you wish to mount the bucket at boot?(yn)" yn
							case $yn in
								[Yy]* ) echo "s3fs#$BUCKET $MNT fuse _netdev,allow_other,use_path_request_style,url=https://s3.$BUCKET_LOC.wasabisys.com/ 0 0" >> /etc/fstab;break;;
								[Nn]* ) break;;
										* ) echo -e "${RED}Please answer yes or no.${RESET}";;
							esac
				done
				echo -e "${GREEN}Backup Location changed succesfully.${RESET}"
				exit 0
		fi
fi
