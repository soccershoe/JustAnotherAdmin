---
layout: post
title: "Which Cert To Use"
date: 2019-10-21
---


I set up my environment with domain controllers that have multiple certificates.  The first certificate is in the computer MY store.  This certificate is set to renew on a regular basis using our windows PKI environment.  I have the permissions on the Certificate Template to autoenroll.  

The second certificate is in the NTDS certificate store.  This cert is used for doing SSL encryption for connections to services like LDAPS (TCP 636) and Secure Global Catalog (TCP 3269).  

Why I set this up using two differen certificate stores was to separate the computer certificate to be hands off.  Computer certs would autoenroll without affecting just that small handful of 3 or 4 domain controllers being load balanced for LDAPS requests.  The NTDS certificate can have multiple SAN's if you are giving users links like 'ldap.domain.local' or using a load balancer to maybe regionalize ldap requests.  

If you put your certificate for LDAPS into the NTDS store, it will be the selected certificate for those requests hitting the ADDS service.  Any other requests coming in for the Computer Name will use the certificate in the computer MY store.  

Here's some excellent detail on how it Windows select certificates.
https://www.torivar.com/2016/04/08/which-certificate-is-my-domain-controller-using-for-ldaps/

Additonal information on logging and troubleshooting AD/PKI certificate issues.
https://blogs.msdn.microsoft.com/benjaminperkins/2013/09/30/enable-capi2-event-logging-to-troubleshoot-pki-and-ssl-certificate-issues/
