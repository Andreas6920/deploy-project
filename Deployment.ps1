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
    Install-app -Name "chrome, vlc, 7zip, adobe"
    Start-WinAntiBloat
    Start-WinSecurity

# Message
    msg * "Complete"
