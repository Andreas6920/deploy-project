# Ensure admin rights
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    
    # Relaunch as an elevated process
    $Script = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy RemoteSigned", "-File `"$Script`""}

# Bypass ExecutionPolicy
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Timestamps for actions
    Function Get-LogDate {return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]")}

Write-Host "$(Get-LogDate)`tOPSÆTNING STARTER" -f Green

# Wait for internet
    Write-Host "$(Get-LogDate)`t    Venter på internet" -ForegroundColor Green -NoNewline
    do{Write-Host "." -ForegroundColor Green -NoNewline; sleep 3}until((Test-Connection github.com -Quiet) -eq $true)
    Write-host " [VERIFICERET]" -ForegroundColor Green

# Opgrader TLS
    Write-Host "$(Get-LogDate)`t    Opgradere TLS." -ForegroundColor Green
    [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor ([System.Net.ServicePointManager]::SecurityProtocol)

# Set DNS to cloudflare for optimized performance
    Write-Host "$(Get-LogDate)`t    Opsætter DNS til Cloudflare." -ForegroundColor Green
    if($env:USERDNSDOMAIN -eq $null){
        $job = Start-Job -ScriptBlock {
        $nic = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
        Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses "1.1.1.1,1.0.0.1" | Out-Null}}

# Rename PC
    # Klargøring
        Write-Host "$(Get-LogDate)`t    Navngiver PC." -ForegroundColor Green
        # Modtager brugertastning
            Write-Host "`t- Indtast Fornavn: " -nonewline -f yellow;
            $Forename = Read-Host
            $Forename = $Forename.Replace('æ','a').Replace('ø','o').Replace('å','a').Replace(' ','')
            Write-Host "`t- Indtast Efternavn: " -nonewline -f yellow;
            $Lastname = Read-Host
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
            $WarningPreference = "SilentlyContinue"
            Write-Host "`t`t- COMPUTERNAVN:`t`t$PCName" -f Yellow;
            if($PCName -ne $env:COMPUTERNAME){Rename-computer -newname $PCName}
        # Omdøb PC Beskrivelse
            $WarningPreference = "SilentlyContinue"
            Write-Host "`t`t- BESKRIVELSE:`t`t$PCDescription" -f Yellow;
            $ThisPCDescription = Get-WmiObject -class Win32_OperatingSystem
            $ThisPCDescription.Description = $PCDescription
            $ThisPCDescription.put() | out-null
            Write-Host "$(Get-LogDate)`t    Computeren navngives ved genstart." -ForegroundColor Green

# Prepare script after reboot
    Write-Host "$(Get-LogDate)`t    Forbereder genstart:" -ForegroundColor Green
    
    # Starter
    $ScriptUrl = "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/deploy-project-part2.ps1"
    $ScriptName = [System.IO.Path]::GetFileNameWithoutExtension((Split-Path $ScriptUrl -Leaf))
    $ScriptFolder = $env:HOMEDRIVE
    $ScriptLocation = Join-Path -Path $Scriptfolder -ChildPath (Split-Path $ScriptUrl -Leaf)
    $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $Description = "PC deployment script, part 2"

    # Download filen til C:\ via Invoke-RestMethod
    try {Invoke-RestMethod -Uri $ScriptURL -OutFile $ScriptLocation
         Write-Host "$(Get-LogDate)`t        - Script downloaded successfully to: $ScriptLocation" -ForegroundColor Yellow} 
    catch { Write-Host "$(Get-LogDate)`t        - FAILED to download script: $_" -ForegroundColor Red}

    # Task Action - Løber lokalt script med PowerShell i fuld skærm
    $taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-w Maximized -ExecutionPolicy Bypass -File `"$ScriptLocation`""
    $taskTrigger = New-ScheduledTaskTrigger -AtLogon  
    $taskPrincipal = New-ScheduledTaskPrincipal -UserId $CurrentUser -LogonType Interactive -RunLevel Highest
    $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd
    Register-ScheduledTask -TaskName $ScriptName -Description $Description -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings $taskSettings | Out-Null
    Write-Host "$(Get-LogDate)`t        - Scheduled task '$ScriptName' created successfully." -ForegroundColor Yellow

# Restart-PC
    Start-Sleep -S 3
    Write-Host "$(Get-LogDate)`t    Genstarter PC." -ForegroundColor Green
    Start-Sleep -S 5
    Restart-Computer -Force
