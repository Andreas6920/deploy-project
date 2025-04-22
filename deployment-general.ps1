# Ensure admin rights
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    
# Relaunch as an elevated process
    $Script = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy RemoteSigned", "-File `"$Script`""}

# Bypass ExecutionPolicy
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Timestamps for actions
    Function Get-LogDate {return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]")}

# Wait for internet
    Write-Host "$(Get-LogDate)`t    Venter på internet" -ForegroundColor Green -NoNewline
    do{Write-Host "." -ForegroundColor Green -NoNewline; sleep 3}until((Test-Connection github.com -Quiet) -eq $true)
    Write-host " [VERIFICERET]" -ForegroundColor Green

# Start Script
    Write-Host "$(Get-LogDate)`tOPSÆTNING STARTER" -f Green

# Opgrader TLS
    Write-Host "$(Get-LogDate)`t    Opgradere TLS." -ForegroundColor Green
    [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor ([System.Net.ServicePointManager]::SecurityProtocol)

# Set DNS to cloudflare for optimized performance
    Write-Host "$(Get-LogDate)`t    Opsætter DNS til Cloudflare." -ForegroundColor Green
    if($env:USERDNSDOMAIN -eq $null){
        $job = Start-Job -ScriptBlock {
        $nic = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
        Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses "1.1.1.1,1.0.0.1" | Out-Null}}

# Configure Windows
    irm https://git.io/JzrB5 | IEX; 
    Start-WinAntiBloat
    Start-WinSettings
    Start-WinSecurity
    Install-App -Name "Office, Chrome, 7zip, VLC" -EnableAutoupdate

# Message
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $btn = [System.Windows.Forms.MessageBoxButtons]::OK
    $ico = [System.Windows.Forms.MessageBoxIcon]::Information
    $Title = 'Microsoft Windows Deployment'
    $Message = 'Deployment complete!'
    $Return = [System.Windows.Forms.MessageBox]::Show($Message, $Title, $btn, $ico)
