---
layout: post
title: "What Are PAW's"
date: 2019-12-28
---

**Why Not Your Regular Workstation?**

Since a PAW is a workstation does that mean it is a Tier 2 device (seem my other post on [Credential Tiering](https://soccershoe.github.io/JustAnotherAdmin/blog/2020/01/07/CredentialTiering)?  Because highly privileged accounts will be used in the workflows for the daily management of Tier0 servers and services, they must be regarded as a Tier 0 device.  In practice where I work, this means accounts such as Domain Admins or other highly privileged service accounts, the use of these accounts are limited to interactive log in to Tier0 only and are blocked from logging into Tier1 or Tier2 devices.  

Allowing cross-Tier logins exposes weaknesses that can be exploited to harvest credentials.  This is the basis of Pass the Hash (PtH) attack remediation in that an interactive logon can leave password hashes resident in LSASS memory.  Thanks to publicly available tools a very low skilled hacker can harvest and utilize those hashes regardless of the password length or complexity.  “Run As” also places a hash of your NTLM credential in LSASS memory.  Beyond credentials stored in LSASS memory, vigilance against malware-based keyboard loggers need to be maintained.  Therefore, administrators should not get caught up on where the credential is stored but rather focus on the trustworthiness the entire device. This is called the [Clean Source Principal](https://docs.microsoft.com/en-us/windows-server/identity/securing-privileged-access/securing-privileged-access-reference-material).
*It absolutely required to keep the strict segregation.  It only takes one breach of this rule to be easily exploited by tools such as Bloodhound.

Lifted this image from ![Alt Image](https://docs.microsoft.com/en-us/windows-server/identity/media/privileged-access-workstations/pawfig2.jpg)

**Okay, but what is a PAW?**

A PAW is the workstation the admin uses to access and administer the network using privileged credentials. It provides the admin a secure method to perform day-to-day administrative tasks on Tier0 network devices such as Domain Controllers and cloud admin portals (like Azure and AWS if you are using them with services such as AzureAD or hosting domain controllers) while restricting access to member servers and user workstations.  

Daily user tasks such as email or web browsing will use a Tier2 classified workstation. Because the PAW adheres to the Clean Source Security Principal and is limited in functionality and internet connectivity it prevents the logged on user from freely surfing the Internet, checking email, running applications outside of those allowed for a Tier0 context, or insecurely accessing network devices that could expose risk to credential theft. It provides the admin everything they need to do their job and nothing more via “Least Privilege Security”.

Lifted this image from ![Alt OtherImage](https://msdnshared.blob.core.windows.net/media/2017/10/PAW-Overview.jpg)