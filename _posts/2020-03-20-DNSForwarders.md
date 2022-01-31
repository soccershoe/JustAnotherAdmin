---
layout: post
title: "Multiple DNS Forwarders"
date: 2020-03-03
---

**Multiple DNS Forwarders**  What happens if you have multiple DNS fowarders in your DNS Server configuration?

{{ more }}

Another quick post so that I can remember this tidbit in the future.  

Here's the setup:  You have a domain controller and set it to forward upstream to central DNS servers.  You uncheck root hints and put a couple IP's in for the Forwarders.  

Here's the question:  How does Windows know which IP to send those forwarding queries too?  And what if one of them goes down?

I didn't really look this up before because I assumed too much.  It just worked, why chase it down?

Microsoft does have the answer:  [Dynamic DNS Fowarders](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/dn305898(v=ws.11)?#dynamic-dns-forwarders)

The DNS Server picks the one with the fastest response time and dynamically reorders the list.  This can be disabled by setting this DWORD to 0.  ```HKLM\System\CurrentControlSet\Services\DNS\Parameters\EnableForwarderReordering```

This will take care of you if one of your Forwarding addresses is unavailable.  It'll just send all the queries to the one that is responding.  

How often does the reordering happen?  I couldn't find out with my searching.  I'm going to say that it's black box magic at this point and do some more assuming where there is some sort of algorithm moving things around with each query.  

But what about the scenario where you have a zone available on one forwarder, but not the other?  Well, your clients will get mixed results.  Assuming both forwarding addresses are available, whenever the dns query hits the forwarder that doesn't have the zone available, the query will provide the client with the result that the zone doesn't exist.  

That's it for today.
Laters!

![Alt Cookie](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/cookiemonster.gif)