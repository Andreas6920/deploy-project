# Start
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Do{sleep 15}until((Test-Connection github.com -Quiet) -eq $true)
$date = get-date -f "yyyy/MM/dd - HH:mm:ss"

# Set DNS to cloudflare for optimized performance
if($env:USERDNSDOMAIN -eq $null){
Write-Host "[$date]`t- Setting DNS" -f green
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
            $Forename = Read-Host " "
            $Forename = $Forename.Replace('æ','a').Replace('ø','o').Replace('å','a').Replace(' ','')
            Write-Host "`t- Indtast Efternavn:" -nonewline -f green;
            $Lastname = Read-Host " "
            $Lastname = $Lastname.Replace('æ','a').Replace('ø','o').Replace('å','a').Replace(' ','')
        # COMPUTER NAVN
            $PCName = "PC-"+$Forename.Substring(0,3).ToUpper()+$Lastname.Substring(0,3).ToUpper()
        # COMPUTER BESKRIVELSE
            if ($Lastname -notlike "*s"){$Lastname = $Lastname + "'s"}
            else{$Lastname = $Lastname + "'"}
            $Lastname = (Get-Culture).TextInfo.ToTitleCase($Lastname)
            $Forename = (Get-Culture).TextInfo.ToTitleCase($Forename)
            $PCDescription = $Forename+" "+$Lastname + " PC"
    # Navngiv PC
        # Omdøb PC
            Write-Host "`t`t- COMPUTERNAVN:`t`t$PCName" -f Yellow;
            if($PCName -ne $env:COMPUTERNAME){Rename-computer -newname $PCName}
        # Omdøb PC Beskrivelse
            Write-Host "`t`t- BESKRIVELSE:`t`t$PCDescription" -f Yellow;
            $ThisPCDescription = Get-WmiObject -class Win32_OperatingSystem
            $ThisPCDescription.Description = $PCDescription
            $ThisPCDescription.put() | out-null
            $WarningPreference = "Continue"
            Write-Host "`t- Computeren navngives ved næste genstart." -f Green

### PART 2 - SET TO SCHEDULED TASK AFTER NEW REBOOT

# Start
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Do{sleep 15}until((Test-Connection github.com -Quiet) -eq $true)
    $date = get-date -f "yyyy/MM/dd - HH:mm:ss"

# Configure Windows
    $url = "https://git.io/JzrB5"
    $path = Join-path -Path $env:TMP -Childpath "Winoptimizer.ps1"
    Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
    Import-Module $path
    Start-WinAntiBloat
    Start-WinSecurity

## Install printer
    ### Måske job baggrundsjob

# App installation
    Set-ExecutionPolicy Bypass -Scope Process -Force;

# Install chocolatey
    Write-Host "[$date]`t- Removing Chocolatey" -f green
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Install Applications
    Write-Host "[$date]`t- Installing Applications:" -f green
    Write-Host "[$date]`t`t- Removing office bloat" -f green
        "Microsoft.MicrosoftOfficeHub","Microsoft.Office.OneNote" | %{ if (Get-AppxPackage | Where-Object Name -Like $_){Get-AppxPackage | Where-Object Name -Like $_ | Remove-AppxPackage; Start-Sleep -S 5}}
    Write-Host "[$date]`t`t- Installing office" get-date -f green
        choco install microsoft-office-deployment --params="'/Product:ProfessionalRetail /64bit /ProofingToolLanguage:da-dk,en-us'" -y
    Write-Host "[$date]`t`t- Installing Chrome" get-date -f green
        choco install googlechrome --ignore-checksums -y
    Write-Host "[$date]`t`t- Installing VLC" get-date -f green
        choco install vlc -y
    Write-Host "[$date]`t`t- Installing 7-zip" get-date -f green
        choco install 7zip.install -y
    Write-Host "[$date]`t`t- Activating Office" get-date -f green
        start-sleep -s 30; & ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook
    Write-Host "[$date]`t`t- Activating Windows" get-date -f green
        start-sleep -s 10; & ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID

# Install Endpoint Protection


# Action1
    irm "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/action.ps1" | iex


# Message
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $btn = [System.Windows.Forms.MessageBoxButtons]::OK
    $ico = [System.Windows.Forms.MessageBoxIcon]::Information
    $Title = 'Microsoft Windows Deployment'
    $Message = 'Deployment complete!'
    $Return = [System.Windows.Forms.MessageBox]::Show($Message, $Title, $btn, $ico)
