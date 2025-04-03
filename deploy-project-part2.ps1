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

# Configure Windows
    irm https://git.io/JzrB5 | IEX; 
    Start-WinAntiBloat
    Start-WinSecurity
    Install-App -Name "Office, Chrome, 7zip, VLC" -EnableAutoupdate
    
    Write-Host "[$(Get-LogDate)]`t`t- Activating Office" -ForegroundColor Yellow
    start-sleep -s 30; & ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook

# Install printer

    $url = "https://raw.githubusercontent.com/Andreas6920/print_project/refs/heads/main/print-module.psm1"
    $path = Join-Path -Path $env:TMP -ChildPath "Printer-Installation.ps1"
    irm $url -OutFile $path
    Import-Module $path

    Install-Printer -All -NavisionPrinter

# Install Endpoint Protection

# Action1
    irm "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ActionOne.ps1" | iex


# Remove Scheduled task

# Message
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $btn = [System.Windows.Forms.MessageBoxButtons]::OK
    $ico = [System.Windows.Forms.MessageBoxIcon]::Information
    $Title = 'Microsoft Windows Deployment'
    $Message = 'Deployment complete!'
    $Return = [System.Windows.Forms.MessageBox]::Show($Message, $Title, $btn, $ico)
