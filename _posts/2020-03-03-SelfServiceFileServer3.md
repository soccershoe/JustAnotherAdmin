---
layout: post
title: "Self Service File Shares : Scripts Setup"
date: 2020-03-03
---

**Self-Service File Server : Scripts Setup**  The scripting is the fun part!  Let's make it happen!

{{ more }}

Please see my [first posting overview](https://soccershoe.github.io/JustAnotherAdmin/blog/2020/02/14/SelfServiceFileServer) if you haven't already.
And then my [second post about server setup.](https://soccershoe.github.io/JustAnotherAdmin/blog/2020/02/14/SelfServiceFileServer2)

_fyi_ ::  Before you get all the way through this, I do use a third party tool to facilitate adding users to groups.  But that can be automated away using native powershell.  GroupID has a couple of nice features going for it though.  GroupID by [Imanami](https://www.imanami.com/)

***Prerequisites***
* Powershell v4 minimum
* Imanami GroupID Powershell Module
* Custom scripts I've included [here](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/files/Self-ServiceFileServer.zip)

_also fyi_ These scripts and steps are not a copy/paste to your setup.  You'll need to go in and modify for your understanding and your environment.  This is more of a framework for a deployment in your environment.  Plus the script that creates the share needs some work!  

![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/needswork3.jpg)

### Script Descriptions ###
1. Create-ExpirationTask.ps1 - This script creates the file expiration task in FSRM to enable the automated migration of files to the Archive drive.  This is a script because there is an option only available in the command line and not in the GUI.
2. Create-FileShareV2.ps1 - This is the main script that creates the file share and emails the end user.  
3. Modify-LastAccessTime.ps1 - This is a test script to test the functionality of the FSRM Archive task.  The script modifies the LastAccessTime of the files specified so that the FSRM Archive task automatically moves the files the next time the FSRM task runs.
4. MoveFile.ps1 - This is the script called by the FSRM task created by Creat-ExpiratoinTask.ps1.  It does the actual move for the files from the source location to the Archive location.  It is placed in the C:\windows\system32 folder.
5. Store-SecureCreds.ps1 - This file creates the password hash used to store the password securely in the Create-FileShareV2.ps1 file for the domain service account doing the actual work.  

Other things to note in my scripts (besides the amaturity. _heh_ ).....  They aren't optimized for use with variables for domain, servernames, etc.. You'll have to go through the script and test lines for your environment.  Man!  There sure are a lot of _fyi's_ in this whole thing.  

### Step One ###
Install GroupID.  I won't go over this but a minimal install of just the Powershell module is needed.  

### Step One point Five ###
Create a C:\Scripts folder and place all your scripts there.  

### Step Two ###
Verify you're using Powershell v4 minimum:  `$psversiontable.psversion`

### Step Two point Five ###
Create a service account in your domain that'll do all the script work in the background.

### Step Three ###
Now, this may not be the most secure way to do this.  Do what's best for your environment or how you best know to use passwords securely in a script.  

Use the Store-SecureCreds.ps1 to create the hash of your service account password.  Use the hash and place it in the 'Create-FileShareV2.ps1' script (line 20 for my example script). 

