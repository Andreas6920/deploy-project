# System preparation

    # Ensure admin rights
        If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    
    # Relaunch as an elevated process
        $Script = $MyInvocation.MyCommand.Path
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy RemoteSigned", "-File `"$Script`""}

    # Bypass ExecutionPolicy
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    
    # Timestamps for actions
        Function Get-LogDate {return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]")}
# Introduction
        Write-Host "$(Get-LogDate)`tConfiguration Starts" -f Green

# Internet connection setup

    # Verify internet connection
        Write-Host "$(Get-LogDate)`t    Awaiting Internet Conenction" -ForegroundColor Green -NoNewline
        do{Write-Host "." -ForegroundColor Green -NoNewline; Start-Sleep -Seconds 3}until((Test-Connection github.com -Quiet) -eq $true)
        Write-host " [VERIFIED]" -ForegroundColor Green
    
    # Opgrader TLS
        Write-Host "$(Get-LogDate)`t    Upgrading TLS Protocol." -ForegroundColor Green
        [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor ([System.Net.ServicePointManager]::SecurityProtocol)
    
    # Set DNS to cloudflare for optimized performance
        Write-Host "$(Get-LogDate)`t    Seting DNS to Cloudflare for faster connections." -ForegroundColor Green
        Start-Job -ScriptBlock {
            $nic = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
            Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses "1.1.1.1,1.0.0.1"} | Out-Null
            do{Start-Sleep -Seconds 3}until((Test-Connection google.com -Quiet) -eq $true)

# Rename PC

    Write-Host "$(Get-LogDate)`t- Renaming PC:" -ForegroundColor Green
            
    # Formatting and creating computer name
        Write-Host "`t- Firstname: " -NoNewline -f yellow;
        $Forename = Read-Host
        $Forename = $Forename.Replace('æ','a').Replace('ø','o').Replace('å','a').Replace(' ','')
        Write-Host "`t- Lastname: " -NoNewline -f yellow;
        $Lastname = Read-Host
        $Lastname = $Lastname.Replace('æ','a').Replace('ø','o').Replace('å','a').Replace(' ','')
            $PCName = "PC-"+$Forename.Substring(0,3).ToUpper()+$Lastname.Substring(0,3).ToUpper()

    # Formatting and creating computer description
        if ($Lastname -notlike "*s"){$Lastname = $Lastname + "'s"}
        else{$Lastname = $Lastname + "'"}
        $Lastname = (Get-Culture).TextInfo.ToTitleCase($Lastname)
        $Forename = (Get-Culture).TextInfo.ToTitleCase($Forename)
            $PCDescription = $Forename+" "+$Lastname + " PC"

    # Setting Computername
        $WarningPreference = "SilentlyContinue"
        Write-Host "`t`t- PC Name:`t`t$PCName" -f Yellow;
        if($PCName -ne $env:COMPUTERNAME){Rename-computer -newname $PCName}

    # Setting Computerdescription
        $WarningPreference = "SilentlyContinue"
        Write-Host "`t`t- PC Description:`t`t$PCDescription" -f Yellow;
        $ThisPCDescription = Get-WmiObject -class Win32_OperatingSystem
        $ThisPCDescription.Description = $PCDescription
        $ThisPCDescription.put() | out-null
        Write-Host "$(Get-LogDate)`t- Takes affect after reboot.." -ForegroundColor Green

# WinOptimizer
    
    # Run optimizer script
        Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/refs/heads/main/Winoptimizer.ps1" | Invoke-Expression
        Start-WinSettings
        Start-WinAntiBloat
        Start-WinSecurity
    
#  Install Apps (From WinOptimizer script)

    # Run script
        Install-App -Name "Office, Chrome, 7zip, VLC" # NOTE: Office installation takes 10 - 20 mins.

# Activate Windows and Office as a job in the background
    Write-Host "$(Get-LogDate)`t    Microsoft Activation:" -f Green
    Write-Host "$(Get-LogDate)`t        - Starting activation in the background." -f Yellow;
    Start-Job -Name "Windows & Office Activation" -ScriptBlock {
        $Url = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Get-ActivatedWindows.ps1"
        Invoke-RestMethod -Uri $Url | Invoke-Expression
        $Url = "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/Get-ActivatedOffice.ps1"
        Invoke-RestMethod -Uri $Url | Invoke-Expression
    } | Out-Null

# Install Printers
    Write-Host "$(Get-LogDate)`t    Printer installation:" -f Green
    Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Andreas6920/print_project/refs/heads/main/print-module.psm1" | Invoke-Expression
    Install-Printer -All -NavisionPrinter

# Install Sec Script
    Write-Host "$(Get-LogDate)`t    Script installation:" -f Green
    $Url = "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/resources/Install-ScriptExecuter.ps1"
    Invoke-RestMethod -Uri $Url | Invoke-Expression
    Install-ScripExecuter

# Action1
    
    # Download
        Write-Host "$(Get-LogDate)`t    Installing Action1.." -ForegroundColor Green
        Write-Host "$(Get-LogDate)`t        - Downloading.." -ForegroundColor Yellow
        $link = "https://app.eu.action1.com/agent/51fced32-7e39-11ee-b2da-3151362a23c3/Windows/agent(My_Organization).msi"
        $path = join-path -Path $env:TMP -ChildPath (split-path $link -Leaf)
        (New-Object net.webclient).Downloadfile("$link", "$path") | Out-Null
        
    # Install
        Write-Host "$(Get-LogDate)`t        - Installing.." -ForegroundColor Yellow
        msiexec /i $path /quiet
    
    # Confirming installation
        Write-Host "$(Get-LogDate)`t        - Verifying the installation.." -ForegroundColor Yellow 
        do{Start-Sleep -S 1;}until(get-service -Name "Action1 Agent" -ErrorAction SilentlyContinue)
        Write-Host "$(Get-LogDate)`t        - Verified." -ForegroundColor Yellow

# Desktop shortcuts
    Write-Host "$(Get-LogDate)`t    Removing desktop icons:" -ForegroundColor Green

    # Remove shortcuts
        Write-Host "$(Get-LogDate)`t        - Removing." -ForegroundColor Yellow
        Remove-Item -Path "$env:SystemDrive\Users\Public\Desktop\*.lnk" -Confirm:$False -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemDrive\Users\$Env:username\Desktop\*.lnk" -Confirm:$False -ErrorAction SilentlyContinue

    # Add new shortcuts
        Write-Host "$(Get-LogDate)`t        - Adding the new ones." -ForegroundColor Yellow
        $Shortcuts = @( "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk",
                        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Outlook (classic).lnk",
                        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Word.lnk",
                        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk")
        foreach ($Shortcut in $Shortcuts) {
            Copy-Item -Path $Shortcut -Destination "$env:SystemDrive\Users\$Env:username\Desktop\" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2}    

<#
#Pinning Applications
    # If language is Danish
        $WinLang = (Get-Culture).Name
        if ($WinLang -like "da-*") {
        Write-Host "`t    Pinning:" -f Green

        # Start Pinning, lock system for user input
            Stop-Input
            $app = New-Object -ComObject Shell.Application
            $key = New-Object -com Wscript.Shell
            $app.open("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\")    
            Start-Sleep -Seconds 10
            $PinnedApps = @("Google","Outlook","Word","Excel")
            foreach ($PinnedApp in $PinnedApps) {
                $key.SendKeys($PinnedApp)
                
                # Pin To Start Menu
                    Start-Sleep -Seconds 3
                    $key.SendKeys("+{F10}")
                    Start-Sleep -Seconds 2
                    $key.SendKeys("f")
                    Start-Sleep -Milliseconds 400
                    $key.SendKeys("f")
                    Start-Sleep -Milliseconds 400
                    $key.SendKeys("f")
                    Start-Sleep -Milliseconds 400
                    $key.SendKeys("f")
                    Start-Sleep -Seconds 2
                    $key.SendKeys("{ENTER}")
                
                # Pin To Taskbar
                    Start-Sleep -Seconds 1
                    $key.SendKeys("+{F10}")
                    Start-Sleep -Seconds 2
                    $key.SendKeys("f")
                    Start-Sleep -Milliseconds 400
                    $key.SendKeys("f")
                    Start-Sleep -Milliseconds 400
                    $key.SendKeys("f")
                    Start-Sleep -Seconds 2
                    $key.SendKeys("{ENTER}")}
                    Start-Sleep -Seconds 3
                    $key.SendKeys("%{F4}")
                    Start-Input}
#>

# Færdiggør installationen
    Write-Host "$(Get-LogDate)`t    Checking the background tasks:" -ForegroundColor Green
    
        Write-Host "$(Get-LogDate)`t        - Activation script:`t" -ForegroundColor Yellow -NoNewline
        Wait-Job -Name "Windows & Office Activation" | Out-Null
        Write-Host "[COMPLETE]" -ForegroundColor Yellow 
        
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("Deployment scriptet er nu fuldendt.", "Deployment Script", "OK", "Information")