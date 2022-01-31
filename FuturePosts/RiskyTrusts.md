[CmdletBinding()]  
Param  
(  
    [switch]$Collect, 
    [switch]$ScanAll 
) 
 
if ($Debug) {  
    $DebugPreference = 'Continue'  
} 
else { 
    $DebugPreference = 'SilentlyContinue'  
} 

function Get-AdTrustsAtRisk 
{ 
    [CmdletBinding()]  
    Param  
    (  
        [string]$Direction = "Inbound", 
        [switch]$ScanAll 
    ) 
 
    if ($ScanAll) { 
        return get-adtrust -filter {Direction -eq $Direction} 
    } 
    else { 
        return get-adtrust -filter {Direction -eq $Direction -and TGTDelegation -eq $false} 
    } 
} 
 
function Get-ServiceAccountsAtRisk 
{ 
    [CmdletBinding()]  
    Param  
    (  
        [string]$DN = (Get-ADDomain).DistinguishedName, 
        [string]$Server = (Get-ADDomain).Name 
    ) 
 
    Write-Debug "Searching $DN via $Server" 
 
    $SERVER_TRUST_ACCOUNT = 0x2000  
    $TRUSTED_FOR_DELEGATION = 0x80000  
    $TRUSTED_TO_AUTH_FOR_DELEGATION= 0x1000000  
    $PARTIAL_SECRETS_ACCOUNT = 0x4000000    
 
    $bitmask = $TRUSTED_FOR_DELEGATION -bor $TRUSTED_TO_AUTH_FOR_DELEGATION -bor $PARTIAL_SECRETS_ACCOUNT  
  
$filter = @"  
(& 
  (servicePrincipalname=*) 
  (| 
    (msDS-AllowedToActOnBehalfOfOtherIdentity=*) 
    (msDS-AllowedToDelegateTo=*) 
    (UserAccountControl:1.2.840.113556.1.4.804:=$bitmask) 
  ) 
  (| 
    (objectcategory=computer) 
    (objectcategory=person) 
    (objectcategory=msDS-GroupManagedServiceAccount) 
    (objectcategory=msDS-ManagedServiceAccount) 
  ) 
) 
"@ -replace "[\s\n]", ''  
  
    $propertylist = @(  
        "servicePrincipalname",   
        "useraccountcontrol",   
        "samaccountname",   
        "msDS-AllowedToDelegateTo",   
        "msDS-AllowedToActOnBehalfOfOtherIdentity"  
    )  
 
    $riskyAccounts = @() 
 
    try { 
        $accounts = Get-ADObject -LDAPFilter $filter -SearchBase $DN -SearchScope Subtree -Properties $propertylist -Server $Server 
    } 
    catch { 
        Write-Warning "Failed to query $Server. Consider investigating seperately. $($_.Exception.Message)" 
    } 
              
    foreach ($account in $accounts) {  
        $isDC = ($account.useraccountcontrol -band $SERVER_TRUST_ACCOUNT) -ne 0  
        $fullDelegation = ($account.useraccountcontrol -band $TRUSTED_FOR_DELEGATION) -ne 0  
        $constrainedDelegation = ($account.'msDS-AllowedToDelegateTo').count -gt 0  
        $isRODC = ($account.useraccountcontrol -band $PARTIAL_SECRETS_ACCOUNT) -ne 0  
        $resourceDelegation = $account.'msDS-AllowedToActOnBehalfOfOtherIdentity' -ne $null  
      
        $acct = [PSCustomobject] @{  
            domain = $Server 
            sAMAccountName = $account.samaccountname  
            objectClass = $account.objectclass          
            isDC = $isDC  
            isRODC = $isRODC  
            fullDelegation = $fullDelegation  
            constrainedDelegation = $constrainedDelegation  
            resourceDelegation = $resourceDelegation  
        }  
 
        if ($fullDelegation) {  
            $riskyAccounts += $acct    
        } 
    }  
 
    return $riskyAccounts 
} 
 
function Get-RiskyServiceAccountsByTrust  
{ 
    [CmdletBinding()]  
    Param  
    ( 
        [switch]$ScanAll 
    ) 
     
    $riskyAccounts = @() 
 
    $trustTypes = $("Inbound", "Bidirectional") 
 
    foreach ($type in $trustTypes) { 
 
        $riskyTrusts = Get-AdTrustsAtRisk -Direction $type -ScanAll:$ScanAll 
 
        foreach ($trust in $riskyTrusts) { 
            $domain = $null 
     
            try { 
                $domain = Get-AdDomain $trust.Name -ErrorVariable eatError -ErrorAction Ignore 
            } catch { 
                write-debug $_.Exception.Message 
            } 
 
            if($eatError -ne $null) { 
                Write-Warning "Couldn't find domain: $($trust.Name)" 
            } 
 
            if ($domain -ne $null) { 
                $accts = Get-ServiceAccountsAtRisk -DN $domain.DistinguishedName -Server $domain.DNSRoot 
 
                foreach ($acct in $accts) { 
                    Write-Debug "Risky: $($acct.sAMAccountName) in $($acct.domain)" 
                }             
 
                $risky = [PSCustomobject] @{  
                    Domain = $trust.Name 
                    Accounts = $accts 
                } 
 
                $riskyAccounts += $risky 
            } 
        } 
    } 
 
    return $riskyAccounts 
} 
 
if ($Collect) { 
   Get-RiskyServiceAccountsByTrust -ScanAll:$ScanAll | Select-Object -expandProperty Accounts | format-table 
}