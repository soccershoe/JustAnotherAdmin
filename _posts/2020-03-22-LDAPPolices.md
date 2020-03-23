---
layout: post
title: "LDAP Policies and Performance"
date: 2019-10-21
---

:scream:  "Uhg...  My developers keep saying that their LDAP connections on occasion time out.  Why do they keep bugging me?  I can't reproduce their issue with ldp.exe.  Everything looks healthy."  OR "Hey random developer, why are you maxing out my CPU with your poorly formed LDAP query running every 5 milliseconds!?"

{{ more }}

My day to day is managing a bunch of domain controllers all over the globe.  This Windows domain started as an NT4 domain, upgraded to 2000, then 2003, 2008, and currently 2012 (I know...  it's 2020... we're working on it... doesn't matter for this post).  You know what all those upgrades bring with it?  Security holes, empty settings, and defaults that never thought they'd see the day past 2005.  Great.  

That brings me to LDAP Policies.  LDAP Polices define the limits that LDAP clients have to abide by for their queries.  The limits keep LDAP functioning, even when a bazillion people all do an ldap search at the same time for a wildcard to the root of your directory.  That kind of badly formed query will bring your CPU to its knees.  

Here is a great doc for the settings defined by MS for each server version: hhttps://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/3f0137a1-63df-400c-bf97-e1040f055a99?redirectedfrom=MSDN

As you can see, there are different policy settings that have been added with each version.  Here are the ones I have actual values for other than "0": MaxActiveQueries, InitRecvTimeout, MaxConnections, MaxConnIdleTime, MaxDatagramRecv, MaxNotificationPerConn, MaxPoolThreads, MaxReceiveBuffer, MaxPageSize, MaxQueryDuration, MaxResultSetSize, MaxTempTableSize.

These tell me that they haven't been changed since this was a Windows 2000 domain.  The settings for something like "ThreadMemoryLimit" don't have a value or set to "0".  

So, when you upgrade your domains and increase your Domain Functional Level and Forest Functional Level, you are bringing forward the meager settings that MS originally set (unless you changed them already).  Microsoft also sets the new policies to "0".  Nowhere I could find defines what "0" is, but I assume that it would be the default for the new OS.  I asked MS and they stated they'd need to do a code review to verify.  I'd say it's pretty safe to say that it's the default for the server version.  It just doesn't help and sows confusion that they don't state what "0" means.  Does it mean zero, or default, or unlimited for it's value is my question.

What can you do?  Work with your clients first off to scope their queries.  Monitor your CPU usage.  LSASS.exe will go crazy.  Make sure you are monitoring for EventID 2898 and 2899.  Those will be logged in your Directory Services eventlog after you change the logging level, which I hope you already have.  There is great data there.

You can use Performance Monitor to grab which LDAP queries are the most CPU expensive.  There is a built-in 'Data Collector Set' called 'Active Directory Diagnostics' that will give you data on the previous 5 minutes of activity and include the LDAP queries that pegged your CPU.  Five minutes isn't very long.  That may not help you.  You can try building your own 'Data Collector Set' that includes the LDAP queries, but danged if that doesn't collect GB's per minute of data in that .etl file.  That isn't helpful either.  I've tried playing around using the GUI, but there's probably some enterprising person out there on the internets with a good way to do this.  

You could also try capturing network data with Wireshark or Netmon or NetSH (see my post on NetSH captures here: https://soccershoe.github.io/JustAnotherAdmin/blog/2019/09/21/UsingNetSH).  There are limitations here as well since any LDAPS traffic is encrypted.  And hopefully you aren't using LDAP on TCP 389.  That'll be all your LDAP calls with username and passwords in cleartext (not a good thing).

Here's my previous post on increasing your logging: https://soccershoe.github.io/JustAnotherAdmin/blog/2019/10/21/IncreaseYourLDAPLogging

And finally, what if I want to change my policies?  A couple of my domain controllers are pretty much solely use just servicing LDAP.  Developers are crazy nuts for using LDAP for everything.  I guess it's just one of those defaults that everyone and every app has built in.  Services like Okta and Ping that use OpenID or Microsoft ADFS take more work or knowledge to implement.  I guess the bar is lower for implementing LDAP.  Unfortunate though that security and performance is also lower for LDAP.  But whatever.  I'll continue that battle outside this post.

Back to modifying LDAP Policies...

Using NTDSUTIL.exe to modify the policy is good.  The settings don't need a reboot to apply.  One caveat to using NTDSUTIL.exe is that it only displays the "Default Query Policy".  You can set multiple query policies based on Site or Domain Controller.  Please check your Query Policies before just applying using NTDSUTIL.exe.  You might be upending what someone else has done before.

You can use ADSIEDIT to view your Query Policies.  Connect to your Configuration Partition, then you can browse to: "CN=Default Query Policy,CN=Query-Policies,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=yourdomain,DC=com".

Another something you might notice if you upgraded your domains from previous versions is that the results from NTDSUTIL.exe don't exactly match what's in the list for 'lDAPADminLimits'.  To be exact, the values in NTDSUTIL.exe that are showing "0" don't show up in ADSIEDIT.  NTDSUTIL is just giving a value of "0" for items that aren't in the Query Policy.  Just sowing the seeds of confusion from MS.  

If you don't have any extra Query Policies and would like to use NTDSUTIL.exe to edit your LDAP policies, go for it.  Directions from MS can be found here: https://support.microsoft.com/en-us/help/315071/how-to-view-and-set-ldap-policy-in-active-directory-by-using-ntdsutil.

To summarize viewing the ldap policy values:  From an elevated admin cmd.exe prompt type - ```ntdsutil "ldap pol" conn "con to server <servername>" q "show values"```

To summarize setting a ldap policy value:  From an elevated admin cmd.exe prompt type - 
```ntdsutil "ldap pol" conn "con to server <servername>" q
ldap policy: set MaxPageSize to 2000
ldap policy: Commit Changes```

You can also use ldif files to change the policy.  I'll let you figure out how to do that one.  Not my favorite way to edit ldap, and at least for me would be the most error prone.  

Or you can use ADSIEDIT to change the 'Default Query Policy'.  Just update the 'lDAPAdminLimits' field.  

I'm not sure which is the recommended way from Microsoft to change the policies, though everything I can find from MS would be to use NTDSUTIL.exe.  

![alt spidey](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/spider-man-shrugs.jpg)

...huh... this post turned out longer than I was expecting...