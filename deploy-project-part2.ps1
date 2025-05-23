# Start
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Funktion til at få det aktuelle tidspunkt
    function Get-LogDate {return (Get-Date -f "[yyyy/MM/dd HH:mm:ss]")}

# Wait for internet
    Write-Host "$(Get-LogDate)`t    Venter på internet" -ForegroundColor Green -NoNewline
    do{Write-Host "." -ForegroundColor Green -NoNewline; Start-Sleep -Seconds 3}until((Test-Connection github.com -Quiet) -eq $true)
    Write-host " [VERIFICERET]" -ForegroundColor Green
    Start-Sleep -Seconds 3
    Clear-Host

# Starter installationen
    Write-Host "`n$(Get-LogDate)`tINSTALLATIONEN BEGYNDER" -f Green

# Windows Aktivering som job
    Start-Job -Name "Windows Activation" -ScriptBlock {& ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID} | Out-Null

# Installere printer
    Write-Host "$(Get-LogDate)`t    Installere Printere:" -f Green
    Write-Host "$(Get-LogDate)`t        - Starter printer installation i baggrunden." -f Yellow;
    Start-Job -Name "Printer Installation" -ScriptBlock {
        Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Andreas6920/print_project/refs/heads/main/print-module.psm1" | Invoke-Expression
        Install-Printer -All -NavisionPrinter} | Out-Null

# Konfigurer Windows
    Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/Winoptimizer.ps1" | Invoke-Expression
    Start-WinAntiBloat
    Start-WinSettings
    Start-WinSecurity
    Install-App -Name "Office, Chrome, 7zip, VLC" -EnableAutoupdate

# Office aktivering som job
    Start-Job -Name "Office Activation" -ScriptBlock { & ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook } | Out-Null

# Action1
    
    # Download
        Write-Host "$(Get-LogDate)`t    Installerer Action1.." -ForegroundColor Green
        Write-Host "$(Get-LogDate)`t        - Downloader.." -ForegroundColor Yellow
        $link = "https://app.eu.action1.com/agent/51fced32-7e39-11ee-b2da-3151362a23c3/Windows/agent(My_Organization).msi"
        $path = join-path -Path $env:TMP -ChildPath (split-path $link -Leaf)
        (New-Object net.webclient).Downloadfile("$link", "$path") | Out-Null
        
    # Install
        Write-Host "$(Get-LogDate)`t        - Installere.." -ForegroundColor Yellow
        msiexec /i $path /quiet
    
    # Confirming installation
        Write-Host "$(Get-LogDate)`t        - Bekræfter agenten kører.." -ForegroundColor Yellow 
        do{Start-Sleep -S 1;}until(get-service -Name "Action1 Agent" -ErrorAction SilentlyContinue)
        Write-Host "$(Get-LogDate)`t        - Bekræftet." -ForegroundColor Yellow

# Skriverbords ikoner
    Write-Host "$(Get-LogDate)`t    Fikser skrivebordsikoner" -ForegroundColor Green

    # Fjern alle .lnk filer fra public og bruger desktop
        Write-Host "$(Get-LogDate)`t        - Fjerner alle genveje fra skrivebordet" -ForegroundColor Yellow
        Remove-Item -Path "$env:SystemDrive\Users\Public\Desktop\*.lnk" -Confirm:$False -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemDrive\Users\$Env:username\Desktop\*.lnk" -Confirm:$False -ErrorAction SilentlyContinue

    # Tilføj nye .lnk filer til public og bruger desktop
        Write-Host "$(Get-LogDate)`t        - Tilføjer nye genveje til skrivebordet" -ForegroundColor Yellow
        $Shortcuts = @( "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk",
                        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Outlook (classic).lnk",
                        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Word.lnk",
                        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk")

        foreach ($Shortcut in $Shortcuts) {
            Start-Sleep -Seconds 1
            Copy-Item -Path $Shortcut -Destination "$env:SystemDrive\Users\$Env:username\Desktop\" -Force -ErrorAction SilentlyContinue}    



#Pinning Applications

    # Tjek om Windows er installeret på dansk
        $WinLang = (Get-Culture).Name
        if ($WinLang -like "da-*") {
        Write-Host "$(Get-LogDate)`t    Pinning:" -f Green
        Stop-Input
        
        # Start Menu
            Write-Host "$(Get-LogDate)`t        - Start menu.." -ForegroundColor Yellow
            $app = New-Object -ComObject Shell.Application
            $key = New-Object -com Wscript.Shell
            $app.open("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\")    
            Start-Sleep -Seconds 10
            $PinnedApps = @("Google","Outlook","Word","Excel")
            foreach ($PinnedApp in $PinnedApps) {
            $key.SendKeys($PinnedApp)
            Start-Sleep -Seconds 2
            $key.SendKeys("+{F10}")
            Start-Sleep -Seconds 1
            $key.SendKeys("f")
            Start-Sleep -Seconds 1
            $key.SendKeys("f")
            Start-Sleep -Seconds 1
            $key.SendKeys("f")
            Start-Sleep -Seconds 1
            $key.SendKeys("f")
            Start-Sleep -Seconds 1
            $key.SendKeys("{ENTER}")
            Start-Sleep -Seconds 1}
            $key.SendKeys("%{F4}")

            Start-Sleep -Seconds 3

        # Taskbar
            Write-Host "$(Get-LogDate)`t        - Taskbar.." -ForegroundColor Yellow
            $app = New-Object -ComObject Shell.Application
            $key = New-Object -com Wscript.Shell
            $app.open("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\")    
            Start-Sleep -Seconds 10
            $PinnedApps = @("Google","Outlook","Word","Excel")
            foreach ($PinnedApp in $PinnedApps) {
            $key.SendKeys($PinnedApp)
            Start-Sleep -Seconds 2
            $key.SendKeys("+{F10}")
            Start-Sleep -Seconds 1
            $key.SendKeys("f")
            Start-Sleep -Seconds 1
            $key.SendKeys("f")
            Start-Sleep -Seconds 1
            $key.SendKeys("f")
            Start-Sleep -Seconds 1
            $key.SendKeys("{ENTER}")
            Start-Sleep -Seconds 1}
            $key.SendKeys("%{F4}")
        
            Start-Input} 
        
        else {Write-Host "Windows er ikke på dansk. Skipper fastgørelse." -ForegroundColor Yellow}

<#

    Write-Host "$(Get-LogDate)`t    Indstiller taskbar pins" -ForegroundColor Green
    
    Stop-Input
    sleep -s 2
    $app = New-Object -ComObject Shell.Application
    $key = New-Object -com Wscript.Shell    
        
    $app.open("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\")
    sleep -s 1
    $key.SendKeys("{DOWN}")
    sleep -s 1
    $key.SendKeys("Google")
    sleep -s 1
    $key.SendKeys("+{F10}")
    sleep -s 1
    $key.SendKeys("k")
    sleep -s 1
    $key.SendKeys("Outlook")
    sleep -s 1
    $key.SendKeys("+{F10}")
    sleep -s 1
    $key.SendKeys("k")
    sleep -s 1
    $key.SendKeys("word")
    sleep -s 1
    $key.SendKeys("+{F10}")
    sleep -s 1
    $key.SendKeys("k")
    sleep -s 1
    $key.SendKeys("excel")
    sleep -s 1
    $key.SendKeys("+{F10}")
    sleep -s 1
    $key.SendKeys("k")
    sleep -s 1
    $key.SendKeys("%{F4}")
    sleep -s 2

    Start-Input
#>

# Færdiggør installationen
    Write-Host "$(Get-LogDate)`t    Færdiggøre installationen:" -ForegroundColor Green
    
        Write-Host "$(Get-LogDate)`t        - Windows aktivering" -ForegroundColor Yellow -NoNewline
        Wait-Job -Name "Windows Activation" | Out-Null
        Write-Host "`t[FULDENDT]" -ForegroundColor Yellow 

        Write-Host "$(Get-LogDate)`t        - Office aktivering" -ForegroundColor Yellow -NoNewline
        Wait-Job -Name "Office Activation" | Out-Null
        Write-Host "`t[FULDENDT]" -ForegroundColor Yellow 
    
        Write-host "$(Get-LogDate)`t        - Printer installation" -ForegroundColor Yellow -NoNewline
        Wait-Job -Name "Printer Installation" | Out-Null
        Write-host "`t[FULDENDT]" -ForegroundColor Yellow

        Write-host "$(Get-LogDate)`t        - Fjerner deployment script i planlagte opgaver" -ForegroundColor Yellow -NoNewline
        Unregister-ScheduledTask -TaskName "deploy-project-part2" -Confirm:$false | Out-Null
        Remove-Item -Path "$env:HOMEDRIVE/deploy-project-part2" -Force | Out-Null
        Write-host "`t[FULDENDT]" -ForegroundColor Yellow

Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("Deployment scriptet er nu fuldendt.", "Deployment Script", "OK", "Information")