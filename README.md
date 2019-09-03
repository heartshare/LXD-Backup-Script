# LXD-Backup-Script
Automatic LXC Backup using Borg with notifications


### Introduction

Hi All,
I desperately needed something that would backup my LXD containers automatically. Since I couldn't find anything with the features I wanted I decided to make my first bash script.

### Features

- Automatic Backup of Existing Containers using Borg
- Automatic Backup and Detection of New Containers
- Email Notification Reports of Backups
- Auto Detection of Missing Containers and Notification
- Use of S3 Storage in Wasabi as Mount for Backups
- Automatic Removal of Repositories, Archives and Everything Script Related

### Types of Backup Storage Available
- SSH
- Local
- Wasabi

### Types of Notification Available
- Email (Mutt)

### How to Run

Download the file Install_Script, make it executable and run it as root. It will do everything on its own.

### Notes

The script that is run as a service is located at /etc/borg.d/.

The Cleanup, Restore and Modify Scripts are also at this location.

A log file is saved everytime it runs at /var/log/.

The configuration file for Mutt is saved at ~/.muttrc.

Keys for Wasabi are saved at ~/.passwd-s3fs.

Keys for Borg Repositories are saved at /etc/borg.d/keys/.

### Wasabi

For Wasabi you need the following:
- Access Key
- Secret Key
- Bucket Name
- Bucket Region

### Mutt

To use Mutt you need to have a mail server working and an available email account to be used for notifications.

Or you can use your Gmail SMTP details.

### Planned

- Pushover Support (without the attachments because Pushover only supports images)
- XMPP Support
- Possibly Gotify Support also
- Automatic LXD Restore Script
- Modify/Migration Script
- Script Optimization (As I learn more about bash scripting)
- Plus whatever you tell me that makes sense.

### Disclaimer

As I said this is my first script. Any feedback is appreciated. I will test any optimization or change to code you propose. I'm open to learn.
