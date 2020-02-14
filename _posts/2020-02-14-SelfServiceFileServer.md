---
layout: post
title: "Self Service File Shares : Overview"
date: 2020-02-14
---

**Self-Service File Server** How can I enable my end users to self-provision their own SMB shares?  How do I get them closer to their data?  And why would I want to do that?  Too many questions.  

{{ more }}

I looked everywhere and couldn't find a solution where users could set up their own file shares.  I got tired of having to set up groups and group memberships for access, as well as just setting up the share itself.  It was just busy-work.  

Today, users might have access to their own AWS S3 buckets or Dropbox/Onedrive space.  But those don't always meet the requirements of what SMB access traditionally gives.  You might have on-prem service accounts that drop stuff into shared locations, or multiple users need access to edit or archive 'team owned' files.  Those cloud solutions aren't easy or feasible to set up for those same user/team workflows.

There are other options out there like AWS Cloud Gateway which fronts S3/Glacier buckets with locally cached storage.  That'll present an SMB share.  But I wanted to complete this with zero cost other than the resources I already had.  So, Powershell it is.  

I also came up with a storage tier model that encompasses different use cases.  There are three tiers:
* Personal
* Team
* Full Service

_Personal_ represents Dropbox/Onedrive.  The end user has full permissions and full self-service capabilities.  The end user manages this all themselves.  _Full Service_ represents traditional SMB file shares where there are tons of files and there needs to be DFS Replication scenarios or complex permission sets.  Where my self-service comes in is right in the middle.  The _Team_ level creates smaller restricted SMB shares where data is restricted in size (20GB for my env), permissions are limited to one level, and support is mostly hands-off from a helpdesk level. 

If data sets change or teams need capabilities beyond the _Team_ level, then they get migrated to a _Full Service_ SMB share.  Because the _Team_ quotas are set in stone and we want this to be a "self-service" service, we need hard rules.  But tiering this seemed obvious to me to decrease the random file share asks.

### Building out the Details ###

***Problem Statement***
How do you give users almost self-serve file share creation and management and keep a simplified infrastructure, while getting users closer to their data.  Also, how do you keep datasets smaller and manageable for Operations management tasks such as migrating data, expiring shares, backups, etc…

***Technologies Used***
 * Windows Server 2012/2016 (I initially built this out using 2012, but I assume 2016 is valid as well)
  * Windows Roles: File and Storage Services, File and iSCSI Services, File Server, BranchCache for Network Files, Data Deduplication, DFS Namespaces, DFS Replication, File Server Resource Manager, Storage Services
  * Windows Features: Powershell, RSAT Tools, AD DS and AD LDS Tools

### High Level Features ###

***Self-Serve***
Users will be able to contact the helpdesk and request a file share.  The helpdesk will run a script that will immediately create the file share and access groups, as well as emailing the end user instructions on usage.  This is done via two powershell scripts.  One PS script creates the share as well as manages other functions the helpdesk will need to interface with the customer and answer customer questions.  The other script runs on the file server itself and will be running the FSRM Expiration Task.  This is a Task moves the data to the Archive folder.

The share permssions are granted at share creation.  I have the usage of Imanami GroupID to create AD Security Groups.  It's a handy tool to enable end user self-service of those objects.  I'll be using this for the example here since I can use it to assign Security Group owners specific to my requestor's environment.  Using GroupID, two groups are created to manage read and modify permissions.  The same function could also easily be completed using Powershell AD commandlets.  The share paths and how to manage the groups is detailed in the email to the end user when their new share is created.  End users will also be able to do self-service restores using the Windows Previous Version Tab on the File or Folder properties.  

***Auto-Archiving***
The FSRM Task migrates all files to an Archive folder that will move files that have a NTFS LastAccessDate of more than 365 days.  The Archive folder is a SymLink to the E: drive (or wherever you propose).

***User Notifications***
End users get a monthly quota email showing their usage.  On Share creation, the end user receives an email detailing how to use the new Share and manage permissions.

***Storage Space***
The server drives are set to use Storage Spaces (if not using SAN storage. I'm using local storage) and Dedupe features of Windows 2012r2.  The Dedupe feature will enable smaller datasets to work with as duplicated data won’t be stored twice.  Storage Spaces allows for adding or expanding LUNS to the server and dynamically adding space to the lettered drives.

***Limitations***
This is limited to your storage size.  Dedupe helps.  I got about a 50% storage size savings on our existing standard multi-use file share servers.  That's pretty good.  And maybe you'll want to put in a gateway so file shares aren't completely self-service.  I added the helpdesk to make sure that this service wasn't being abused by the general population.  

Take this as far as you want.  I was pleased with the features provided by an out-of-box 2012 server and wanted to enable everything I could for this little project.  

Next post: [Server Setup](https://soccershoe.github.io/JustAnotherAdmin/blog/2020/02/14/SelfServiceFileServer2)

*Off we go!*