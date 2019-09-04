#!/bin/bash

clear

echo "Restore Script"
echo "--------------"
sleep 3s

export BORG_PASSCOMMAND="cat /etc/borg.d/.borg-passphrase"

RESET='\e[0m'
RED='\e[31m'
GREEN='\e[32m'

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
		echo "Please select the repository from which you want to restore:"
		select RESTORE in "${REPOS[@]}"
			do
				[[ -n $RESTORE ]] || { echo -e "${RED}Invalid choice. Please try again.${RESET}" >&2; continue; }
				break # valid choice was made; exit prompt.
		done

		read -p "You selected the repository $RESTORE. Are you sure?(y/n)" yn
			case $yn in
				[Yy]* ) break;;
				[Nn]* ) echo -e "${RED}Please choose again${RESET}";sleep 2s;;
					* ) echo -e "${RED}Please answer yes or no.${RESET}";sleep 2s;;
			esac
done
		
unset yn				

readarray -t ARCHIVES < <(borg list ${MNT}/$RESTORE)
		
if [ -z "$ARCHIVES" ]
	then
		echo -e "${RED}No archives found on the repository $REMOVE${RESET}"
		sleep 3s
		exit 0
fi

while [[ $yn != y ]]
	do
		echo "Please select the archive from which you want to restore:"
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

mkdir /restore
		
cd /restore
		
ARCHIVE=$(echo $ARCHIVE | cut -d' ' -f1)
borg extract -p ${MNT}/$RESTORE::$ARCHIVE

echo -e "${GREEN}The archive was extracted successfully.${RESET}"
sleep 3s

echo "Importing Container"
echo "-------------------"

cd /restore/tmp

for i in *

#Import image to local image list
echo "Importing Image"
lxc image import $i --alias restore-$RESTORE

while true 
	do
		read -p "Please choose a name for the container you want to restore. Default is Repo name. [$RESTORE]: `echo $'\n> '`" NAME
        NAME=${NAME:-$RESTORE}                                                          #Used to provide default option
			read -p "You selected '$NAME' is this correct?(y/n)" yn
			case $yn in
            [Yy]* ) break;;
            [Nn]* ) echo "Please try again:";sleep 2s;;
                * ) echo "Please answer yes or no.";;
            esac
done

#launch container using image
echo "Restauring Container"
lxc launch restore-$NAME mail


echo "Checking for Container"
lxc list | grep $NAME

if [ $? -ne 0 ]
	then
		echo "There was a problem launching the container"
		sleep 2s
		echo "Please try launching it manually"
		sleep 2s
		exit 1
	else
		echo "Container was launched successfully"
		sleep 2s
fi

echo "Removing Leftovers"
lxc image delete restore-$NAME
rm -rf /restore
