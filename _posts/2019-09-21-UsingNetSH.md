---
layout: post
title: "Using NetSH"
date: 2019-09-21
---

## To All the NetSH Commands I've Used Before

I"m writing this down so I can remember for the future.  I've used NetSH so many times in the past and have to look all this info up every time.  It's just one of those useful tools that you don't use every day and thus forget how to use them.  

{{ more }}

Netsh is a veritable swiss army knife of tools.  It does everything.  Most of the time I've been using it to capture domain controller networking traffic.  I hate installing Wireshark on domain controllers for security concerns (maybe a future post).  I'll try updating this post as I use the command in the future.


One of things annoying about capturing network traces with NetSH is the output format.  You have to convert the .ETL file from NetSH to a .CAP file that you can use to view in Wireshark.  Microsoft has killed off Netmon a long time ago, and just killed off Microsoft Message Analyzer.  I'm not sure what else will convert a .ETL file to a .CAP.  MS has removed the Message Analyzer link from their downloads page.  And if you want to download Netmon, it's still there, but it has limitations on the files it can process.  I've had to revert to the the Wayback Machine to find cached download links for Message Analyzer.  I'm not sure what I'll be using to convert those files in the future, but the old software seems to be fine for now.  I liked Message Analyzer.  I wish they hadn't had stopped development.

Another annoying thing about capturing the .ETL files is the huge amount of data it captures.  I have some busy domain controllers and they fill up GB's of data in a few minutes.  My last test capture was a little used domain controller and I ended up with a 4GB file in 20 minutes.  I walked away after starting the capture and putting a hard limit on the file size, so it could have been less than 20 minutes it filled up that file.  That's just ridiculous for my intended purpose to just find out who's talking to the server on TCP 389.  There has to be a way to filter that down to get what you want out of a simple network capture.  Wireshark is nice because you can filter the captures on specific criteria, like specific network ports.  NetSH has a basic filter for capturing things from a MAC or IP or Transport Layer (eg. TCP), but is otherwise crude and you end up with stuff you don't want.

My ultimate goal is to have a nice small portable file that I can get off the domain controller without sucking up bandwidth transferring it to another machine to process.  And then I don't want to have to wait for Message Analyzer or netmon to load and export the data.  I think there may be something within NetSH I can use to better filter these messages using the 'provider' option.  Here's the scenarios I'm going to check to see if this makes a difference in file size and data capture.

* If 'correlation' makes a difference using yes/no
* If 'provider' makes a difference between using 'Microsoft-Windows-NDIS-PacketCapture' and 'Microsoft-Windows-TCPIP'
* If 'provider=Microsoft-Windows-Networking-Correlation' and filtering by specifying ```capture level 1``` and ```ut:packet``` makes a difference

I'll time it at 5 minutes.  And here are the commands I'll test with respectively:

* ```Netsh trace start capture=yes overwrite=yes **correlation=<yes/no>** traceFile=c:\temp\trace.etl captureInterface=”Primary Team” filemode=single maxSize=4000```
* ```Netsh trace start capture=yes overwrite=yes correlation=no traceFile=c:\temp\trace.etl captureInterface=”Primary Team” provider=<Microsoft-Windows-TCPIP/Microsoft-Windows-NDIS-PacketCapture> ```
* ```Netsh trace start capture=yes overwrite=yes correlation=no traceFile=c:\temp\trace.etl captureInterface=”Primary Team” protocol=TCP PacketTruncateBytes=256 filemode=single maxSize=4000 provider=Microsoft-Windows-TCPIP level=5 keywords=ut:ReceivePath,ut:SendPath provider=Microsoft-Windows-Networking-Correlation level=1 keywords=ut:packet ```

Keep in mind that this is a one time test and there could be some rando dev guy hitting this one server one time hard for some odd reason right during my test, skewing everything.  Who knows.  But the results seem to pair with my expectations.

# Test 1
The correlation test made a difference in final file size.  Correlation shrunk the final file size from 480MB to 180MB.  I believe it does some sort of grouping of messages that enables the file size to be compressed further.  So, for portability reasons, the winner of this round is the correlation=yes.  Don't ask me if this makes a difference in the final goal of the output to .cap file, but it sure makes a difference if you need to move this file around to another machine to process it.

# Test 2
Using the ```Microsoft-Windows-NDIS-PacketCapture``` final file size was almost half of the ```Microsoft-Windows-NDIS-PacketCapture```.  Went from 853MB to 460MB.  That made a big difference.  

# Test 3
I found a couple of extra command goodies to see if the result could be filtered down even further.  Ultimately my goal is to have data to trace conversations around finding out who's talking to my domain controller.  Having the smaller file size is key to sanity.  This command took the file size down to 40MB.  This is so much better.  I can leave the command running for a much longer time without sacrifacing disk space, network bandwidth, and my sanity.  I'm down to 40MB with this command.

The final command added some extra stuff.  First, I filtered on just TCP traffic (protocol=TCP), leaving out any UDP traffic.  Then I just grabbed only the first part of each packet, which should include the header (PacketTruncateBytes=256) which should leave out the packet payload.  Then the logging level (level=5/1) should get us just the traffic and none of the junk the correlation provider, except critical, would give us.  And finally the ```keywords=ut:ReceivePath,ut:SendPath``` should give us the network conversations while the ```keywords=ut:packet``` should log nothing for the correlation provider.

It's amazing what's built into this swiss knife of a tool!!

## Level Up!!

I'm not even sure what I'm doing here with this command.  Too much going on.
[Alt LevelUp](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/nextlevel.gif)

```
netsh trace start capture=yes overwrite=yes maxsize=4096 tracefile=C:\Temp\NoConnection\net_mpssvc.etl persistent=yes provider="Microsoft-Windows-IPSEC-SRV" keywords=0xffffffffffffffff level=0xff provider={2588030D-920F-4AD6-ACC0-8AA2CD761DDC} keywords=0xffffffffffffffff level=0xff provider={94335EB3-79EA-44D5-8EA9-306F4FFFA070} keywords=0xffffffffffffffff level=0xff provider={94335EB3-79EA-44D5-8EA9-306F49B3A040} keywords=0xffffffffffffffff level=0xff provider={E4FF10D8-8A88-4FC6-82C8-8C23E9462FE5} keywords=0xffffffffffffffff level=0xff provider={5EEFEBDB-E90C-423A-8ABF-0241E7C5B87D} keywords=0xffffffffffffffff level=0xff provider={D8FA2E77-A77C-4494-9297-ACE3C12907F6} keywords=0xffffffffffffffff level=0xff provider={00000000-0000-0000-0000-000000000000} keywords=0xffffffffffffffff level=0xff provider={EB004A05-9B1A-11D4-9123-0050047759BC} keywords=0xffffffffffffffff level=0xff provider={28C9F48F-D244-45A8-842F-DC9FBC9B6E94} keywords=0xffffffffffffffff level=0xff  provider={5AD8DAF3-405C-4FD8-BCC5-5ABE20B3EDD6} keywords=0xffffffffffffffff level=0xff provider={28C9F48F-D244-45A8-842F-DC9FBC9B6494} keywords=0xffffffffffffffff level=0xff provider={A8351B7A-57BE-4388-8843-08DE1E321B7F} keywords=0xffffffffffffffff level=0xff provider={A487F25A-2C11-43B7-9050-527F0D6117F2} keywords=0xffffffffffffffff level=0xff Provider={5A1600D2-68E5-4DE7-BCF4-1C2D215FE0FE} keywords=0xffffffff level=0x5 Provider={106B464D-8043-46B1-8CB8-E92A0CD7A560} keywords=0xffffffff level=0x5 Provider={AD33FA19-F2D2-46D1-8F4C-E3C3087E45AD} keywords=0xffffffff level=0x5 Provider={106B464A-8043-46B1-8CB8-E92A0CD7A560} keywords=0xffffffff level=0x5
```


## Reference Links
[Cached Message Analyzer Download](https://web.archive.org/web/20191106164517/http://www.microsoft.com/en-us/download/details.aspx?id=44226)
<https://chentiangemalc.wordpress.com/2012/02/22/netsh-traceuse-it/>
<https://community.ipswitch.com/s/article/How-to-run-a-NETSH-Trace>
<https://www.t2techgroup.com/dont-install-wireshark-on-your-windows-server/>
<https://docs.microsoft.com/en-us/powershell/module/pef/new-peftracesession?view=winserver2012r2-ps>
<http://www.tech-wiki.net/index.php?title=How_to_capture_traffic_with_no_Wireshark_using_netsh>
<https://michlstechblog.info/blog/windows-show-and-configure-network-settings-using-netsh/>
<https://blogs.msdn.microsoft.com/canberrapfe/2012/03/30/capture-a-network-trace-without-installing-anything-capture-a-network-trace-of-a-reboot/>
<https://blogs.msdn.microsoft.com/benjaminperkins/2018/03/09/capture-a-netsh-network-trace/>
<https://docs.microsoft.com/en-us/message-analyzer/built-in-trace-scenarios>
<https://docs.microsoft.com/en-us/message-analyzer/using-the-advanced-settings-microsoft-windows-ndis-packetcapture-dialog>
