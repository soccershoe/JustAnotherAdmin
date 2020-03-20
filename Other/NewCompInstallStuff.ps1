# Make C:\temp
mdir c:\temp

# Add Ubuntu
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile C:\temp\Ubuntu.appx -UseBasicParsing
Add-AppxPackage C:\temp\Ubuntu.appx

# Install Chocolatey
# --------------------
$isadmin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544'
If ($isadmin -eq $False) {write-host "Please run as Admin"} else {Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))}

# Install .NET Core
# --------------------
# Run a separate PowerShell process because the script calls exit, so it will end the current PowerShell session.
# &powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Channel Current -Version Latest"
choco install dotnetcore-sdk

# Install Powershell Core
choco install powershell-core -y

# Install Git
choco install git -y

# Install Github Desktop
choco install github-desktop -y

# Install Visual Studio Code
choco install vscode -y

# Install Vagrant
choco install vagrant -y

# Install Packer
choco install packer -y

# Install Edge
choco install microsoft-edge -y

# Install Firefox
choco install firefox -y

# Install Chrome
choco install googlechrome -y

# Install 7-zip
choco install 7zip -y




