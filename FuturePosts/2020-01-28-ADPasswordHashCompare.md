---
layout: post
title: "Multi-domain AD Password Hash Comparison"
date: 2020-01-28
---

**Users Using the Same Password in Mulitple Domains**

{{ more }}

This is a fun problem for admins, or security guys.  Say you manage multiple domains or forests and users probably have the same samaccountname or some other defining account attribute.  Or maybe it's the SQL team that never has to change passwords or the helpdesk enables users to use the same password.  Best practices should be that those user accounts do not use the same password between these domains/forests.  

How do you as a concerned admin or security pro find out if there are violations of this best practice so you can go and remediate this issue?

There are several third party tools that are expensive or difficult to implement.  Or ones that replace the Windows GINA! ***blech*** Those are no fun.  

Also, say you get your hands on everyone's password or password hash in each domain/forest.  Maybe you went on your domain controller with some tool and dumped it all with Mimikatz.  ***shrug*** Then what are you going to do?  Put all that sensitive data in one location?  ***yuck***  All your keys in one location.  

Here's what I came up with...

![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/PasswordIncorrect.jpg)