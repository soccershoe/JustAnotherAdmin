---
layout: post
title: "Changing Your DSRM Password(s)"
date: 2019-10-01
---

**Using Unique DSRM Passwords**

{{ more }}

Your domain controllers have a shared user database in Active Directory.  So you only have to worry about your domain admin account and protecting that account.  _Not really_

Each of your domain controllers also have a local account database.  This is where the Directory Services Recovery Mode (DSRM) account lives.  It's important that this account also be protected with the same diligence as your domain admin account.  This account isn't sync'ed between domain controllers. Each DSRM account is unique to that domain controller.  This is your break glass account in case all hell breaks loose or you need to do some serious offline AD maintenance.  At this point, if you need to use that account, you may be sweating bullets.  

![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/sweating.jpg)

Here's how to change your DSRM password
1. Start up an administrative command prompt.
2. type in `ntdsutil`
3. type `set dsrm password`
4. type `reset password on server myservername`
  * you can type in `reset password on server null` to change the password on the local server
5. enter your new password, twice, when prompted
6. type `q` and enter twice to quit
7. save off your new password in your secured password database
8. enjoy your new level of security

[![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/dsrm.png "All Secured Here Sir!")](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/dsrm.png)

In the past I have seen articles on how to syncronize the account password using a domain account and GPO.  I'm not sure if I could really endorse this method, even if you have your [Credential Tiering](https://soccershoe.github.io/JustAnotherAdmin/blog/2020/01/07/CredentialTiering) and [AGPM](https://docs.microsoft.com/en-us/microsoft-desktop-optimization-pack/agpm/) set up for your environment.  This password is just as, or even more important, than the domain administrator account.  Don't make it easier for offline cracking if your 'server room' just happens to be under Chad's desk or in Chad's closet.  Don't be Chad.  Your DSRM password should be unique for each domain controller and stored securely in your physical or virtual password vault.  

[Sync DSRM Password](https://blogs.technet.microsoft.com/askds/2009/03/11/ds-restore-mode-password-maintenance/)

The famous [Ned Pyle](https://twitter.com/nerdpyle) did make a good case in the article for actually doing this method quite a while ago.  If you need to manage a bazillion domain controllers, it becomes a huge hastle.  In my day job, I have over 100 of these guys floating around.  It's pretty static and new DC's aren't popping up every few minutes.  But if you do actually go the Ned route, please make sure you secure your environment using credential tiering, credential hygene, and logging/alerting.  

I don't have any good tips otherwise.  It should be a onetime setup when you promote your domain controller.  Make it a habit for putting the password in your password database at that time.  Don't forget it.

![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/dontforget.jpg)

