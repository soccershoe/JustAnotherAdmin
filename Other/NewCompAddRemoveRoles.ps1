Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All
Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 –Online
Disable-WindowsOptionalFeature -FeatureName Printing-XPSServices-Features -Online
Disable-WindowsOptionalFeature -FeatureName FaxServicesClientPackage -Online
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient
Disable-WindowsOptionalFeature -Online -FeatureName WorkFolders-Client
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
