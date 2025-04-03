# Reinsure admin rights
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        # Relaunch as an elevated process
        $Script = $MyInvocation.MyCommand.Path
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy RemoteSigned", "-File `"$Script`""
    }

# Start
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Funktion til at få det aktuelle tidspunkt
    function Get-LogDate {return (Get-Date -f "yyyy/MM/dd HH:mm:ss")}

# Wait for internet
    Write-Host "[$(Get-LogDate)]`t- Venter på internet" -ForegroundColor Green -NoNewline
    do{Write-Host "." -ForegroundColor Green -NoNewline; sleep 3}until((Test-Connection github.com -Quiet) -eq $true)
    Write-host " [VERIFICERET]" -ForegroundColor Green

# Configure Windows
    irm https://git.io/JzrB5 | IEX; 
    Start-WinAntiBloat
    Start-WinSecurity
    Install-App -Name "Office, Chrome, 7zip, VLC" -EnableAutoupdate
    
    Write-Host "$(Get-LogDate)`t    Activating Office" -f Green
    & ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook

# Install printer
    irm https://raw.githubusercontent.com/Andreas6920/print_project/refs/heads/main/print-module.psm1 | IEX
    Install-Printer -All -NavisionPrinter

# Install Endpoint Protection

# Action1
    
    # Download
    Write-Host "[$(Get-LogDate)]`t- Action1 Installation" -ForegroundColor Green
    Write-Host "$(Get-LogDate)`t        - Henter ned" -ForegroundColor Yellow
    $link = "https://app.eu.action1.com/agent/51fced32-7e39-11ee-b2da-3151362a23c3/Windows/agent(My_Organization).msi"
    $path = join-path -Path $env:TMP -ChildPath (split-path $link -Leaf)
    (New-Object net.webclient).Downloadfile("$link", "$path") | Out-Null
    
    # Install
    Write-Host "$(Get-LogDate)`t        - Opsætter" -ForegroundColor Yellow -NoNewline
    msiexec /i $path /quiet
    
    # Confirming installation
    do{Start-Sleep -S 1; Write-Host "." -NoNewline -ForegroundColor Yellow}until(get-service -Name "Action1 Agent" -ErrorAction SilentlyContinue)

# Remove Scheduled task
    Unregister-ScheduledTask -TaskName "post-reboot-setup" -Confirm:$false

# Message
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $btn = [System.Windows.Forms.MessageBoxButtons]::OK
    $ico = [System.Windows.Forms.MessageBoxIcon]::Information
    $Title = 'Microsoft Windows Deployment'
    $Message = 'Deployment complete!'
    $Return = [System.Windows.Forms.MessageBox]::Show($Message, $Title, $btn, $ico)
