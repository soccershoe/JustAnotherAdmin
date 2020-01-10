---
layout: post
title: "Increase Your LDAP Logging"
date: 2020-10-21
---

I want to find out who's connecting to my ldap server and how they are connecting.  I don't see anything in the standard log files.  I don't want to install wireshark on my domain controller either.  Where's the beef?

![Beef](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/wherebeef.jpg)

{{ more }}

This is an easy one.  All it takes is a simple registry update on your DC.  Make that change and you are golden.  No reboots or nothing.  It takes effect immediately.  

Up your NTDS logging by changing the '16 LDAP Interface Events' from 0 to 3 for more detailed information on LDAP requests.  Now go check your 'Directory Services' log.  This can be super helpful for those pesky customers looking to find out why their LDAP calls are taking 15ms instead of 10ms.  

*Warning* Start out with a level 2 and make sure your domain controller load isn't bad before continuing.  Level 2 gives good detail by the way.  

[https://support.microsoft.com/en-us/help/314980/how-to-configure-active-directory-and-lds-diagnostic-event-logging](https://support.microsoft.com/en-us/help/314980/how-to-configure-active-directory-and-lds-diagnostic-event-logging)

Now that I have my logging cranked up, what can I do with it?  Here's what I've used it for:
* Find out who is doing Simple Binds to my domain controllers and kick them to the curb for sending passwords in cleartext over the wire
* SSL issues relating to clients failing to connect to LDAPS

Give it a go.  At the least turn it on and forget about it until you need it some day.  Better to have it in hand than to find you need it later and not have it available.