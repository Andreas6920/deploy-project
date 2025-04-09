# Start
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Funktion til at få det aktuelle tidspunkt
    function Get-LogDate {return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]")}

# Wait for internet
    Write-Host "$(Get-LogDate)`t    Awaiting internet connectivity" -ForegroundColor Green -NoNewline
    do{Write-Host "." -ForegroundColor Green -NoNewline; sleep 3}until((Test-Connection github.com -Quiet) -eq $true)
    Write-host " [GRANTED]" -ForegroundColor Green

# Install printer
    Invoke-RestMethod https://raw.githubusercontent.com/Andreas6920/print_project/refs/heads/main/print-module.psm1 | Invoke-Expression
    Install-Printer -All -NavisionPrinter

# Configure Windows
    Invoke-RestMethod "https://git.io/JzrB5" | Invoke-Expression; 
    Start-WinAntiBloat
    Start-WinSettings
    Start-WinSecurity
    Install-App -Name "Office, Chrome, 7zip, VLC" -EnableAutoupdate

# Activation as background job
        Write-Host "$(Get-LogDate)`t    Activates as background job..." -ForegroundColor Green

        $activationJob = Start-Job -ScriptBlock {
            #Office
            & ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook
            
            Start-Sleep -S 10
            
            # Windows
            & ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID}

# Install Endpoint Protection
    # Placeholder

# Action1
    
    # Download
    Write-Host "$(Get-LogDate)`t    Action1 installation:" -ForegroundColor Green
    Write-Host "$(Get-LogDate)`t        - Downloader" -ForegroundColor Yellow
    $link = "https://app.eu.action1.com/agent/51fced32-7e39-11ee-b2da-3151362a23c3/Windows/agent(My_Organization).msi"
    $path = join-path -Path $env:TMP -ChildPath (split-path $link -Leaf)
    (New-Object net.webclient).Downloadfile("$link", "$path") | Out-Null
    
    # Install
    Write-Host "$(Get-LogDate)`t        - Installere" -ForegroundColor Yellow
    msiexec /i $path /quiet
    
    # Confirming installation
    do{Start-Sleep -S 1; Write-Host "." -NoNewline -ForegroundColor Yellow}until(get-service -Name "Action1 Agent" -ErrorAction SilentlyContinue)

# Remove Scheduled task
    Write-Host "$(Get-LogDate)`t    Rydder op." -ForegroundColor Green
    Unregister-ScheduledTask -TaskName "deploy-project-part2" -Confirm:$false

# Setup Desktop icons
    Write-Host "$(Get-LogDate)`t    Indstiller skrivebordsikoner" -ForegroundColor Green

    # Fjerner gamle ikoner
        $Desktops = @(
        "$env:USERPROFILE\Desktop",
        "C:\Users\Public\Desktop") + (Get-ChildItem "C:\Users" -Directory).FullName | ForEach-Object { "$_\Desktop" }
        foreach ($Path in $Desktops) {
            if (Test-Path $Path) {
                Get-ChildItem -Path $Path -Filter *.lnk -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                    Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                    Write-Host "Removed: $($_.FullName)" -ForegroundColor Green}}
            
                Copy-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" -Destination $Path
                Copy-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Outlook (classic).lnk" -Destination $Path
                    $OutlookShortcut = Join-path $Path -ChildPath "Outlook (classic).lnk"
                    Rename-Item -Path $OutlookShortcut -NewName "Outlook.lnk"
                Copy-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Word.lnk" -Destination $Path
                Copy-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk" -Destination $Path  
                
                
                }

    # Indsæt nye ikoner
    
<#
# Pin icons to taskbar

    Write-Host "$(Get-LogDate)`t    Indstiller taskbar pins" -ForegroundColor Green
    
    Stop-Input
    sleep -s 2
    $app = New-Object -ComObject Shell.Application
    $key = New-Object -com Wscript.Shell    
        
    $app.open("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\")
    sleep -s 1
    $key.SendKeys("{DOWN}")
    sleep -s 1
    $key.SendKeys("Google")
    sleep -s 1
    $key.SendKeys("+{F10}")
    sleep -s 1
    $key.SendKeys("k")
    sleep -s 1
    $key.SendKeys("Outlook")
    sleep -s 1
    $key.SendKeys("+{F10}")
    sleep -s 1
    $key.SendKeys("k")
    sleep -s 1
    $key.SendKeys("word")
    sleep -s 1
    $key.SendKeys("+{F10}")
    sleep -s 1
    $key.SendKeys("k")
    sleep -s 1
    $key.SendKeys("excel")
    sleep -s 1
    $key.SendKeys("+{F10}")
    sleep -s 1
    $key.SendKeys("k")
    sleep -s 1
    $key.SendKeys("%{F4}")
    sleep -s 2

    Start-Input
#>

# Vent på at aktivering er færdig
    Write-Host "$(Get-LogDate)`t    Afventer afslutning af aktivering..." -ForegroundColor Green
    Wait-Job $activationJob | Out-Null
    Receive-Job $activationJob | Out-Null
    Remove-Job $activationJob | Out-Null
    Write-Host "$(Get-LogDate)`t        - Aktivering fuldført." -ForegroundColor Green


Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$balmsg.BalloonTipText = "Deployment scriptet er nu fuldendt."
$balmsg.BalloonTipTitle = "Deployment Script"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(20000)