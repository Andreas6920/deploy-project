# Ensure admin rights
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    
    # Relaunch as an elevated process
    $Script = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy RemoteSigned", "-File `"$Script`""}

# Bypass ExecutionPolicy
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Timestamps for actions
    Function Get-LogDate {return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]")}

# Opgrader TLS
Write-Host "$(Get-LogDate)`t    Opgradere TLS." -ForegroundColor Green
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor ([System.Net.ServicePointManager]::SecurityProtocol)

# Set DNS to cloudflare for optimized performance
Write-Host "$(Get-LogDate)`t    Opsætter DNS til Cloudflare." -ForegroundColor Green
if($env:USERDNSDOMAIN -eq $null){
    (Get-NetAdapter -Physical) | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses ("1.1.1.1","1.0.0.1") }}


# Prompt-funktion
function Ask-YesNo ($question) {
    do {
        Write-Host "$(Get-LogDate)`t$question (y/n)" -NoNewline
        $response = Read-Host " "
        $response = $response.Trim().ToLower()
    } while ($response -notin "y", "n")
    return ($response -eq "y")
}

# Spørg brugeren
$InstallOffice   = Ask-YesNo "Install Microsoft Office 2016?"
$ActivateOffice  = Ask-YesNo "Activate Microsoft Office?"
$ActivateWindows = Ask-YesNo "Activate Windows?"

# Wait for internet
    Write-Host "$(Get-LogDate)`t    Venter på internet" -ForegroundColor Green -NoNewline
    do{Write-Host "." -ForegroundColor Green -NoNewline; sleep 3}until((Test-Connection github.com -Quiet) -eq $true)
    Write-host " [VERIFICERET]" -ForegroundColor Green

Write-Host "$(Get-LogDate)`tOPSÆTNING STARTER" -f Green

# Configure Windows
    Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/Winoptimizer.ps1" | Invoke-Expression
        Start-WinAntiBloat
        Start-WinSettings
        Start-WinSecurity
        
# Install Apps
    Install-App -Name "Chrome, 7zip, VLC"
    if ($InstallOffice) {Install-App -Name "Office"}
    if ($ActivateOffice) { Write-Host "$(Get-LogDate)`t    - Aktiverer Office..." -ForegroundColor Yellow; & ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook}
    if ($ActivateWindows) {Write-Host "$(Get-LogDate)`t    - Aktiverer Windows..." -ForegroundColor Yellow; & ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID}

# Install Drivers
    Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Andreas6920/Other/refs/heads/main/scripts/SDI-Tool.ps1" | Invoke-Expression

# Message
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $btn = [System.Windows.Forms.MessageBoxButtons]::OK
    $ico = [System.Windows.Forms.MessageBoxIcon]::Information
    $Title = 'Microsoft Windows Deployment'
    $Message = 'Deployment complete!'
    $Return = [System.Windows.Forms.MessageBox]::Show($Message, $Title, $btn, $ico)
