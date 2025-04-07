# Reinsure admin rights
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    # Relaunch as an elevated process
    $Script = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy RemoteSigned", "-File `"$Script`""
}

# Start
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Timestamps for actions
Function Get-LogDate {
            return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]")}

# Configure Windows
    Write-Host "[$(Get-LogDate)]`t- Opsætter Windows:" -ForegroundColor Green
    $url = "https://git.io/JzrB5"
    
    irm $url | iex

    Start-WinAntiBloat
    Start-WinOptimizer
    Start-WinSecurity
    Install-App -Name "Office, Chrome,7zip,VLC" -MicrosoftOffice2016Retail -EnableAutoupdate


# Install printer

    $url = "https://raw.githubusercontent.com/Andreas6920/print_project/refs/heads/main/print-module.psm1"
    $path = Join-Path -Path $env:TMP -ChildPath "Printer-Installation.ps1"
    irm $url -OutFile $path
    Import-Module $path

    Install-Printer -All -NavisionPrinter

# Install Applications

    # Install Chocolatey
    $url = "https://community.chocolatey.org/install.ps1"
    $path = Join-Path -Path $env:TMP -ChildPath "ChocolateyInstall.ps1"
    $logpath = Join-Path -Path $env:TMP -ChildPath "ChocolateyLogs.txt"
    Write-Host "[$(Get-LogDate)]`t- Preparing Application Installation." -ForegroundColor Green
    irm $url -OutFile $path
    . $path | Out-Null

    ## Install applications with chocolatey
    Write-Host "[$(Get-LogDate)]`t- Installing Applications:" -ForegroundColor Green
    Write-Host "[$(Get-LogDate)]`t`t- Removing office bloat" -ForegroundColor Yellow
        $ProgressPreference = "SilentlyContinue" # hide progressbar
        "Microsoft.MicrosoftOfficeHub", "Microsoft.Office.OneNote" | ForEach-Object {
        if (Get-AppxPackage | Where-Object Name -Like $_) {
            Get-AppxPackage | Where-Object Name -Like $_ | Remove-AppxPackage; Start-Sleep -Seconds 5}}
    Write-Host "[$(Get-LogDate)]`t`t- Installing office (This step may take a while...)" -ForegroundColor Yellow
    choco install microsoft-office-deployment --params="'/Product:ProfessionalRetail /64bit /ProofingToolLanguage:da-dk,en-us'" -y --log-file=$logpath | Out-Null
    Write-Host "[$(Get-LogDate)]`t`t- Installing Chrome" -ForegroundColor Yellow
    choco install googlechrome --ignore-checksums -y --log-file=$logpath | Out-Null
    Write-Host "[$(Get-LogDate)]`t`t- Installing VLC" -ForegroundColor Yellow
    choco install vlc -y --log-file=$logpath | Out-Null
    Write-Host "[$(Get-LogDate)]`t`t- Installing 7-zip" -ForegroundColor Yellow
    choco install 7zip.install -y --log-file=$logpath | Out-Null
    $ProgressPreference = "Continue" #unhide progressbar
    Write-Host "[$(Get-LogDate)]`t`t- Activating Office" -ForegroundColor Yellow
    start-sleep -s 30; & ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook
    Write-Host "[$(Get-LogDate)]`t`t- Activating Windows" -ForegroundColor Yellow
    start-sleep -s 10; & ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID

# Install Endpoint Protection

# Action1
    irm "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/ActionOne.ps1" | iex

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
