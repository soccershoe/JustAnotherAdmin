---
layout: post
title: "Windows Event Logging"
date: 2019-10-28
---

**Let's start Logging All The Things**

{{ more }}

This is a long one, so lets get going.  Let's set up a WEF environment!

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
  * **Push/Pull** – Subscriptions can be configured to push or pull the eventlog entries to/from the WEF server. EITSO uses push Subscriptions.

**What are the Requirements**

  * Group Policy Objects (GPOs) to control security auditing and event logging.
  * One or more servers with a configured Windows Event Log Collector service (often referred to as the "WEF Server" or "WEF
Collector").
  * Functional Kerberos for all endpoints (domain) or a valid TLS certificate (non-domain) for the Event Log Collector servers. *Note: My install doesn't include directions for non-domain joined WEF servers or clients.*
  * Windows Remote Management (WinRM) enabled on all workstations and servers that will forward events.
  * Firewall rules permitting WinRM connectivity (TCP 5985/5986) and WEF between the devices.
  * GPOs to specify the URL of the WEF subscription manager(s).
  * One or more event log subscriptions. A subscription is a collection of events based on Event IDs or other criteria to tell the
endpoints which event logs to forward.
  * A GPO is linked at the root of the domain labeled with the relevant settings. The setting in the GPO directs each client machine in
the domain which WEF server to talk to, every 15 minutes (configurable), to check if it has any Subscriptions specific to that
computer and what events to send.
  * The WEC server is then configured with the Eventlog MMC. The subscriptions are created with the relevant info for the client
machines.
  * From there, Splunk can be configured to pull the collected logs

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
  * As new devices are added to the domain and receive the appropriate security logging and WEF subscription GPOs, they will automatically
begin forwarding events, reducing the administrative burden of ensuring log coverage and quality.
  * In my environment, a WEC server is deployed for an AD site or group of AD sites (depending on load) as configured via GPO and runs the Event Log Collector service. A group policy object instructs all clients in the site to communicate with the WEF server, which provides a copy of the subscriptions that the workstation should use.

**A few limits on things**

While WEF provides immense value, it is not without limitations. These limitations should be considered when evaluating a WEF
deployment for your organization.

  * Load balancing is difficult. When using Kerberos, it is difficult—if not impossible—to effectively load balance the forwarded events
between multiple nodes. While events can be forwarded to multiple WEF servers, traditional methods of load balancing the traffic
do not work as the Service Principle Name (SPN) cannot be duplicated.
  * Active diagnosis and troubleshooting is limited. When WEF fails, it is often difficult to diagnose why. There are limited tools for
troubleshooting client issues, or validating the health of a given node. We have dedicated a section to addressing these issues later
in this article.
  * WEF supports a subset of XPath 1.0. This limits Subscriptions in size and scope. This will create more log files for growth if needed.

**Defining WEF Subscriptions**

The meat of a WEF subscription ruleset is defined by a collection of XML documents. The XML files can be imported and exported into the
configuration of the WEF server Subscriptions using the command line tool, wecutil.exe. The XML schema is explained in the Microsoft
MSDN documentation (links below)

**Custom Windows Event Channels**

More details here that we don't have to worry about yet.
WEF can be extended with additional custom event channels. Extending the number of event channels available provides a few primary
benefits:
  * Each event channel can have an independent maximum size and rotation strategy.
  * Each event channel can be used as a unique identifier for tagging data for ingestion into a SIEM (splunk or whatever else).
  * Event channels may be placed on different disks or storage devices for improving disk I/O.
  * Creating new event logs can be completed with the directions here: https://blogs.technet.microsoft.com/russellt/2016/05/18/creatingcustom-windows-event-forwarding-logs/ 
  * NOTE: The WEF configuration can only have one .DLL deployed. Use the existing .MAN file to build the new .DLL to maintain the current
event logs while adding new ones.
  * The Windows SDK is required to build the DLL. From Microsoft: "Developers who rely on ecmangen for event manifest creation are advised
to install the Windows Creators Edition of the SDK to obtain the file"

**Configuration File Locations**

Here is where I have placed all my necessary files for building the WEC server.  They may be referenced in the scripts or scheduled tasks, so update cautiously if you would like a different location.
  * C:\WEC-Build - Files and apps needed to build and maintain the .DLL and .MAN files
  * C:\WEC-Scripts – Various scripts for WEF maintenance
  * C:\WEC-Subscriptions – Location for Scheduled Task XML backups and Powershell
  * D:\WEC-EventLogs - folder where the custom EventLogs will eventually reside

**Deploying the actual WEC Server (assuming GPO's already deployed)**

Build New WEF Server (This is te abbreviated version if your infrastructure is good to go.)
1) Copy WEC-Build, WEC-Scripts, WEC-Subscriptions to C:\ from existing WEF server.
2) Import all Scheduled Tasks located in WEC-Scripts.
3) xcopy C:\WEC-Scripts\WUInstallation\*.* C:\Windows\System32\WindowsPowerShell\v1.0\Modules /E
4) Create D:\WEC-EventLogs.
5) Deploy Subscriptions using .\WEC-Deploy-Subscriptions.ps1.
6) Deploy the Channels.
     a) wevtutil um C:\windows\system32\CustomEventChannels.man (only needed if CustomEventChannels.man has been previously
loaded)
     b) xcopy C:\WEC-Build\CustomEventChannels.* C:\windows\system32
     c) wevtutil im C:\windows\system32\CustomEventChannels.man
7) Restart Server
8) Set EventLog size using .\WEC-Set-EventlogSize.ps1.
9) Move EventLogs using .\WEC-Move-Eventlogs.ps1.
the end

**Configure your Auditing GPO**

Client Auditing is configured via a GPO.  I've created a new one specific to Auditing in my environment.  Do what's appropriate for yours. Update the GPO as necessary to increase what is being audited.  You can find examples in the links below for what to audit.  I've included in my files a copy of my auditing settings.  Clients pick which WEF server to grab their configuration from via settings defined in the GPO.  Clients pick depending on what Active Directory defined site they are in, or by IP address for sites that may be larger than what one WEF server should handle.

For redundancy, I've created the GPO such that clients will send their events to two different WEC servers at the same time.

Clients Audit GPO – GPO defining auditable events and event log size (example includes GPO GPP setting for applying to a client site).
WEC Server GPO – GPO defining settings required by the WEF servers (example includes GPP setting to make sure the Wecsvc service starts as well as configuration for WinRM).
*links below*

