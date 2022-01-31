---
layout: post
title: "Random LDAP Stuff"
date: 2020-01-5
---

**what am I forgetting about LDAP?**

{{ more }}

Here's some random stuff, like definitions and links and the like so that I don't forget it.  Some of this is my wording, and some is copy and paste from rando sources.

**What is LDAP?**
LDAP is an industry standard Protocol that systems use to connect to a directory, such as Active Directory. It facilitates programmatic
access to that directory for tasks such as looking up contact info, usernames or other data stored in the directory database. LDAP is defined
in [RFC4511](https://tools.ietf.org/html/rfc4511). It is a client-server model. The client asks a question and the server replies with an answer.

**LDAP Version History**
* *LDAPv1* – This is the original version of LDAP. It was never codified as a standard. Many libraries still support this version. It had serious
security flaws and should be avoided.
* *LDAPv2* – This version was released as RFC Draft Standard in 1995 and was quickly followed up by LDAPv3 with a published Draft in 1996 to
address various inadequacies. LDAPv2 also had security issues. And unfortunately, as well, LDAPv2 is probably the largest supported
implementation.
* *LDAPv3* – With the RFC publication of LDAPv3, v2 was marked as obsolete and no longer a standard. The benefits to LDAPv3 are the usage of
strong encryption and authentication methods, such as SASL, that are built into the protocol as per the RFC.
Limitations of LDAPv2 are various, but the most affecting limitations are the lack of adherence to documented standards and lack of
supporting modern encryption and authentication like Kerberos or PKI. LDAPv1 and LDAPv2 were officially retired in 2003. As such, LDAPv2
usage should be avoided where possible.

**LDAP Firewall Info**
LDAP connections are made over TCP and UDP on port 389, TCP 636 (LDAP over SSL), and TCP 3268 or 3269 (GC over SSL) for Global Catalog connections. Your internal network communications will probably be allowed to connect to Active Directory using any of these ports where allowed and appropriate. LDAP connections coming from external, such as SaaS applications, should be limited to TCP 636 for LDAPS communication and only allowed from approve IP addresses.

**LDAP Authentication**
LDAP Authentication refers to the LDAP BIND mechanism in the protocol and in the context of your Corporate Active
Directory. There may be better or more appropriate alternative ways to authenticate with Corporate Active Directory, such as ADFS. 

LDAP generally supports Bind types: *Anonymous* (no user/pass), *Unauthenticated* (user but no pass), *User/Pass authenticated* (user and
pass supplied). Anonymous and Unauthenticated methods allow clear text passwords being sent and should be disallowed.

The last Authentication mechanism is SASL. SASL is a framework as defined in [RFC4422](https://tools.ietf.org/html/rfc4422) allows secured authentication between client and
server. Both parties can negotiate which mechanism to use. Mechanisms are GSSAPI, GSS-SPENGO, External, and Digest-MD5.
It is recommended to use Simple Binds using username and password only after starting a secured session (TLS or StartTLS), 
or SASL using GSSAPI with either Kerberos or NTLMv2.  All transmission of the username/password should be secured.
Transmitting passwords should be treated with strictest security in mind. The following Bind methods are listed from strongest to least
strong. Please choose appropriately when connecting to Corporate Active Directory.
* SASL/GSSAPI/Kerberos with session-level encrytion
* SASL/GSSAPI/NTLMv2 with session-level encryption
* SASL/GSSAPI/Kerberos
* SASL/GSSAPI/NTLMv2
* SASL/GSSAPI/NTLM with session-level encryption
* Simple/Usernam&Password with session-level encryption
* SASL/GSSAPI/NTLM
* Simple/Username&Password (cleartext passwords)

**LDAP Encryption**
Any info on encrypting the connection to ensure data integrity. This would include session-level encryption, in other words StartTLS or
LDAPS. The first way, StartTLS encrypts the data after the connection has been made. A LDAP connection is made and then after connection
a command is sent to start TLS and after that the data will be encrypted. All this happens over TCP 389. The second way is to connect to TCP
636 which only supports full session encryption. This is LDAPS.

To use either LDAPS or StartTLS, you will need for your application or server a certificate from a PKI infrastructure. 
The alternative to LDAPS or StartTLS if your application doesn't support it would be to use IPSEC to encrypt your traffic. This is outside the
scope of this post, but a good one for future writing.  

**TLS/SSL Review**
TLS/SSL communications are meant to provide Identification, Privacy, and Integrity. Identification is crucial to validate who you will be
communicating with. Generally for connections to LDAP using LDAPS or StartTLS, you'll be proving our identity with Certificates
from a trusted internal Certificate Authority. Privacy will provide encryption to the data sent between the parties. Integrity provides
mechanisms to make sure that the data between client and server was not tampered with before it reaches the other side.
TLS/SSL connections begin with an exchange between the client and server to negotiate how they will encrypt and decrypt their
communications. It's the SSL handshake. On Windows, Schannel completes this handshake. The handshake is comprised of the Protocol,
Key Exchanges, Ciphers, and Hashing Algorithms.

**Plain text passwords**
Setting up the authentication for the LDAP connection, a 'Simple BIND' and 'SASL PLAIN' can send the user's username and password in 
plaintext. This is obviously not ideal. Active Directory does not prevent these types of connections, but may at a future date. So
the connections utilizing either Simple or SASL PLAIN should be encrypted using TLS, either by using LDAPS or StartTLS.

**Definitions**
* *Global Catalog* - (GC) servers provide a global listing of all objects in the Forest. Global Catalog servers replicate to themselves all objects
from all domains and hence, provide a global listing of objects in the forest. However, to minimize replication traffic and keep the GC's
database small, only selected attributes of each object are replicated.
* *LDAP* - Lightweight Directory Access Protocol (LDAP) is an open, vendor-neutral, industry standard application protocol for accessing and
maintaining directory information services like Active Directory.
* *TLS/SSL* - are cryptographic protocols that provide communications security over a network.
* *StartTLS* – This is a feature added to LDAPv3 that enables negotiation of TLS connection within the LDAP protocol. This LDAP session can
ensure data and authentication confidentiality and encryption using Certificates. Active Directory supports StartTLS
connections. The connection is over TCP 389, which is beneficial for firewalls as this port is usually allowed open.
* *Bind* – When an LDAP session is created, the session is set to anonymous. The Bind will establish the Authentication for the session.
* *SASL* – 'Simple Authentication and Security Layer' is a framework allowing multiple types of authentication, such as GSSAPI, Kerberos,
Digest-MD5, Plain and External used with TLS. Defined in RFC4422.
* *GSSAPI* – GSSAPI authentication (RFC 2743) allows the use of Kerberos TGT or NTLM tokens to be passed for authentication.
* *LDAP Referrals* – LDAP directories may also hold references to other directories, so an attempt to access "ou=department,dc=example,
dc=com" could return a referral  to a server that holds that part of the directory tree.  
* *OpenSSL* – OpenSSL contains an open-source implementation of the SSL and TLS protocols. The core library implements basic 
cryptographic functions and provides various utility functions.
* *Kerberos* – is a computer network authentication protocol that works on the basis of tickets to allow nodes communicating over a nonsecure network to prove their identity to one another in a secure manner. 
* *Cipher Suites* - is a set of algorithms that help secure a network connection that uses Transport Layer Security (TLS) or Secure Socket Layer
(SSL).
* *Digest-MD5* – The (RFC2831) sends the MD5 hash of the password over the network. It's a step better than cleartext passwords, but should
be avoided.
* *Subject Alternative Name (SAN)* –  is an extension to X.509 that allows various values to be associated with a security certificate using a
subjectAltName field.
* *Distinguished Name (DN)* – Every LDAP entry has a DN referencing its location in the directory.  It is written in this specific format (eg."
ou=department,dc=example,dc=com").
* *OpenLDAP* – Open source implementation of LDAP.
* *GSS-SPNEGO* – This (RFC4178) is actually GSSAPI authentication but the client and server negotiate which authentication token they use.
Preference in order negotiated is Kerberos, NTLMv2, NTLM, and LM.

**References**
[https://tools.ietf.org/html/rfc4511](https://tools.ietf.org/html/rfc4511)
[https://technet.microsoft.com/en-us/library/cc961766.aspx](https://technet.microsoft.com/en-us/library/cc961766.aspx)
[https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol](https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol)