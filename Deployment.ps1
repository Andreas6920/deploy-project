# TLS upgrade
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set DNS if NOT domain member
    if($env:USERDNSDOMAIN -eq $null){
    $nic = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
    Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses "1.1.1.1,1.0.0.1" | out-null}

# Start Windows bloat cleaner
    $Path1 = "$env:TMP\wintools.ps1"
    iwr -useb https://git.io/JzrB5 -O $Path1
    ipmo $Path1;
    $Path2 = "$env:TMP\winclean.ps1"
    iwr -useb "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/scripts/win_antibloat.ps1" -O $Path2
    ipmo $Path2;

# Start installation of common apps
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
	$config = 
	'<?xml version="1.0" encoding="utf-8"?>
	<packages>
	<package id="googlechrome" />
	<package id="vlc" />
	<package id="7zip.install" />
	<package id="adobereader" />
	</packages>'
	set-content $config -Path c:\packages.config
    choco install c:\packages.config --yes --ignore-checksums -r
       
# Message
    Start-Sleep -S 120
    msg * "Complete"