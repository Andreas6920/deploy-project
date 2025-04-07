# Start
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Funktion til at få det aktuelle tidspunkt
    function Get-LogDate {return (Get-Date -f "yyyy/MM/dd HH:mm:ss")}

# Wait for internet
    Write-Host "$(Get-LogDate)`t    Afventer internet forbindelse" -ForegroundColor Green -NoNewline
    do{Write-Host "." -ForegroundColor Green -NoNewline; sleep 3}until((Test-Connection github.com -Quiet) -eq $true)
    Write-host " [VERIFICERET]" -ForegroundColor Green

# Configure Windows
    irm https://git.io/JzrB5 | IEX; 
    Start-WinAntiBloat
    Start-WinSettings
    Start-WinSecurity
    Install-App -Name "Office, Chrome, 7zip, VLC" -EnableAutoupdate

# Activation 
    Write-Host "$(Get-LogDate)`t    Activation:" -f Green

    Write-Host "$(Get-LogDate)`t        - Office" -ForegroundColor Yellow
    & ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook

    Write-Host "$(Get-LogDate)`t        - Windows" -ForegroundColor Yellow
    & ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID


# Install printer
    irm https://raw.githubusercontent.com/Andreas6920/print_project/refs/heads/main/print-module.psm1 | IEX
    Install-Printer -All -NavisionPrinter

# Install Endpoint Protection

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
    Unregister-ScheduledTask -TaskName "post-reboot-setup" -Confirm:$false

# Setup Desktop icons
    Write-Host "$(Get-LogDate)`t    Indstiller skrivebordsikoner" -ForegroundColor Green
    $desktop = [Environment]::GetFolderPath("Desktop") 
    Get-ChildItem $desktop | % {Remove-Item $_.FullName; Start-Sleep -S 1}
    Copy-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" -Destination $desktop
    Copy-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Outlook (classic).lnk" -Destination $desktop
        $path = Join-path $desktop -ChildPath "Outlook (classic).lnk"
        Rename-Item -Path $path -NewName "Outlook.lnk"
    Copy-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Word.lnk" -Destination $desktop
    Copy-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk" -Destination $desktop

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

Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$balmsg.BalloonTipText = "Deployment scriptet er nu fuldendt."
$balmsg.BalloonTipTitle = "Deployment Script"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(20000)