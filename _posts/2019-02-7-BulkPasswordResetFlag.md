---
layout: post
title: "Bulk Password Reset Flag"
date: 2020-02-7
---

**Setting the Password Reset on Next Logon flag in bulk**

{{ more }}

I had this problem the other day.  How do you reset a bunch of users accounts to change password on next logon.  And your manager or security team asks if you can do it for this specific group of people, and of those people, only the people in the last 17 days who haven't already changed their password, need to change password on next logon.  Luckily I was provided an intial list of users.

![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/ManagersEverywhere.jpg)

This isn't pretty but gets the job done.  Powershell time!


    ## full list of users who haven’t changed passwords in the last 17 days.
    $users = import-csv C:\temp\fulllistusers.csv
    $list = @()
    Foreach ($user in $users) {
     $out = Get-ADUser -identity $user.samAccountname -Properties PasswordLastSet | where {$_.passwordlastset -lt ((get-date).adddays   (-17))}
     $list += $out
    }
    ($list | select SamAccountName,PasswordLastSet).count
    $list | select SamAccountName | Export-Csv c:\temp\filteredusers.csv -NoTypeInformation## set the flag for designated users
    import-csv C:\temp\filteredusers.csv | ForEach-Object {
        $samAccountName = $_.“samAccountName”
        Get-ADUser -Identity $samAccountName | Set-ADUser -ChangePasswordAtLogon:$True -Verbose
    }

Feel free to modify as needed for your scenario.

![alt text](https://raw.githubusercontent.com/soccershoe/JustAnotherAdmin/master/images/PasswordIncorrect.jpg)
