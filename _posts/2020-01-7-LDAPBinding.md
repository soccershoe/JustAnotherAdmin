---
layout: post
title: "LDAP Binding"
date: 2020-01-8
---

**What's the deal with Anonymous Binds?**

{{ more }}

Have you ever opened up ldp.exe, connected to your ldap server, and then tried a Simple Bind with some random user?  WTH??!!  How is that successful?!

![Alt LdapAnon](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/LdapAnon.png)

Why is that even a thing?  Microsoft has since Windows 2000 allowed anonymous binds by default.  This is not the case with other Ldap providers like OpenLdap.  That's so strange.  The anonymous user has no permission in Active Directory to do anything, which is good (unless you really messed around with permissions! don't do that).  Though there is no concern with AD, there is concern with lazy developers who use Ldap for authentication.  A dev application could give false access to that app based on anonymous access.  Imagine logging into an app with just a username and null password.  No bueno.  Single factor auth.  

Oh, sweet, would you look at that....  The anonymous bind is allowed in the ldap [Alt RFC4511](https://tools.ietf.org/html/rfc4511)

Microsoft has made an update to Windows Server 2019 allowing you to disable anonymous ldap access, but it's not disabled by default.  Again, why??

Please use authentication when connecting to LDAP.  TLS is great if you have a PKI environment.  Connecting to LDAPS is probably the best and most supported way.  

Ooh... That reminds me.  Microsoft is releasing a patch in March of 2020 which changes the default settings in Windows.  This might catch a lot of organizations by surprise.  It updates all windows OS's to use Signing by default.  This makes it much harder to send your LDAP credentials in clear text over the wire.  Simple Binds without some sort of mechanism to hide your credentials will now fail.  This goes for applications and java apps and a bazillion service accounts you probably have in your organization.  Please see my next post on this speedbump of IT.  

