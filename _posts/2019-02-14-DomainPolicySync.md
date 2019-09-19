---
layout: post
title: "Default Domain Policy & Local Policy Sync"
date: 2019-02-14
---

**The Times When the Default Domain Policy and Local Security Policy Sync**

I didn't know this.  But now it makes sense to me.  There are several password related settings that are synced between domain controllers, but these settings are in the Local Security Policy.  These password settings are synced as stated from Microsoft so "that the members of the domain have a consistent experience regardless of which domain controller they use to log on".  

*Example_*  Say you open up the Local Security Policy on a domain controller in your domain.  Then go ahead and edit a password policy setting like the account lockout time or password length.  The setting will update in the Local Security Policy on all the other domain controllers in your domain.  The Local Security Policy isn't so "local" for these password settings.  On top of that, if you are auditing who's writing to your GPO's (you should be doing that or using AGPM), you'll see that the "Default Domain Policy" is getting updated as well!  Whoa!

![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/whaa?.jpg)

The way I came across this was through a security project.  To increase security, I blocked GPO inheritance on the 'Domain Controllers' OU.  Who does that right??  There are some security implications to allowing GPO settings to flow down from the root of the domain.  You don't want the same GPO linked to the domain root and the 'Domain Controllers' OU at the same time (maybe another post on another day).  GPO's can be a useful tool for bad actors to remain in your environment if you aren't looking.  Anyways... If your password settings in your 'Default Domain Policy' aren't applied to your domain controller, the settings may be different (if you changed the MS defaults).  When you go and try to update the password policy in the GPO it's not going to work and will show inconsistent behavior.  I ended up confused for a while and banging my head on things.

![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/whodoesthat.jpg)

I really couldn't find any good Microsoft articles on this or guidance on blocking inheritance on the 'Domain Controllers' OU.  These links are the best I could find.
<https://support.microsoft.com/en-ca/help/259576/group-policy-application-rules-for-domain-controllers>
<https://sdmsoftware.com/group-policy-blog/gp-troubleshooting/ghosts-in-the-gpo-machine-local-security-policy-changes-on-dcs/>
