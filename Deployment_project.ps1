﻿# TLS upgrade
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Install Modules
    Write-Host "Installing modules" -NoNewline
    $modulepath = $env:PSmodulepath.split(";")[1]
    $modules = @("https://raw.githubusercontent.com/Andreas6920/print_project/main/res/PrinterScript.psm1", "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/functions/WinOptimizer.psm1")
    Foreach ($module in $modules) {
    # prepare folder
        $file = (split-path $module -Leaf)
        $filename = $file.Replace(".psm1","").Replace(".ps1","").Replace(".psd","")
        $filedestination = "$modulepath/$filename/$file"
        $filesubfolder = split-path $filedestination -Parent
        If (!(Test-Path $filesubfolder )) {New-Item -ItemType Directory -Path $filesubfolder -Force | Out-Null; Start-Sleep -S 1}
    # Download module
        (New-Object net.webclient).Downloadfile($module, $filedestination)
    # Install module
        if (Get-Module -ListAvailable -Name $filename){ Import-module -name $filename; Write-Host "." -NoNewline}
    else {Write-Host "!"}}

# Set DNS if NOT domain member
    if($env:USERDNSDOMAIN -eq $null){
    $ProgressPreference = "SilentlyContinue"
    Start-Sleep -S 1
    $nic = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
    Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses "1.1.1.1,1.0.0.1" | out-null
    Start-Sleep -S 1
    $ProgressPreference = "Continue"}

# Intall apps
    Install-app -Name "chrome, vlc, 7zip, adobe, office2016"
    
# Install windows-optimizer
    Start-WinAntiBloat

# Enhance Winodws Security
    Start-WinSecurity

# Install Printers
    Start-PrinterScript -Department Kontor


# Set default apps
    irm -useb "https://raw.githubusercontent.com/DanysysTeam/PS-SFTA/master/SFTA.ps1" -O "$env:TMP\1.ps1"; ipmo "$env:TMP\1.ps1";

    # default browser to chrome 
        Set-PTA ChromeHTML http
        Set-PTA ChromeHTML https
    # default pdf to adbobe reader
        Set-FTA AcroExch.Document.DC .pdf
    # default video to vlc
    # default zip, rar, img to 7zip

# Install All printers
        # Install-Printer -Number 20
        # Install-Printer -Department Salg
        # Install-Printer -All
        # Install-Printer -Test

# Activate Windows if it's not acitvated yet
    Write-host "`t`t- Checking if Windows is activated" -f Yellow
    $licenseStatus = Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object { $_.ApplicationID -eq "55c92734-d682-4d71-983e-d6ec3f16059f" } | Select-Object -Property LicenseStatus
    if ($licenseStatus.LicenseStatus -eq  1){Write-host "`t`t`t- It is already activated." -f Yellow} else{Write-host "`t`t`t- It's not. starting activation." -f Yellow; & ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /HWID}

# Activate Microsoft Office 2016, but waiting for it to be finished installing
    Write-host "`t`t- Waiting for Microsoft office to be installed" -f Yellow
    do{Start-Sleep -S 10}until((test-path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk") -eq $true) Start-Sleep -S 30
    Write-host "`t`t`t- Activating" -f Yellow
    & ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /Ohook 

$licenseStatus = Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object { $_.ApplicationID -eq "55c92734-d682-4d71-983e-d6ec3f16059f" } | Select-Object -Property LicenseStatus
if ($licenseStatus.LicenseStatus -eq  1){} else{Write-host "`t`t`t- It's not. starting activation." -f Yellow; & ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /HWID}

