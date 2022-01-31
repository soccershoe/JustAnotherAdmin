---
layout: post
title: "Cross-Forest Password Reuse"
date: 2020-01-30
---

**What are your users doing with their multitude of accounts?**

Here's what I'm dealing with.  I've got quite a few admins.  And several Windows Forests with trusts, one-way or two.  All those admins have multiple accounts across those forests.  And what do they do?  Use the same passwords in some of their accounts.  What are the repercussions and how do we fix this?

{{ more }}

Admins using the same passwords across trusted forest boundaries....   This definitely happens.  All the time.  Even after people get their hand slapped doing it, or see other people get their hand slapped.  

If you have a malicious actor in your environment, let's say they popped your Domain Admin account in one domain, they are definitely going to try those same credentials across your trusts or wherever else they can try them.  There's no roadblocks for them to continue to move between your domains and to continue to cause havok.  This happens all the time at companies.  It happens when you don't vet the security of a new subsidiary before integrating.  It happens when you have a nice Pen test team and they are poking about.  It happens because the admins have too many accounts in too many forests (please use a password manager) and don't want to manage all those passwors! This is a golden ticket/silver ticket/pass-the-hash/lateral movement opportunity where that malicous actor smiles really big smile (not that you can see them smile because hackers wear ski caps under their hoodies).  

![HackerSmile](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/hackersmile.png)

**_And please set up logging using WEF or other methods_**  You'll want to create roadbumps for the hacker to be able to alert you when things happen.  You can follow my [WEF Logging](https://soccershoe.github.io/JustAnotherAdmin/blog/2019/10/28/WEFLogging) posts as a start.  

## How are you going to detect password hash reuse?

### _Note - everything here I've done in my lab.  This is something I've played with but not made it into a production environment yet.  Please do your own validations._

The idea behind this is based on the same idea from the totally awesome [Have I Been Pwned](https://haveibeenpwned.com/API/v3) site.  The site, without knowing your password and based on a few characters of your hashed password, knows if you have been part of the pwned database.  You can plug into the API and find out!  It is just amazing.

* some nutty math stuff - [https://en.wikipedia.org/wiki/K-anonymity](https://en.wikipedia.org/wiki/K-anonymity)
* some help explaining some of that math stuff at least for me - [https://www.troyhunt.com/introducing-306-million-freely-downloadable-pwned-passwords/](https://www.troyhunt.com/introducing-306-million-freely-downloadable-pwned-passwords/)

Their secret sauce:  Basically, if we compare the first 5 characters of the hashed password, we have something like a 99.99% chance that the password is unique.  

Here's what we're going to do.  Windows stores all it's passwords in a hash (why is this not an issue, see below).  We dump it out using your tool of choice staying in a secured spot, like on the domain controller.  Clean it up so that you have just the first 5 characters of the hashed passwords so you can play with this in an unsecured location.

I've been testing using this tool from [Michael Grafnetter](https://github.com/MichaelGrafnetter).  Please check out his great [DSInternals](https://www.dsinternals.com/en/downloads/) Powershell module.  Specifically, Get-ADReplAccount.  Or, you can use mimikatz, powershell empire, or whatever else allows you to get those hashes.  

Download and Import the Powershell module on your domain controller.

**Here's the code to get those hashes, trim them to 5 characters, and save them off to a file.**

```
$HashList = @()
$AllUsers = Get-ADUser -filter *

foreach ($User in $AllUsers) {
    $Hash = (Get-ADReplAccount -Server <Servername> -ObjectGuid $User.ObjectGUID | Format-Custom -View HashcatNT | Out-String).Trim() -replace ".{27}$"
    $HashList += $Hash
    }

$HashList | Out-File C:\temp\HashOutput.txt
```

For those nice Pen Testers, here's an offline dit version for extracting the hashes.

```
# Save ntds.dit for offline use
C:\>ntdsutil
ntdsutil: activate instance ntds
ntdsutil: ifm
ifm: create full c:\pentest
ifm: quit
ntdsutil: quit

# Offline DB testing
# First, we fetch the so-called Boot Key (aka SysKey)
# that is used to encrypt sensitive data in AD:
#$key = Get-BootKey -SystemHivePath 'C:\IFM\registry\SYSTEM'
$key = Get-BootKey -Online

# We then load the DB and decrypt password hashes of all accounts:
Get-ADDBAccount -All -DBPath 'C:\temp\ifm\Active Directory\ntds.dit' -BootKey $key

# We can also get a single account by specifying its distinguishedName,
# objectGuid, objectSid or sAMAccountName atribute:
Get-ADDBAccount -DistinguishedName 'CN=JaneDoe,CN=Users,DC=domainname,DC=local' -DBPath 'C:\temp\ifm\Active Directory\ntds.dit' -BootKey $key 
(Get-ADDBAccount -DistinguishedName 'CN=JohnDoe,CN=Users,DC=domainname,DC=local' -DBPath 'C:\temp\ifm\Active Directory\ntds.dit' -BootKey $key).NTHash
(Get-ADDBAccount -DistinguishedName 'CN=krbtgt,CN=Users,DC=domainname,DC=local' -DBPath 'C:\temp\ifm\Active Directory\ntds.dit' -BootKey $key).NTHash
```

Do this in each domain or forest you want to check.  You'll have the hashes, only represented by their first 5 characters, and the associated username.  

Take this and compare with the other files from your other domains.  And now you have a yourself a way to check passwords with relative certainty that users aren't re-using their passwords.  

_Please use this with care._  And please ask your Security team if this is something safe and worth doing.  If it is, make it part of your quarterly checks or some automated process.



**Why is this not an issue?**
Technically, yes, I guess this would be an issue.  This would be a super issue if everyone had access to the AD database.  But the server/service is not meant to be accessible by everyone.  It's meant to live in a security bubble where access like that is not granted, but only to highly privileged users.  Salting the entries wouldn't be of help because no untrusted access is granted.  AD doesn't store the password, it just stores the hash.  Then compares the hash to what you typed in when logging on.  It might be an MD4 (LM), or MD5 (NTLM), or AES256_CTS_HMAC_SHA1_96 (Kerberos).  This may have changed with server 2016/2019.  I haven't checked.

**Update 3-25-2020**
This is great!   [Michael Grafnetter](https://github.com/MichaelGrafnetter) has updated his Powershell module to include some of the features of what I tried to accomplish with my scripting here.  He added the IHaveBeenPwnd functionality which is super awesome.  And sounds like he thinks this password re-use scenario is just as important to me.

I haven't yet tested Michael's module yet, so I'm not sure my Powershell musings will still work as written, but you all are smarter than me out there and can figure it out.  Also, my script allows for offline comparison.  If you have disparate networks with disparate admins, you can have them dump out the truncated password hashes and not have files floating around with passwords or hashes directly from your ntds.dit.  Keeps things safe and not all eggs in one basket type scenario.  

Please check out his great [DSInternals](https://www.dsinternals.com/en/downloads/) Powershell module.  