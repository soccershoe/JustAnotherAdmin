---
layout: post
title: "Updating Powershell Install-Module"
date: 2020-06-25
---

**Updating Powershell Install-Module**

{{ more }}

I've had to look this up like five times now.  :roll_eyes:  Saving this here for me.

Problem:

Install-Module - unable to resolve package source 'https //www.powershellgallery.com/api/v2/'

If you try to install but get the error message 'unable to resolve package source ’https://www.powershellgallery.com/api/v2/’' then try:

`[Net.ServicePointManager]::SecurityProtocol = "tls12"`

Then restart the Powershell console.

Then you should be able to update PowershellGet.

`Install-Module –Name PowerShellGet –Force`

Restart your console once more and you should be able to install anything you want at this point. Like `Install-Module -Name RDWebClientManagement`.

And if that doesn't do it, you probably will need to enforce StrongCryptography for each 32 adn 64 bit versions of .net.

`Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord`

`Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto'  -Value '1' -Type DWord`

Restart once more.  See if that does it for you.

![Forgetting](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/forgetting.png)