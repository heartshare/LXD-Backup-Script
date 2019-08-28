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

### Planned

- Pushover Support (without the attachments because Pushover only supports images)
- XMPP Support
- Possibly Gotify Support also
- Automatic LXD Restore Script
- Script Optimization (As I learn more about bash scripting)

### Disclaimer

As I said this is my first script. Any feedback is appreciated. I will test any optimization or change to code you propose. I'm open to learn.
