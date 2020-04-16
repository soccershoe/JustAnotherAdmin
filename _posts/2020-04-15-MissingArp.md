---
layout: post
title: "Missing Gateway in ARP Cache"
date: 2020-04-15
---

**The Default Gateway address is missing from my ARP cache**

I'm not sure how this happened or why.  I have yet to dig into that rabbit hole.  I had a domain controller just stop working.  I couldn't ping it or RDP to it.  It seemed to happen post-reboot or post-patching.  

{{ more }}

The funny thing was, I could ping and RDP and create other general network traffic from the same network segment.  That was a clue.  I double checked and found that I couldn't ping the gateway.  Another clue.  

Checked the ARP cache.  ```arp -a```

Missing Default Gateway.  

![wtf](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/wtf.jpg)

This is like 30 year old networking RFC/IEEE/Old stuff.  It should just work.  <sarcasm> Like ethernet 100 auto-switching and ldap! </sarcasm>

I resolved it by adding in the ARP entry as static.  No amount of rebooting or restarting services made that entry dynamically appear.  I used the MAC address from the other working server to make it work.  

```arp -s 192.168.0.5 00-00-12-00-00-ff```

Well shoot.  That didn't work.  I guess there is a limitation on creating static arp entries for the Default Gateway.  Windows won't let you do it.  Now what?

You remove the default gateway from the NIC IP properties.  Done.

Now I can create the static arp entry for the default gateway.  Done.

Now I'll put back the default gateway in the IP properties.  Done. 

Works again.  Now reboot.  FFFfffffff......

Well that stinks.

Forgot that little bit about the arp command static entries don't persist through a reboot.  I haven't come across this issue ever.  I'm glad my brain held on to that little fact from 20 years ago.  

So to really make it static through reboots, Microsoft has a Powershell command to make it go.  

First get the interface:  ```Get-NetIPInterface```

Note the ifIndex number of your NIC.  

Next is to show what is in your arp cache:  ```Get-NetNeighbor -InterfaceIndex 22```

And finally to apply the static entry:  ```Set-NetNeighbor -InterfaceIndex 12 -IPAddress "192.168.0.5" -LinkLayerAddress "00-00-12-00-00-ff"```

If you need to remove it:  ```Remove-NetNeighbor -IPAddress 192.168.0.5```

And all is good with this little networking world.  

Eventually I'll follow up on root cause.  Without doing any sort of investigation or firing up Wireshark [or Netsh](https://soccershoe.github.io/JustAnotherAdmin/blog/2019/09/21/UsingNetSH), I think the arp return packed from the Cisco is not making it back to my server.  Because it's always a network problem.  

![zissou](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/zissou.jpg)
