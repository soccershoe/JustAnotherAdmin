---
layout: post
title: "Which Cert To Use"
date: 2019-10-21
---

**Domain Controllers with Multiple Certificates Setup**

{{ more }}

I set up my environment with domain controllers that have multiple certificates.  The first certificate is in the computer MY store.  This certificate is set to renew on a regular basis using our windows PKI environment.  I have the permissions on the Certificate Template to autoenroll.  

The second certificate is in the NTDS certificate store.  This cert is used for doing SSL encryption for connections to services like LDAPS (TCP 636) and Secure Global Catalog (TCP 3269).  

Why I set this up using two different certificate stores was to separate the computer certificate to be hands off.  Computer certs would autoenroll without affecting just that small handful of 3 or 4 domain controllers being load balanced for LDAPS requests.  The NTDS certificate can have multiple SAN's if you are giving users links like 'ldap.domain.local' or using a load balancer to maybe regionalize ldap requests.  

If you put your certificate for LDAPS into the NTDS store, it will be the selected certificate for those requests hitting the ADDS service.  Any other requests coming in for the Computer Name will use the certificate in the computer MY store.  

### How do I add the certificate to the Store

I'm not going to list steps getting a certificate from your CA.  Hopefully you already have that taken care of.  Maybe in a future post I'll add one for how to set up and get certificates from your own CA.  There are [lots](https://www.altaro.com/hyper-v/request-ssl-windows-certificate-server/) of [good](https://blogs.msdn.microsoft.com/tysonpaul/2016/05/24/certificate-request-from-standalone-ca-certificate-authority-for-operations-manager-scom-2012r2/) [articles](https://www.leeejeffries.com/request-an-ssl-certificate-from-a-windows-ca-without-web-enrolment/) about it.  

1. You have your PFX, CER, or whatever file you got from your CA which includes the private key.  **Check**.
2. You open your Computer Certificate Manager MMC Snapin.  Run certlm.msc.  **Check**.
  * By the way.  This is to import the certificate into the Computer MY store.
3. So, if you skipped step 2 because you wanted to import your cert into the Service My store, then proceed here.  **Check**.
  * Open the MMC.exe console.  Add the Certificates snapin, and in the subsequent pop-up, select 'Service' instead.  Select the ADDS service if you are wanting to have a LDAPS cert used.  Import to the Service MY store.  **Check**.
4. Double check that the certificate you imported has the private key.
5. And if your PFX import added extra trusted root chain certificates, move those to the Intermediate or Root trusted Stores where appropriate.  

This seems pretty straightforward to add certificates, so I'll refer you to the above/below helpful links on certificate MMC's.  


Here's some excellent detail on how it Windows select certificates.
https://www.torivar.com/2016/04/08/which-certificate-is-my-domain-controller-using-for-ldaps/

Additonal information on logging and troubleshooting AD/PKI certificate issues.
https://blogs.msdn.microsoft.com/benjaminperkins/2013/09/30/enable-capi2-event-logging-to-troubleshoot-pki-and-ssl-certificate-issues/
