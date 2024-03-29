---
layout: post
title: "Windows Defender Manual Definition Updates"
date: 2019-10-07
---

**Updating Defender Manually**

{{ more }}

Since I'm doing this infrequently, but enough to keep forgetting the link, I'll post this for myself to remember.

[https://www.microsoft.com/en-us/wdsi/definitions/](https://www.microsoft.com/en-us/wdsi/definitions/)

![Alt Defender](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/dontremember.jpg)

Download appropriate file and run the executable to update Defender.  There will be no interactive window.  This may be helpful when you don't have access to the internet such as unplugging a suspected virus/malware infected machine.  In my most frequent case, we use [**PAW's**](https://docs.microsoft.com/en-us/windows-server/identity/securing-privileged-access/privileged-access-workstations/) that don't have access to the internet other than connecting to the work VPN.  Work is usually providing definition updates via WSUS.  If the PAW hasn't been turned on in a while, the VPN won't connect if Defender hasn't updated within a certain time period.  The VPN software will validate you have current DAT's before letting you in.

![Alt Defender](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/Windows-Defender.png)