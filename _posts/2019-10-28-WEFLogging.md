---
layout: post
title: "Windows Event Logging ...Part 1"
date: 2019-10-28
---

**Let's start Logging All The Things!  ...Part 1**

{{ more }}

This is a long one.  I'll eventually break this article into several posts and better organize it.

Let's set up a WEF environment!  

What has a free log centralization platform built into it's operating system?  Windows.  Using Windows Event Forwarding (WEF) and some Active Directory GPO's, we can create a system where you can centralize all your logging to do what you like with.  You can then send your logs on forward to Splunk or ELK or some other searching platform.  Or just keep it on the centralized WEF server.  

Let's implement Windows Event Forwarding for the whole of your Windows environment. 

**Let's start off with some Definitions:**

  * **WEF** – Windows Event Forwarding (WEF) is a powerful log forwarding solution integrated within modern versions of Microsoft Windows.
WEF allows for event logs to be sent, either via a push or pull mechanism, to one or more centralized Windows Event Collector (WEC)
servers. WEF is agent-free, and relies on native components integrated into the operating system.
  * **Windows Event Channels** - Event Channels are queues that can be used for collecting and storing event log entries on a collector server.
  * **Windows Event Collector** – Windows Event Collector (WEC) is the central server collecting all the event logs sent from the clients.
  * **Subscriptions** – Eventlog Subscriptions are the configuration item polled by client machines to tells the client specific eventlog entries to
send to the WEF server.
  * **Push/Pull** – Subscriptions can be configured to push or pull the eventlog entries to/from the WEF server. In my example here I use push Subscriptions.

**What are the Requirements**

  * Group Policy Objects (GPOs) to control security auditing and event logging.
  * One or more servers with a configured Windows Event Log Collector service (often referred to as the "WEF Server" or "WEF
Collector").
  * Functional Kerberos for all endpoints (domain) or a valid TLS certificate (non-domain) for the Event Log Collector servers. *Note: My install doesn't include directions for non-domain joined WEF servers or clients.*
  * Windows Remote Management (WinRM) enabled on all workstations and servers that will forward events.
  * Firewall rules permitting WinRM connectivity (TCP 5985/5986) and WEF between the devices.
  * GPOs to specify the URL of the WEF subscription manager(s) that the clients use.
  * One or more event log subscriptions. A subscription is a collection of events based on Event IDs or other criteria to tell the
endpoints which event logs to forward.
  * A GPO that is linked at the root of the domain labeled with the relevant settings. The setting in the GPO directs each client machine in
the domain which WEF server to talk to, every 15 minutes (configurable), to check if it has any Subscriptions specific to that
computer and what events to send.
  * The WEC server is then configured with the Eventlog MMC. The subscriptions are created with the relevant info for the client
machines.
  * From there, Splunk or ELK or Syslog, can be configured to pull the collected logs

![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/WEFPicture.PNG)

**How's this work really?**
Don't worry so much about details, just that this is kind of how it goes down on the client side.

The following actions occur upon first receiving appropriate GPOs on a workstation:
  * The workstation configures security auditing and starts writing to the local event log.
  * The workstation connects to the subscription manager(s) using WinRM, authenticated either via Kerberos or TLS. In both cases,
transport-layer encryption is applied.
  * The workstation registers itself in the registry of the Event Log Collector (WEC server), and downloads a list of all relevant WEF
Subscriptions.
  * The workstation periodically sends events to the Event Log Collector(s) as defined in the subscription files. Additionally, the
workstation connects on a periodic heartbeat.
  * As new devices are added to the domain and receive the appropriate security logging and WEF subscription GPOs.  So they will automatically
begin forwarding events, and we are now hands off and reducing the administration of making sure there is log coverage for everyone.
  * In my environment we have lots of users in some offices, a WEC server is deployed for an AD site or group of AD sites (depending on load) as configured via GPO and runs the Event Log Collector service. A group policy object instructs all clients in the site to communicate with the WEF server, which provides a copy of the subscriptions that the workstation should use.

**A few limits on things**

While WEF provides immense value, it is not without limitations. These limitations should be considered when evaluating a WEF
deployment for your organization.

  * Load balancing is difficult. When using Kerberos, it is difficult—if not impossible—to effectively load balance the forwarded events
between multiple nodes. While events can be forwarded to multiple WEF servers, traditional methods of load balancing the traffic
do not work as the Service Principle Name (SPN) cannot be duplicated.
  * Diagnosis and troubleshooting is limited. When WEF fails, it is often difficult to diagnose why. There are limited tools for
troubleshooting client issues, or validating the health of a given node. We have dedicated a section to addressing these issues later
in this article.
  * WEF supports a subset of XPath 1.0. This limits Subscriptions in size and scope. This will create more log files for growth if needed.
  * When you start getting up over 2000 clients on a WEF server, the GUI starts to loose it.  I believe it's because it takes so long to read all the client info from the registry.  You can get around it using the wevutil command line, or limit users per server.

**Defining what's in your WEF Subscriptions**

The meat of a WEF subscription ruleset is defined by a collection of XML documents. The XML files can be imported and exported into the
configuration of the WEF server Subscriptions using the command line tool, wecutil.exe. The XML schema is explained in the Microsoft
MSDN documentation (links below).  You can also use the GUI to define what events you are collecting.  I've supplied some example .XML files if you prefer that route.

**Custom Windows Event Channels**

More details here that we don't have to worry about quite yet.  This can be a bit of a technical task and not quite a requirement for this to be successful.  Though it is great for organizing your collected events.  My example here is set up with multiple channels.  Maybe I'll provide a post or section to making this work.  There are some separate requirements if you want to create your own or go beyond the example provided here.

WEF can be extended with additional custom event channels. Extending the number of event channels available provides a few primary
benefits:
  * Each event channel can have an independent maximum size and rotation strategy.
  * Each event channel can be used as a unique identifier for tagging data for ingestion into a SIEM (splunk or whatever else).
  * Event channels may be placed on different disks or storage devices for improving disk I/O.
  * Creating new event logs can be completed with the directions here: <https://blogs.technet.microsoft.com/russellt/2016/05/18/creatingcustom-windows-event-forwarding-logs/>
  * NOTE: The WEF configuration can only have one .DLL deployed. Use the existing .MAN file to build the new .DLL to maintain the current
event logs while adding new ones.
  * The Windows SDK is required to build the DLL. From Microsoft: "Developers who rely on ecmangen for event manifest creation are advised
to install the Windows Creators Edition of the SDK to obtain the file"

**Configuration File Locations**

Here is where I have placed all my necessary files for building the WEC server.  They may be referenced in the scripts or scheduled tasks, so update cautiously if you would like a different location.
  * C:\WEC-Build - Files and apps needed to build and maintain the .DLL and .MAN files
  * C:\WEC-Scripts – Various scripts for WEF maintenance
  * C:\WEC-Subscriptions – Location for Scheduled Task XML backups and Powershell
  * .D:\WEC-EventLogs - folder where the custom EventLogs will eventually reside


**Configure your Auditing GPO**

Client Auditing is configured via a GPO.  I've created a GPO specific to Auditing for clients in my environment.  Do what's appropriate for yours. Update the GPO as necessary to increase what is being audited by default from Microsoft.  

You can find examples in the links below for what to audit and how best to configure your settings.  I've included in my files here a copy of my auditing settings.  Clients pick which WEF server to grab their configuration from via settings defined in the GPO.  GPO's are pretty flexible if you use Group Policy Preferences (GPP) and use things like AD Site or IP address range if you suspect your environment is larger than what one WEF server could handle.

For redundancy, I've created the GPO such that clients will send their events to two different WEC servers at the same time.

  * **Clients Audit GPO** – GPO defining auditable events and event log size (example includes GPO GPP setting for applying to a client site).
  * **WEC Server GPO** – GPO defining settings required by the WEF servers (example includes GPP setting to make sure the Wecsvc service starts as well as configuration for WinRM).


**Deploying the actual WEC Server (assuming GPO's already deployed)**

Build New WEF Server (This is te abbreviated version if your infrastructure is good to go and you are just adding a new WEF server.)

1. Copy WEC-Build, WEC-Scripts, WEC-Subscriptions to C:\ from existing WEF server.
2. Import all Scheduled Tasks located in WEC-Scripts.
3. xcopy C:\WEC-Scripts\WUInstallation\*.* C:\Windows\System32\WindowsPowerShell\v1.0\Modules /E
4. Create D:\WEC-EventLogs.
5. Deploy Subscriptions using .\WEC-Deploy-Subscriptions.ps1.
6. Deploy the Channels.
   * wevtutil um C:\windows\system32\CustomEventChannels.man (only needed if CustomEventChannels.man has been previously loaded)
   * xcopy C:\WEC-Build\CustomEventChannels.* C:\windows\system32
   * wevtutil im C:\windows\system32\CustomEventChannels.man
7. Restart Server
8. Set EventLog size using .\WEC-Set-EventlogSize.ps1.
9. Move EventLogs using .\WEC-Move-Eventlogs.ps1.

the end

**Configure the WEC Collectors**

Most of the work is done via GPO. The Site GPO's will be linked to client sites that will define which WEC server they connect to to get their
subscriptions.  The rest of the configuration is completed in the following sections.

   * Create the folder C:\WECScripts.  We'll store our scripts and configuration files here
   * Create the folder D:\WEC-EventLogs.  We'll store the actual event log files here.  Putting them on a separate disk can help with disk performance if you are worried about that.

Deploy some Scheduled Maintenance tasks.  Add each of these Scheduled tasks in Task Scheduler by importing the .xml located in C:\WECScripts.  Open Task Scheduler and select Task Scheduler Library, then click on Import Task on the right bar.

1. WEC-HTTPErr-Grooming.xml - clears the logs in the httperr folder as they fill up the C: drive
2. WEC-Registry-Grooming.xml - clears client subscriptions in the registry to prevent registry bloat and bad performance
3. Weekly Reboot.xml - clear any memory leaks
4. Daily Windows Update - automatically apply windows updates to get ahead of security or other Windows issues.  Module, Script and Scheduled task are located in my example files.  I wouldn't call these servers needing any sort of 99.999% uptime.  So reboot them and update them often.
5. System_Microsoft-Windows-Resource-Exhaustion-Detector_2004 - This task will restart the server if event id 2004 shows up in the System
event log.  2004 warns of resource exhaustion.  It's happened to me, so I made this.

**Deploy the Channels and Move the Eventlogs**

Once the DLL has been created using the directions previous, use the following steps to deploy the DLL. This must be executed on each
Subscription Manager (WEC server):
1. Unload the existing manifest via command line:  wevtutil um C:\windows\system32\CustomEventChannels.man (it may not exist if
you haven't yet built the server).
2. Copy your newly created CustomEventChannels.man and CustomEventChannels.dll files into c:\windows\system32.  These files are
preconfigured using the existing documented paths and located in C:\WEC-Build.
3. Import the new manifest via command line:  wevtutil im C:\windows\system32\CustomEventChannels.man. This creates the
defined channels and log files on the WEC servers.
4. Restart the server.
5. I also recommend increasing the size of each channel to 2GB.  Run the example Powershell below or 'WEC-Set-EventlogSize.ps1' located in C:\WEC-Scripts. 

```
$xml = wevtutil el | select-string -pattern "WEC"
foreach ($subscription in $xml) {
wevtutil sl $subscription /ms:2194304000
}
```

Move the event logs to the D: drive to be more flexible with disk size and performance. Disk performance can be a bottleneck.
Run the below in Powershell or use the WEC-Move-Eventlogs.ps1 located in C:\WEC-Scripts.

```
Stop-Service wecsvc
$xml = wevtutil el | select-string -pattern "WEC"
foreach ($subscription in $xml) {
wevtutil sl $subscription /lfn:D:\WEC-EventLogs\$subscription.evtx
}
Start-Service wecsvc
```

**Troubleshooting**

Ok.  This section needs a bit more info.  But here's what I have for now.
1. WinRM connection issues get logged here on the server side: C:\Windows\System32\LogFiles\HTTPERR.  Might be able to find some branches to follow when clients are unable to connect.
2. 

**Other Notes**

1. Registry Pruning
   * Delete keys under HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\EventCollector\Subscriptions<SubscriptionName> for PCs that are no longer active. A script with a scheduled task is deployed on each WEC server that just looks for the last heartbeat time and has intelligence to remove keys here that with HeartBeat times older than a specific threshold.
2. HTTPErr log pruning
   * Delete files under C:\Windows\System32\Logfiles\HTTPErr The files record errors for the WinRM connections. WinRM uses HTTP.SYS, the same driver as IIS, which means it logs certain things by default.
3. Keep each WEF server under 2000 subscriptions. This should be a manageable size while still being able to use the MMC.exe GUI usable.
4. A weekly scheduled reboot task is created to keep the server healthy from memory leaks. *Windows may be a little leaky.*

**Appendix**

  * List of WEF channels as I have configured:
1. WEC-Powershell: Event channel for collecting PowerShell events.
2. WEC-WMI: Event channel for collecting WMI events.
3. WEC-EMET: Event channel for collecting EMET events.
4. WEC-Authentication: Event channel for collecting authentication events.
5. WEC-Services: Event channel for collecting services events.
6. WEC-Process-Execution: Event channel for collecting process creation/termination events.
7. WEC-Code-Integrity: Event channel for collecting device guard and code integrity events.
8. WEC2-Registry: Event channel for collecting registry audit events.
9. WEC2-Object-Manipulation: Event channel for collecting object audit events.
10. WEC2-Applocker: Event channel for collecting applocker events.
11. WEC2-Task-Scheduler: Event channel for collecting scheduled task and at events.
12. WEC2-Application-Crashes: Event channel for collecting application crash events.
13. WEC2-Windows-Defender: Event channel for collecting windows defender events.
14. WEC2-Group-Policy-Errors: Event channel for collecting group policy error events.
15. WEC3-Drivers: Event channel for collecting driver events.
16. WEC3-Account-Management: Event channel for collecting account management events.
17. WEC3-Windows-Diagnostics: Event channel for collecting diagnostic events.
18. WEC3-Smart-Card: Event channel for collecting smart card events.
19. WEC3-External-Devices: Event channel for collecting USB and external device events.
20. WEC3-Print: Event channel for collecting printer and print job events.
21. WEC3-Firewall: Event channel for collecting firewall events.
22. WEC4-Wireless: Event channel for collecting 802.1 wireless events.
23. WEC4-Shares: Event channel for collecting SMB share events.
24. WEC4-Bits-Client: Event channel for collecting BITS Client events.
25. WEC4-Windows-Update: Event channel for collecting windows update events.
26. WEC4-Hotpatching-Errors: Event channel for collecting hotpatching error events.
27. WEC4-DNS: Event channel for collecting DNS query and DLL loading events.
28. WEC4-System-Time-Change: Event channel for collecting time change events.
29. EC5-Operating-System: Event channel for collecting operating system events.
30. WEC5-Certificate-Authority: Event channel for collecting CA events.
31. WEC5-Crypto-API: Event channel for collecting crypto API events.
32. WEC5-MSI-Packages: Event channel for collecting package installation events.
33. WEC5-Log-Deletion-Security: Event channel for collecting log deletion events.
34. WEC5-Log-Deletion-System: Event channel for collecting log deletion events.
35. WEC5-Autoruns: Event channel for collecting Autoruns-To-Wineventlog events.
36. WEC6-Exploit-Guard: Event channel for collecting Exploit Guard events.
37. WEC6-Duo-Security: Event channel for collecting Duo Security events.
38. WEC6-Device-Guard: Event channel for collecting Device Guard events.
39. WEC6-ADFS: Event channel for collecting Active Directory Federation Services events.
40. WEC6-Sysmon: Event channel for collecting Sysinternals Sysmon events.
41. WEC6-Software-Restriction-Policies: Event channel for collecting Software Restriction Policy events.
42. WEC6-Microsoft-Office: Event channel for collecting Microsoft Office events.
43. WEC7-Active-Directory: Event channel for collecting Active Directory change events.
44. WEC7-Terminal-Services: Event channel for collecting Terminal Services and Terminal Services Gateway events.
45. WEC7-Privilege-Use: Event channel for collecting privilege events.

**Building DLL Overview**

This only needs to be completed if the WEC Subscriptions need to be changed from the build already supplied from the .dll and .man.

Prereq:  Windows 10 SDK from Creators Edition (I think you need this specific version because MS moved some stuff around and moved or removed the ecmangen.exe file)

*Editing*

Launch the Manifest Generator: "C:\Program Files (x86)\Windows Kits\10\bin\x64\ecmangen.exe"
Load the CustomEventChannels.man file.  Make any changes to the file. Ensure the following settings are observed:
  * All channels are marked as Operational and Enabled.
  * No more than 7 channels are added to each provider.
  * Channels following the naming scheme (WEC#-Name)
  * Symbols use underscores and not hyphens.

*Compiling*

To compile, perform the following from a cmd.exe shell:
  * "C:\Program Files (x86)\Windows Kits\10\bin\x64\mc.exe" CustomEventChannels.man
  * "C:\Program Files (x86)\Windows Kits\10\bin\x64\mc.exe" -css CustomEventChannels.DummyEvent CustomEventChannels.man
  * "C:\Program Files (x86)\Windows Kits\10\bin\x64\rc.exe" CustomEventChannels.rc
  * "C:\Windows\Microsoft.NET\Framework64\v4.x.x\csc.exe" /win32res:CustomEventChannels.res /unsafe /target:library /out: CustomEventChannels.dll C:CustomEventChannels.cs

*Deployment*

For each WEF server you need to deploy this to, perform the following:
1. Disable the Windows Event Collector Service: net stop Wecsvc
2. Disable all current WEF subscriptions.

Unload the current Event Channel file:
1. wevtutil um C:\windows\system32\CustomEventChannels.man
2. Copy (and replace) the following files to each WEF server under C:\Windows\system32: 
  * CustomEventChannels.dll 
  * CustomEventChannels.man
3. Load the new Event Channel file:
  * wevtutil im C:\windows\system32\CustomEventChannels.man
4. Resize the log files:
```
$xml = wevtutil el | select-string -pattern "WEC"
foreach ($subscription in $xml) {
wevtutil sl $subscription /ms:2194304000
}
```
5. Re-enable the WEF subscriptions.
6. Re-enable the Windows Event Collector service

**Sources**

  * <https://medium.com/palantir/windows-event-forwarding-for-network-defense-cb208d5ff86f>
  * <https://blogs.technet.microsoft.com/jepayne/2015/11/23/monitoring-what-matters-windows-event-forwarding-for-everyoneeven-if-you-already-have-a-siem/>
  * <https://www.nsa.gov/ia/_files/app/Spotting_the_Adversary_with_Windows_Event_Log_Monitoring.pdf>
  * <https://github.com/iadgov/Event-Forwarding-Guidance>
  * [Microsoft Windows Event Forwarding to help with intrusion detection](https://docs.microsoft.com/en-us/windows/threat-protection/use-windows-event-forwarding-to-assist-in-instrusion-detection)
  * [Monitoring What Matters](https://blogs.technet.microsoft.com/jepayne/2015/11/23/monitoring-what-matters-windows-event-forwarding-for-everyone-even-if-you-already-have-a-siem/)
  * [Spotting the Adversary](https://www.iad.gov/iad/library/reports/spotting-the-adversary-with-windows-event-log-monitoring.cfm)
  * [Creating Custom Windows Event Forwarding Logs](https://blogs.technet.microsoft.com/russellt/2016/05/18/creating-custom-windows-event-forwarding-logs/)
  * [Windows Logging Cheat Sheet](https://static1.squarespace.com/static/552092d5e4b0661088167e5c/t/580595db9f745688bc7477f6/1476761074992/Windows+Logging+Cheat+Sheet_ver_Oct_2016.pdf)
  * [Event Forwarding Guidance](https://github.com/iadgov/Event-Forwarding-Guidance/)
  * [Windows Event Log Reference](https://msdn.microsoft.com/en-us/library/aa385785%28v=vs.85%29.aspx)
  * [Windows Event Log Consuming Events](https://msdn.microsoft.com/en-us/library/dd996910%28v=vs.85%29.aspx)
  * [Advanced XML Filtering](https://blogs.technet.microsoft.com/askds/2011/09/26/advanced-xml-filtering-in-the-windows-event-viewer/)
  * [XPath Documentation](https://www.w3.org/TR/xpath/)

  

