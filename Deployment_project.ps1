# TLS upgrade
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set DNS if NOT domain member
    if($env:USERDNSDOMAIN -eq $null){
    $ProgressPreference = "SilentlyContinue"
    Start-Sleep -S 1
    $nic = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
    Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses "1.1.1.1,1.0.0.1" | out-null
    Start-Sleep -S 1
    $ProgressPreference = "Continue"}

# Install windows-optimizer
    $Link = "https://git.io/JzrB5" 
    $Path = join-path -Path $env:TMP -ChildPath "WinOptimizer.ps1"
    Invoke-WebRequest -Uri $Link -OutFile $Path -UseBasicParsing
    Import-Module $path
    
# Intall apps
    
    Start-Job -Name Install -ScriptBlock { Install-app -Name "chrome, vlc, 7zip, adobe, office2016"}
    Start-WinAntiBloat
    Start-WinSecurity

# Set default apps
    # default browser to chrome    
    # default pdf to adbobe reader
    # defualt video to vlc
    # default zip, rar, img to 7zip

# Install All printers
    # Install-Printer -Number 20
    # Install-Printer -Department Salg
    # Install-Printer -All
    # Install-Printer -Test

# Activate Office and Windows
    & ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /HWID
    & ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /Ohook 
