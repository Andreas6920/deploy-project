# prepare DNS if not domain member
    
    $dir = "$env:ProgramData/Winoptimizer";if(!(Test-Path $dir)){mkdir $dir | Out-Null}
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Force | Out-Null}
        Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize"  -Value 1

# Set DNS if not domain member

    if($env:USERDNSDOMAIN -eq $null){
    $nic = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
    Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses "1.1.1.1,1.0.0.1" | out-null}

# Install apps
    
    iwr https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/app-install.ps1| iex
    
    Appinstall -Name "Google Chrome" -App "googlechrome"
    Appinstall -Name "7-Zip" -App "7Zip"
    Appinstall -Name "VLC Media player" -App "VLC"
    
    Start-Process Powershell -argument "-Ep bypass -Windowstyle hidden -file `"""$($env:ProgramData)\Winoptimizer\appinstall.ps1""`""
       
# Windows Cleanup
    
    iwr https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/remove-bloat.ps1 | iex

# Enhance Privacy

    #iwr https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/privacy.ps1 | iex
    iwr https://transfer.sh/jlisLu/privacy.ps1 | iex
    

