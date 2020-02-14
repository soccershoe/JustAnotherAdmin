---
layout: post
title: "Self Service File Shares : Server Setup"
date: 2020-02-14
---

**Self-Service File Server : Server Setup**

{{ more }}

Please see my [first posting overview](https://soccershoe.github.io/JustAnotherAdmin/blog/2020/02/14/SelfServiceFileServer) if you haven't already.

Also, please note that this isn't a step-by-step install.  This is an install for my environment.  Please use this as a framework for getting yourself up and running.  I'm assuming you have some basic knowledge of most of these topics.  And I'm including my scripts as well for helping to make your magic happen.

Ok.  Now the fun part.  Building out the server.

You have your fresh server.  Add all the Roles and Features necessary.  

### Roles and Features ###
1. Roles Installed (add Features as required by the Role)
  1. File and Storage Services
    1. File and iSCSI Services
      1. File Server
      2. BranchCache for Network Files
      3. Data Deduplication
      4. DFS Namespaces
      5. DFS Replication
      6. File Server Resource Manager
  2. Storage Services
2. Features Installed (add additional Features as required by the Feature)
  1. Windows PowerShell
    1. Windows PowerShell 2.0 Engine
  2. Remote Server Administration Tools
    1. Role Administration Tools
    2. AD DS and AD LDS Tools

### DNS Config ###
Give your new service a name.  I named mine 'Depot'.  Like a file depot.  I thought about 'Stacks', but stacks of files is terrible.  I originally just wanted 'Shares', but that DNS name was already taken by some other service.  So Depot it was, and I may be referring to 'Depot' during later writings.  

### Local Server Admins ###
Create a domain service account that we'll use as an administrator on the file server.  I named mine 'filemonitor'.  Add this account as a local admin group.  

### Enable WinRM ###
Run Powershell as Administrator and enable WinRM.  Lifted from [KB555966](https://support.microsoft.com/en-us/help/555966)

1. Write the command prompt : "WinRM quickconfig" and press on the "Enter" button.
2. The following output should appear:
    1. ``` "WinRM is not set up to allow remote access to this machine for management.
The following changes must be made:
 
Set the WinRM service type to delayed auto start.
Start the WinRM service.
Create a WinRM listener on HTTP://* to accept WS-Man requests to any IP on this
machine.
 
Make these changes [y/n]? y" ```
3. After pressing the "y" button, the following output should appear:
    1. ``` "WinRM has been updated for remote management.
 
WinRM service type changed successfully.
WinRM service started.
Created a WinRM listener on HTTP://* to accept WS-Man requests to any IP on this machine." ```

### Disk Config ###
We will be creating two disks, D: and E:.  One drive will be the data drive (D:\) and the other will be the archival drive (E:\).  

1. Prerequisites
  1. **NOTE**   If using SAN storage, you cannot use Windows Storage Pools.  Set up SAN storage as normal D: and E: drives and skip Storage Pools setup below.
  2. For using non-SAN storage, each data drive (D: and E:) is made up of at least two drives and will make two Storage  Pools.  Please continue with the steps below.
2. In Computer Management, Disk Management, Online the drives.
3. In Server Management, go to File and Storage Services. Then Volumes, then Storage Pools.
  1. In Storage Pools, select Tasks, then New Storage Pools
  2. Follow the Wizard
    1. Name the Storage Pool ‘DataSP’.
    2. Select two of the four primordial disks for the Pool (assuming that you are splitting the 4 disks equally between the Data and Archive drives).
  3. Create the second Storage Pool following the Wizard
    1. Name the Storage Pool ‘ArchiveSP’.
    2. Select the remaining disks.
   4. Right click the new ‘DataSP’ Storage Pool and select New Virtual Disk
   5. Follow the Wizard
    1. Select the Storage Pool
    2. Name the Virtual Disk ‘DataVD’
    3. Select ‘Simple’ layout
    4. Select ‘Fixed’ provisioning
    5. Select Maximum Size
   6. The New Volume Wizard will automatically pop up
   7. Follow the Wizard
    1. Select Drive Letter “D”
    2. Volume Label “Data”
    3. Data Dedupe is “General File Server”
   8. Follow the same steps in step d. above to complete the config for the Archive drive.

### Initial Folder Creation ###
Create the following folders: 
* D:\Scripts
* D:\Shares
* D:\StorageReports
* D:\StorageReports\Incident
* D:\StorageReports\Interactive
* D:\StorageReports\Scheduled
* E:\FileExpiration

Create these custom permissions.  The default permissions inherited creates some funky permissions later on.  No need for that CREATE permission to persist.  It makes for some more difficult troubleshooting of permissions for the helpdesk, or yourself.
* D:\Shares
  * Remove Inheritance and copy permissions
  * Remove all Users\Groups except SYSTEM and local Administrators and Domain Admins.  They will all get Full Control.

### Initual Scripts Setup ###
* Use the D:\Scripts folder to store all your scripts.  
* One script needs to live outside the D:\Scripts folder.  Put the MoveFile.ps1 (we'll go over this script later) into the C:\Windows\System32 directory.

### FSRM Setup ###
1. Open the FSRM MMC console
2. Right-click File Services Resource Manager and select ‘Configure Options’
  1. Email Notifications Tab
    1. Default From address
      1. filedepot@domain.com
    2. SMTP server
      1. smtphost.domain.com
    3. Default Administrator email
      1. fileadmin@domain.com
  2. Report Locations Tab
    1. Incident
      1. D:\StorageReports\Incident
    2. Scheduled
      1. D:\StorageReports\Interactive
    3. On-Demand
      1. D:\StorageReports\Scheduled
  3. File Screen Audit Tab
    1. Check the box
  4. Automatic Classification Tab
    1. Check ‘Enable fixed schedule’
    2. Set a schedule for Midnight Weekly on Saturday
  5. Access-Denied Assistance Tab
    1. Click “View assistance request settings”
      1. Check ‘Enable access-denied assistance’
      2. Edit the text in the box to the appropriate message.  Example below.
      3. Click ‘Configure Email Requests
        1. Check ‘enable users to request assistance’
        2. Only check ‘Folder Owner’ and ‘Generate and eventlog entry’.
        3. Edit the email text with:  ‘For general support, contact: helpdesk@domain.com’
3. Creating the File Expiration Task
  1. Run Powershell ISE as Administrator
  2. Edit the ‘Create-FileExpiration.ps1’ to make sure that the –FolderDestination option points to E:\FileExpiration on line 5.
  3. Run the script
  4. Validate that the task has been created in the FSRM MMC console in the File Management Tasks section
4. Edit Quota Templates
  1. Edit the template:  250 MB Extended Limit
      1. Rename it to ‘25GB Extended Limit’
      2. Space limit:  25GB
  2. Edit the template:  200 MB Limit with 50 MB Extension
      1. Rename it to ‘20GB Limit with 5GB Extension’
      2. Space limit:  20GB
      3. Edit “Warning (100%)
        1. Uncheck the send ‘send email to the following administrators’
        2. Select the ‘Command’ tab
          1. Change Command Arguments to:  “quota modify /path:[Quota Path] /sourcetemplate:"25GB Extended Limit"”

### Secure Stored Password ###
I don't know if this is the most secure way to embed a password in the script or the most efficient process to make this work, but it's better than a clear-text password.  
* Run Powershell ISE as administrator
* In the 'Store-SecureCreds.ps1' file (more later on this file), add the password for your domain\filemonitor service account to line 3.  
  * Run the script and save the output.  This output will be use later in the other Powershell Script.
  * Edit the password out of the script and save that file.  No need to store it here.  Make sure you save that password though elsewhere, like your password vault.

### Enable Shadow Copies ###
1. Right click on the Data drive and select “Configure Shadow Copies”.
2. Click on the Settings button
3. Change the Volume to the Archive drive
4. Set Maximum Size to No Limit
5. Change the Schedule to Once a day Snapshots
6. Select the Data drive and click the Enable button
7. Click “yes” to enable Shadow Copies
8. Eg. The D: drive should be storing Snapshots on the E: drive with a daily schedule.

I think that's enough for the server setup.  Next steps for setting up the Script will be in the next posting.  *Woo!*