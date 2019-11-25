Get-ADObject -LDAPFilter '(objectClass=siteLink)' -SearchBase (Get-ADRootDSE).ConfigurationNamingContext -Property Name, Cost, Description, Sitelist | Out-GridView
