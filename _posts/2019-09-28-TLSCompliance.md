---
layout: post
title: "TLS Security and Compliance"
date: 2019-09-28
---

## TLS Security and Compliance

I'm a bit late to this party (POODLE in 2014, PCI DSS 3.1 in 2016) but I thought I'd share some previous info I had on making sure your servers were TLS compliant.  Maybe you are concerned for security or checking the box for PCI compliance.  Hopefully this will help. The information below is taylored to my environments, but use this in any way helpful.

{{ more }}

## Generally Why

There are an infinite amount of character permutations in your data.  There is a finite number of SHA1 hashes.  The SHA1 hash is supposed to be a random hashed jumble of characters representing your data.  But with the finite number of hashes, eventually you'll come across hash collisions.  From those collisions, a determined adversary could potentially use this against you to spoof your certificate authority's authenticty and sniff your traffic.  I'll let other smarter folks detail how all that works.  I'm just working to not be caught on the short end of the compliance stick.


## Am I Compliant?

Two things need to be tested to make sure you are compliant.  The first is the OS.  Things like RDP and WinRMS use SSL to encrypt using protocols not allowed.  Second is your application.  IIS, Apache, Java or any other application that uses SSL to encrypt traffic needs to be remediated.  This includes traffic not on traditional secured traffic network ports.  If you are solely looking for PCI compliance, each environment is unique in scope.  Please adjust your expections appropriately to your environment.  


Here are some tools I've used to test if your stuff is compliant.  
* [My Powershell Scripts)](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/files/MultiServer.zip)
* [Nmap (Zenmap)](https://nmap.org/)
* [IISCrypto by Nartac](https://www.nartac.com/Products/IISCrypto/)
* [TestSSLServer4.exe by SSLLabs (might be retired now)](https://www.ssllabs.com/)


## Am I Affected by Other Services Becoming Compliant?

Even if you don't have servers or applications to fix, it's very possible that you may be affected by another service that will be changing to compliance.  The two big protocols affected is if your service consumes LDAPS or HTTPS.
For example, if your service uses LDAPS to authenticate, please test against an endpoint providing a SHA2 certificate to validate that you can still do LDAPS calls while enforcing TLS 1.1 or 1.2.  

One troubling example I found was a developer working in Java for the Oracle team.  They had a tool they wrote that restricted ciphers to only use RC4 ciphers.  RC4 is not supported and their application will no longer function.  They had copied a configuration that was written probably back in 1997 and the page hadn't been updated since then even though the Oracle/Java tool had been updated to support modern methods.

![Alt Facepalm](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/ComputerFacepalm.jpg)

## Testing Your Compliance

# Testing your OS
**Powershell**

Run the Get-TLS.ps1 script on your server to test local TLS OS compliance.  Expected results should look like this:
​​​
[![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/GoodCiphersSmall.jpg "Looks good here")](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/GoodCiphers.jpg)
[![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/GoodProtocolsSmall.jpg "Also good here")](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/GoodProtocols.jpg)


If your OS needs remediation, it would look like this:

[![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/ForRemediationSmall.jpg "Looks good here")](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/ForRemediation.jpg)


**IISCrypto by Nartac**

No installation necessary.  Unpack and run.  Expected results should look like this:

[![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/IISCryptoGoodSmall.jpg "Looks good here")](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/IISCryptoGood.jpg)

Remediation required looks like this:

[![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/IISCryptoRemediateSmall.jpg "Looks good here")](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/IISCryptoRemediate.jpg)


# Testing your Application

**Nmap (Zenmap)**

If you can, install Nmap or Zenmap.  Zenmap is Nmap with a Windows GUI.  Nmap can scan locally or remotely the ports used for your application.
Example Command:  nmap -sV -p 636 --script ssl-enum-ciphers server.fqdn.com
     This example scans the domain controller remotely on TCP 636, the port for LDAPS.  The results of the remote scan should produce ONLY the following under 'ssl-enum-ciphers'.

[![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/NmapCiphersSmall.jpg "Looks good here")](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/NmapCiphers.jpg)

An application that needs remediation will show results for 'SSLv3' under the cipher section or these 'warnings':  'Broken cipher RC4 is deprecated by RFC 7465' or 'Ciphersuite uses MD5 for message integrity​'.

**TestSSLServer4**

This is an executable run from the command line or Powershell.  It requires .NET 2.0 or 4.0.  It may not be compatible with your server.  
Example Command:  .\TestSSLServer4.exe -all server.fqdn.com 636
      This example scans the domain controller remotely on TCP 636, the port for LDAPS.  The results of the remote scan should produce ONLY the following.  If SSLv2 or SSLv3, for example, are not reported, then it is not supported.

[![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/TestSSLServerGoodSmall.jpg "Looks good here")](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/TestSSLServerGood.jpg)

An application that needs remediation will show results for 'SSLv3' under the cipher section or these 'warnings':  'Server supports RC4' or 'Server supports SSL 3.0​'.
​
[![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/TestSSLServerRemediationSmall.jpg "Looks good here")](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/tls/TestSSLServerRemediation.jpg)


## How Can I Be Compliant?

# Remediating your OS
  * The easiest way for Windows clients is to run the remedation script, 'Set-TLS.ps1'.
  * IISCrypto is also an acceptible solution.  
  * CentOS is required to be 6.9.  The only solution is to upgrade to this version to support TLS 1.1 or 1.2 by default.

# Remediating your Application
  * .NET requires 4.5+.
  * IIS requires 7.5+.
  * Linux application remedation is mostly limited in scope to OpenSSL implementations.  https://testssl.sh/ will be able to help list where remedation is needed.  
  * Upgrade OpenSSL to a minimum version of 1.0.1-stable for TLS 1.2 support.  Further application specific settings may be required.​
  * OpenJDK or Oracle JavaSDK need to be at least 1.7 to support TLS 1.2.  And then must be enabled in the config.  Both apps 1.8 is supported TLS 1.2 as default.  Further application specific settings may be required.​
  * PHP version 5.3 or later is required for TLS 1.2.  Further application specific settings may be required.
  * Python version 1.19.1 is required for TLS 1.2​.  Further application specific settings may be required.


## Other Useful Links
 * [NIST technical mumbo jumbo](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-52r1.pdf)
 * [A good explanation](https://www.securitymetrics.com/blog/problem-sha-1-updating-your-security-certificate)
 * [2017 Microsoft Advisory](https://support.microsoft.com/en-us/help/4010323/title)
