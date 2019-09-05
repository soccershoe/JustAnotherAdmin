---
layout: post
title: "What Are PAW's"
date: 2019-12-28
---

**Why Not Your Regular Workstation?**
Since a PAW is a workstation does that mean it is a Tier 2 device (seem my other post on 
[Credential Tiering](Tiers defined below)
?  Because highly privileged accounts will be used in the process of daily management of Tier0, they must be regarded as a Tier 0 device.  In practice in EG, this means accounts such as Domain Admins, username_DA, or highly privileged service accounts, these accounts are limited to log in to Tier0 and blocked from logging into Tier1 or Tier0 devices.  Allowing cross-Tier logins exposes weaknesses that can be exploited to harvest credentials.  This is the basis of Pass the Hash (PtH) attack remediation in that an interactive logon can leave password hashes resident in LSASS memory.  Thanks to publicly available tools a very low skilled hacker can harvest and utilize those hashes regardless of the password length or complexity.  “Run As” also places a hash of your NTLM credential in LSASS memory.  Beyond credentials stored in LSASS memory, vigilance against malware-based keyboard loggers need to be maintained.  Therefore, administrators should not get caught up on where the credential is stored but rather focus on the trustworthiness the entire device. This is called the “Clean Source Principal”.
*Vigilance is required to keep the strict segregation.  It only takes one breach of this rule to be easily exploited by tools such as Bloodhound.

**Okay, but what is a PAW?**
A PAW is the workstation the admin uses to access and administrate the network using privileged credentials. It provides the admin a secure method to perform day-to-day administrative tasks on network devices such as Domain Controllers, member servers, user workstations, networking equipment, and eventually EG cloud admin portals (like Azure and AWS). Because the PAW adheres to the Clean Source Security Principal it prevents the logged on user from freely surfing the Internet, checking email, running applications outside of the allowed, or insecurely accessing network devices that could expose risk to credential theft. It provides the admin everything they need to do their job and nothing more via “Least Privilege Security”.
