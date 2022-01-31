---
layout: post
title: "Credential Tiering"
date: 2020-01-7
---

**Credential Tiering**

{{ more }}

This I lifted from [Microsoft](https://docs.microsoft.com/en-us/windows-server/identity/securing-privileged-access/securing-privileged-access-reference-material) until I get something in my own words published.  This is pretty good though.

 - - - - - - - - 

The purpose of this tier model is to protect identity systems using a set of buffer zones between full control of the Environment (Tier 0) and the high risk workstation assets that attackers frequently compromise.

![Alt Tiering](https://docs.microsoft.com/en-us/windows-server/identity/media/securing-privileged-access-reference-material/paw_rm_fig1.jpg)

The Tier model is composed of three levels and only includes administrative accounts, not standard user accounts:

* **Tier 0** - Direct Control of enterprise identities in the environment. Tier 0 includes accounts, groups, and other assets that have direct or indirect administrative control of the Active Directory forest, domains, or domain controllers, and all the assets in it. The security sensitivity of all Tier 0 assets is equivalent as they are all effectively in control of each other.
* **Tier 1** - Control of enterprise servers and applications. Tier 1 assets include server operating systems, cloud services, and enterprise applications. Tier 1 administrator accounts have administrative control of a significant amount of business value that is hosted on these assets. A common example role is server administrators who maintain these operating systems with the ability to impact all enterprise services.
* **Tier 2** - Control of user workstations and devices. Tier 2 administrator accounts have administrative control of a significant amount of business value that is hosted on user workstations and devices. Examples include Help Desk and computer support administrators because they can impact the integrity of almost any user data.

