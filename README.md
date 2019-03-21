# MikroTik RouterOs Autoupdate

This repository contains scripts which allow MikroTik RouterOS devices to have its OS, packages, and firmware always up to date. About all updates and failures email notifications are sent.

## Description

These scripts perform these oprations:

- Check if package updates available (same as `System -> Packages` and `Check For Updates`)
- If updates available, send start update notification email
- Initialize packages update
- After updates the device reboots
- On start check if RouterOS updated, and notify this by email
- Initaialize firmware upgrade (same as `System -> Routerboard` and `Upgrade`)
- Wait firmware installed and reboot 
- After rebooted, send email notification about update completion

## Prerequisites

Email sending reuires valid POP server configuration. You can configure it once using Email Settings of WinBox or WebFig by opening:

`Tools -> Email`

Or use terminal and `/tool email` commands.

## Configuration

### WAN connection

Update process requires reboots after RouterOS and firmware updates. Email notification requires internet connection to send notifications. That's why WAN status check exists in `system-upgrade.rsc` script. The scripts waits when Internet connection established and then continues update. Current version of the script checks PPPoE connection state. Connection name is set in local variable which you need to update with your connection name: 

`:local connection "connection-name";`

If your WAN is not PPPoE, set your type of connection at line `19`:

`/interface pppoe-client monitor $connection`

Instead of `pppoe-client` there could be `ppp-client`, `ovpn-client`, or else. Maybe your "wait for internet connection" logic will be different.

### Notification Email Recepient

Script `system-email.rsc` contains email of updates email recepient. Update it it with your email:

`:local to "notification.email@example.com"`

### Upload Scripts

Add scripts using `System -> Scripts` window. Give them names of script files without extensions:

- system-update
- system-upgrade
- system-email

### Configure Scheduler

In order to run updates periodically, create one scheduler entry using `System -> Scheduler` window. Give it any name, and set `On Event` property to this command:

`/system script run system-update`

Please note that during RouterOS updates the device will be down and rebooted two times, so take this into consideration when configuring scheduler's trigger time. Usual downtime is up to 5 minutes, including wait for PPPoE connections after reboots. Updates happen only when there are new packages available, otherwise the device stays up without interruptions.