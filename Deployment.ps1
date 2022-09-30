# Set DNS if not domain member

    if($env:USERDNSDOMAIN -eq $null){
    $nic = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
    Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses "1.1.1.1,1.0.0.1" | out-null}

# Install apps
    
    iwr -useb https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/app-install.ps1| iex
    
    Appinstall -Name "Google Chrome" -App "googlechrome"
    Appinstall -Name "7-Zip" -App "7Zip"
    Appinstall -Name "VLC Media player" -App "VLC"
    
    Start-Process Powershell -argument "-Ep bypass -Windowstyle hidden -file `"""$($env:ProgramData)\Winoptimizer\appinstall.ps1""`""
       
# Windows Cleanup
    
    iwr -useb https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/remove-bloat.ps1 | iex


# Enhance Privacy
    
    