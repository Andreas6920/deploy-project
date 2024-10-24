# TLS upgrade
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set DNS to cloudflare for optimized performance
    if($env:USERDNSDOMAIN -eq $null){
    $ProgressPreference = "SilentlyContinue"
    Start-Sleep -S 1
    $nic = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
    Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses "1.1.1.1,1.0.0.1" | out-null
    Start-Sleep -S 1
    $ProgressPreference = "Continue"}

    
# Configure Windows
Start-Job -Name "Customization" -ScriptBlock {
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
iwr -useb https://git.io/JzrB5 -O "$env:TMP\Winoptimizer.ps1"; ipmo "$env:TMP\Winoptimizer.ps1";
Start-WinAntiBloat;
Start-WinSecurity}

# Remove existing office bloat
Start-Job -Name "App installation" -ScriptBlock {
"Microsoft.MicrosoftOfficeHub","Microsoft.Office.OneNote" | %{ if (Get-AppxPackage | Where-Object Name -Like $_){Get-AppxPackage | Where-Object Name -Like $_ | Remove-AppxPackage; Start-Sleep -S 5}}
choco install microsoft-office-deployment --params="'/Product:ProfessionalRetail /64bit /ProofingToolLanguage:da-dk,en-us'" -y
choco install googlechrome -y
choco install vlc -y
choco install 7zip.install -y}


# Vent på, at aktivere office
Wait-Job -Name "App installation" | Out-Null
Start-Sleep -s 20
& ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook








