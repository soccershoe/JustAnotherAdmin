<#
This Script returns the current registry settings for encryption
 - Protocols
 - Cipthers
 - Hashes
 - KeyExchangeAlgorithms
 #>

$HiveRoot = "Registry::HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL"

#Get Protocols
$Section = "Protocols"
$Protocols = @("Multi-Protocol Unified Hello","PCT 1.0","SSL 2.0","SSL 3.0","TLS 1.0","TLS 1.1","TLS 1.2")
$ClientTypes = @("Client","Server")

write-host "Getting Protocols"
write-host "-----------------"

foreach ($Protocol in $Protocols)
{
  $RegEntry = "$HiveRoot\$Section\$Protocol"

  If (Test-Path -Path $RegEntry)
  {
    write-host "$Protocol"

    foreach ($ClientType in $ClientTypes)
    {
      #Get DisabledByDefault
      $exists = Get-ItemProperty -Path "$RegEntry\$ClientType" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
      If (($exists -ne $null) -and ($exists.Length -ne 0))
      {
        $RegValue = $exists.DisabledByDefault
        If ($RegValue -eq 0)
        {
          $RegValueTranslate = "False"
        }
        else
        {
          $RegValueTranslate = "True"
        }

        write-host " - $ClientType DisabledByDefault = $RegValueTranslate($regvalue)"
      }

      #Get Enabled
      $exists = Get-ItemProperty -Path "$RegEntry\$ClientType" -Name "Enabled" -ErrorAction SilentlyContinue
      If (($exists -ne $null) -and ($exists.Length -ne 0))
      {
        $RegValue = $exists.Enabled
        If ($RegValue -eq 0)
        {
          $RegValueTranslate = "False"
        }
        else
        {
          $RegValueTranslate = "True"
        }

        write-host " - $ClientType Enabled = $RegValueTranslate($regvalue)"
      }
    }
  }
  else
  {
    write-host "$Protocol not found" -ForegroundColor Yellow
  }
}

#Get Secure Ciphers
$SSection = "Ciphers"
$SCiphers = @("AES 128/128","AES 256/256","Triple DES 168")

write-host ""
write-host "Getting Secure Ciphers"
write-host "-----------------"


foreach ($SCipher in $SCiphers)
{
  $RegEntry = "$HiveRoot\$SSection\$SCipher"
  
  If (Test-Path -Path $RegEntry)
  {
    $RegSCipher = Get-ItemProperty -path $RegEntry
    If ($RegSCipher.Enabled -eq 0)
    {
      $RegSCipherEnabled = "False"
      write-host "$SCipher - Enabled = $RegSCipherEnabled" -ForegroundColor Red
    }
    else
    {
      $RegSCipherEnabled = "True"
      write-host "$SCipher - Enabled = $RegSCipherEnabled" -ForegroundColor Green
    }
  }
  else
  {
    write-host "$SCipher registry entry not found"  -ForegroundColor Yellow
  }
}

#Get Insecure Ciphers
$ISection = "Ciphers"
$ICiphers = @("DES 56/56","NULL","RC2 128/128","RC2 40/128","RC2 56/128","RC4 40/128","RC4 56/128","RC4 64/128","RC4 128/128")
write-host ""
write-host "Getting Insecure Ciphers"
write-host "-----------------"


foreach ($ICipher in $ICiphers)
{
  $RegEntry = "$HiveRoot\$ISection\$ICipher"
  
  If (Test-Path -Path $RegEntry)
  {
    $RegICipher = Get-ItemProperty -path $RegEntry
    If ($RegICipher.Enabled -eq 0)
    {
      $RegICipherEnabled = "False"
      write-host "$ICipher - Enabled = $RegICipherEnabled" -ForegroundColor Green
    }
    else
    {
      $RegICipherEnabled = "True"
      write-host "$ICipher - Enabled = $RegICipherEnabled" -ForegroundColor Red
    }
  }
  else
  {
    write-host "$ICipher registry entry not found" -ForegroundColor Yellow
  }
}


#Get Hashes
$Section = "Hashes"
$Hashes = @("MD5","SHA","SHA256","SHA384","SHA512")

write-host ""
write-host "Getting Hashes"
write-host "--------------"


foreach ($Hash in $Hashes)
{
  $RegEntry = "$HiveRoot\$Section\$Hash"
  
  If (Test-Path -Path $RegEntry)
  {
    $RegHash = Get-ItemProperty -path $RegEntry
    If ($RegHash.Enabled -eq 0)
    {
      $RegHashEnabled = "False"
      If ($Hash -like 'MD5') {write-host "$Hash - Enabled = $RegHashEnabled" -ForegroundColor Green} else {write-host "$Hash - Enabled = $RegHashEnabled" -ForegroundColor Red}
    }
    else
    {
      $RegHashEnabled = "True"
      If ($Hash -like 'MD5') {write-host "$Hash - Enabled = $RegHashEnabled" -ForegroundColor Red} else {write-host "$Hash - Enabled = $RegHashEnabled" -ForegroundColor Green}
    }
  }
  else
  {
    write-host "$Hash registry entry not found" -ForegroundColor Yellow
  }
}

#Get KeyExchangeAlgorithms
$Section = "KeyExchangeAlgorithms"
$KeyExchanges = @("Diffie-Hellman","ECDH","PKCS")

write-host ""
write-host "Getting KeyExchange"
write-host "-------------------"


foreach ($KeyExchange in $KeyExchanges)
{
  $RegEntry = "$HiveRoot\$Section\$KeyExchang"
  
  If (Test-Path -Path $RegEntry)
  {
    $RegKeyExchange = Get-ItemProperty -path $RegEntry
    If ($RegKeyExchange.Enabled -eq 0)
    {
      $RegKeyExchangeEnabled = "False"
      write-host "$KeyExchange - Enabled = $RegKeyExchangeEnabled" -ForegroundColor Red
    }
    else
    {
      $RegKeyExchangeEnabled = "True"
      write-host "$KeyExchange - Enabled = $RegKeyExchangeEnabled" -ForegroundColor Green
    }
  }
  else
  {
    write-host "$KeyExchange registry entry not found" -ForegroundColor Yellow
  }
}
