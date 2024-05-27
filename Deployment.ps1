# TLS upgrade
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set DNS if NOT domain member
    if($env:USERDNSDOMAIN -eq $null){
    $ProgressPreference = "SilentlyContinue"
    Start-Sleep -S 1
    $nic = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
    Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses "1.1.1.1,1.0.0.1" | out-null
    Start-Sleep -S 1
    $ProgressPreference = "Continue"}

# Rename PC
    # Klargøring
        # Modtager brugertastning
            Write-Host "`t- Indtast Fornavn:" -nonewline -f green;
            $New_PCNAME_FORNAVN = Read-Host " "
            $New_PCNAME_FORNAVN = $New_PCNAME_FORNAVN.Replace('æ','a').Replace('ø','o').Replace('å','a').Replace(' ','')
            Write-Host "`t- Indtast Efternavn:" -nonewline -f green;
            $New_PCNAME_EFTERNAVN = Read-Host " "
            $New_PCNAME_EFTERNAVN = $New_PCNAME_EFTERNAVN.Replace('æ','a').Replace('ø','o').Replace('å','a').Replace(' ','')
        # COMPUTER NAVN
            $PC_NAME = "PC-"+$New_PCNAME_FORNAVN.Substring(0,3).ToUpper()+$New_PCNAME_EFTERNAVN.Substring(0,3).ToUpper()
        # COMPUTER BESKRIVELSE
            if ($New_PCNAME_EFTERNAVN -notlike "*s"){$New_PCNAME_EFTERNAVN = $New_PCNAME_EFTERNAVN + "'s"}
            else{$New_PCNAME_EFTERNAVN = $New_PCNAME_EFTERNAVN + "'"}
            $New_PCNAME_EFTERNAVN = (Get-Culture).TextInfo.ToTitleCase($New_PCNAME_EFTERNAVN)
            $New_PCNAME_FORNAVN = (Get-Culture).TextInfo.ToTitleCase($New_PCNAME_FORNAVN)
            $New_Description = $New_PCNAME_FORNAVN+" "+$New_PCNAME_EFTERNAVN + " PC"
    # Navngiv PC
        # Omdøb PC
            Write-Host "`t`t- COMPUTERNAVN:`t`t$PC_NAME" -f Yellow;
            if($PC_NAME -eq $env:COMPUTERNAME){Rename-computer -newname $PC_NAME}
        # Omdøb PC Beskrivelse
            Write-Host "`t`t- BESKRIVELSE:`t`t$New_Description" -f Yellow;
            $ThisPCDescription = Get-WmiObject -class Win32_OperatingSystem
            $ThisPCDescription.Description = $New_Description
            $ThisPCDescription.put() | out-null
            $WarningPreference = "Continue"
            Write-host "`t- Computeren navngives ved næste genstart." -f Green

# Install windows-optimizer
    $Link = "https://git.io/JzrB5" 
    $Path = join-path -Path $env:TMP -ChildPath "WinOptimizer.ps1"
    Invoke-WebRequest -Uri $Link -OutFile $Path -UseBasicParsing
    Import-Module $path

# Intall and clean Windows
    Install-app -Name "chrome, vlc, 7zip, adobe"
    Start-WinAntiBloat
    Start-WinSecurity

# Message
    msg * "Complete"
