---
layout: post
title: "Doing the Basics - Escalation"
date: 2020-04-15
---

**Free things that'll put you ahead of 90% of the others out there to help defend against escalation attacks**

Security is hard.  It's hard to understand.  It's hard to convey importance.  And it's hard to even get easy stuff prioritized over other business processes to complete.  And it's hard to get past all the marketing speak blasting in your VP's face telling him that he needs to buy the fanciest and most expensive EDR solution with built-in AI and Machine Learning to automate all your detections and remediations and you can fire all your staff with your EDR overlord at the controls.  

{{ more }}

Here are a few things that are free, and hopefully for you, take little effort to apply to be ahead of most everyone else out there.  Each of these things makes it that much harder for some attacker to mess around inside your domain/realm/domicile.  There's no way to keep everyone out as a guarantee, but the goal is to make it so that your domain is not financially worth while for them to get what they need.  Most external attackers are financially motivated.  They run a business to make money stealing and selling information.  So don't make it financially not worth their time.  

On top of the above, any of those fancy APT groups doing all sorts of media worthy hacks, they all have to at some point cross paths with the preventions posted here.  There is no way any of those fancy attacks would have happend if these simple and free things below were implemented first.  

**Patch all the things!**
Windows provides Windows Update online for free.  If you need the options provided by WSUS (Windows Server Update Services), use that.  I know it's harder said than done.  I've had to work around maintenance windows and teams unwilling to do any patching to their servers for some reason or another.  And why does the SQL team only patch twice a year?  No idea why they get away with that.  SQL is easy to make redundant.  

MacOS has it's free update process.  They also provde a patching server in their server app.  It's $20, so why not.  

Linux with whatever flavor of apt or yum.  Turn it into a cron job.

Whatever you need, make a policy of it.  Yes, yes. :roll_eyes: Providing the technical solution is easy.  It's the people and policy that's hard.  Start small and crank up the settings as you move forward.  Heat up that pot of water.  

* and level two patch mastery is providing yum or chocolatey or artifactory repo's for 3rd party patching.  Stretch goal.  :)

**Prevent Credential Dumping**
How do you prevent credential dumping?  Not having the credentials on the system in the first place.  Implement a policy of no logons besides DA's to domain controllers or any system that runs agents on the domain controllers.  Three easy GPO's and block inheritance on your Domain Controllers OU.  One for each tier.  Great explanation and [example here...](https://improsec.com/tech-blog/preventing-lateral-movement-in-active-directory-with-authentication-policies)  You say it's easy, but again... the people and policy and complainers wanting their DA accounts to do their finacial reports.  Just, why?

Basically, any system that can affect the sanctity of trust for identity.  Start with just Tier0, as hopefully explained in my [Tier0 post here...](https://soccershoe.github.io/JustAnotherAdmin/blog/2020/01/07/CredentialTiering)

Other mitigations here: https://attack.mitre.org/techniques/T1003/

PtH attacks have been around since 1997.  It's old.  For some reason it is still viable as a technique.  https://en.wikipedia.org/wiki/Pass_the_hash  Make sure that PtH security design makes it into your architecture and security decisions.  

* and level two dump mastery would be JIT and JEA implementations to help abate the use of DA accounts, or the "I need a DA account" asks.

**Extra Hygene**
Clear out all the built-in Active Directory groups.  Delegate those specific roles to Security Groups of your own creation.  Some of those built-in groups have far too much privilege in AD and are escalation paths to DA.  For example, the group Backup Admins can take a backup of the Domain Controller.  BA doesn't have DA rights, but taking that backup offline you now have the ntds.dit to crack in your spare time.  This is just one example.

You can't have DA creds sitting in your lsass cache on systems not tier0.  Easy pickings for mimikatz to pick up.  See previous section^^

* and level two is to use a tool called [PingCastle](https://www.pingcastle.com/) to do some of your own reconisance on yourself.  It's free.  

* and level two.point.five for hygene is to have approval workflows for granting membership into those groups.  Use a product like Imanami or JIT/JEA (again^^) to make human approval roadbumps.  Monitor those group memberships.  

**Local Administrators**
Don't use the same local admin password on all your endpoints.  That makes things too easy for an attacker.  Deploy LAPS from Microsoft if you have that in your MS agreement for usage.  It's a 10 minute setup and a couple GPO's.  Ok, ok.  There are security things you need to think through like securing that field in AD and if storing those passwords in AD are the right thing to do for your org.  There are other solutions as well like Leiberman.  

Also, this password setting will prevent local account usage from traversing the network.  Another roadbump.
link here:

* and level two for local admins is disable that local admin account.  Don't use that 500 account.  Create a new one if you have to.  But make sure it's a random password as well.  And since this is a pretty easy one, I'm going to add to level two a check to make sure any of your GPP's in your GPO's don't have the password saved in them.  That's a password almost stored in cleartext.  It's encrypted but the encryption is so bad that Microsoft published the encryption key.  Like having a lock on the door but any key can unlock the tumbler.  

So there  you have it.  All the easy and free things you should do to save face and save your domicile from unwanted attackers (minus the implementing of the policy and procedure and convincing all the people.  *sigh*

If you need help convicing management of any of these steps, maybe tying one or two of these to MITRE or OWASP findings for top vulns will help.  Or better yet, use PingCastle.  It is made for management reports!  It has Red (bad!) and Green (good!) in the pictures!

![castleyrock](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/castleyrock.jpg)


