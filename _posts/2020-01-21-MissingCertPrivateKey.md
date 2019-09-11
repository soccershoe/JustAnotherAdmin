---
layout: post
title: "Missing Certificate Private Key"
date: 2020-01-21
---

**Where's My Certificate Private Key?**

I had just completed a handful of custom certs for a customer.  Their computer certs expired and they needed new ones.  Unfortunately, this was an old system and the certs needed to come from our old SHA1 PKI servers.  No problem.  They aren't retired, just no longer servicing SHA1 certs anymore.  

If you haven't deprecated your SHA1 certificate infrastructure, please try to make this a priority.  It's a hefty security risk.

When the customer imported the .cer files into their MY store, the Private Key was missing.  :O

To fix the issue, I got the certificate thumbprint and ran:  certutil.exe -repairstore my "thumbprint".  And magically after this, the cert Private Key showed that it was associated with the cert in the cert MMC console for the computer.  Weird. but now fixed.

*update*
Just found the Microsoft article to address:  [assign a private key to a new certificate](https://support.microsoft.com/en-us/help/889651/how-to-assign-a-private-key-to-a-new-certificate-after-you-use-the-cer)

