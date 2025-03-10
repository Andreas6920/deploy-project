# Start
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

#reinsure admin rights
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    # Relaunch as an elevated process
    $Script = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy RemoteSigned", "-File `"$Script`""
}

# Funktion til at få det aktuelle tidspunkt
function Get-LogDate {return (Get-Date -f "yyyy/MM/dd HH:MM:ss")}

# Opgrader TLS
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor ([System.Net.ServicePointManager]::SecurityProtocol)
Do{sleep 15}until((Test-Connection github.com -Quiet) -eq $true)

# Set DNS to cloudflare for optimized performance
if($env:USERDNSDOMAIN -eq $null){
Write-Host "[$(Get-LogDate)]`t- Indstiller DNS." -ForegroundColor Green
$ProgressPreference = "SilentlyContinue"
Start-Sleep -S 1
$nic = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
Set-DnsClientServerAddress -InterfaceAlias $nic -ServerAddresses "1.1.1.1,1.0.0.1" | out-null
Start-Sleep -S 1
$ProgressPreference = "Continue"}

# Rename PC
    # Klargøring
        Write-Host "[$(Get-LogDate)]`t- Omdøber PC." -ForegroundColor Green
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
            Write-Host "[$(Get-LogDate)]`t- Computeren navngives ved næste genstart." -ForegroundColor Green

 # Prepare script after reboot
        Write-Host "[$(Get-LogDate)]`t- Forbereder næste genstart." -ForegroundColor Green
        $url = 
        $path = 'C:\ProgramData\post-reboot-setup.ps1'
        irm -uri $url -OutFile $path
        #Setting to start after reboot
        $name = 'port-reboot-setup'
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ep bypass -file $path"
        $principal = New-ScheduledTaskPrincipal -UserId $env:username -LogonType ServiceAccount -RunLevel Highest
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        Register-ScheduledTask -TaskName $Name  -Principal $principal -Action $action -Trigger $trigger -Force | Out-Null 

    # Restart-PC
        Write-Host "[$(Get-LogDate)]`t- Genstarter PC." -ForegroundColor Green
        Start-Sleep -Seconds 10
        Restart-Computer -Force
