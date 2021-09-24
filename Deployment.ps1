

## What could be better, what's up next:
##  Google chrome fails to install with chrome, install it with msi https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi
##   Inking & Typing Personalization is not disabled
##   Store my activity history on this device
##   Let Windows Track app launches to improve start and search results

# APPLICATION INSTALLATION

    ## install chocolatey
    if (!(Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) { 
        # installing chocolatey
        Write-host "      application not found. Installing:" -f green
        Write-host "        - Preparing system.." -f yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        # Downloading installtion file from original source
        Write-host "        - Downloading script.." -f yellow
        (New-Object System.Net.WebClient).DownloadFile("https://chocolatey.org/install.ps1","$env:TMP/choco-install.ps1")
        # Adding a few lines to make installtion more silent.
        Write-host "        - Preparing script.." -f yellow
        $add_line1 = "((Get-Content -path $env:TMP\chocolatey\chocoInstall\tools\chocolateysetup.psm1 -Raw) -replace '\| write-Output', ' | out-null' ) | Set-Content -Path $env:TMP\chocolatey\chocoInstall\tools\chocolateysetup.psm1; "
        $add_line2 = "((Get-Content -path $env:TMP\chocolatey\chocoInstall\tools\chocolateysetup.psm1 -Raw) -replace 'write-', '#write-' ) | Set-Content -Path $env:TMP\chocolatey\chocoInstall\tools\chocolateysetup.psm1; "
        $add_line3 = "((Get-Content -path $env:TMP\chocolatey\chocoInstall\tools\chocolateysetup.psm1 -Raw) -replace 'function.* #write-', 'function Write-' ) | Set-Content -Path $env:TMP\chocolatey\chocoInstall\tools\chocolateysetup.psm1;"
        ((Get-Content -path $env:TMP/choco-install.ps1 -Raw) -replace 'write-host', "#write-host" ) | Set-Content -Path $env:TMP/choco-install.ps1
        ((Get-Content -path $env:TMP/choco-install.ps1 -Raw) -replace '#endregion Download & Extract Chocolatey', "$add_line1`n$add_line2`n$add_line3" ) | Set-Content -Path $env:TMP/choco-install.ps1
        # Executing installation file.
        Set-Location $env:TMP
        Write-host "        - Installing.." -f yellow
        .\choco-install.ps1
        Write-host "        - Installation complete.." -f yellow}

        choco install googlechrome -y | out-null
        choco install 7Zip -y | out-null
        choco install VLC -y | out-null
        Start-Sleep -s 3
# hotfiX! if chrome is corrupt from Chocolatey download and install from d
    if (!((Get-ChildItem -Directory -Depth 2 ("$env:ProgramFiles", "$env:ProgramFiles(x86)") -Recurse).Name -eq "Chrome")){
        Invoke-WebRequest -uri "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi" -OutFile "$env:ProgramData\chocolatey\googlechromestandaloneenterprise.msi"
        Set-Location "$env:ProgramData\chocolatey"
        MsiExec.exe /i googlechromestandaloneenterprise.msi /qn
        }


# Windows Cleaning Lady
    # Microsoft Bloat
    $ProgressPreference = "SilentlyContinue" #hide progressbar
    start-sleep 5
    $Bloatware = @(

        "Microsoft.ZuneMusic"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftStickyNotes"
        "Microsoft.Getstarted"
        "Microsoft.Office.OneNote"
        "Microsoft.People"
        "Microsoft.3DBuilder"
        "*officehub*"
        "*feedback*"
        "Microsoft.Music.Preview"
        "Microsoft.WindowsMaps"
        "*windowscommunicationsapps*"
        "*autodesksketch*"
        "*plex*"
        "*print3d*"
        "*Paint3D*"
        "*Mixed*"
        "*oneconnect*"
                                            
        # Xbox Bloat
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxApp"
        "Microsoft.Xbox.TCUI"
                                            
        # Bing Bloat
        "Microsoft.BingTravel"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingWeather"
        "Microsoft.BingNews"
        "Microsoft.BingFinance"
        "Microsoft.BingSports"
        "Microsoft.Bing*"
        "*Bing*"

        # Games
        "*disney*"
        "*candycrush*"
        "*minecraft*"
        "*bubblewitch*"
        "*empires*"
        "*Royal Revolt*"
                            
        # Other crap
        "*Skype*"
        "*Facebook*"
        "*Twitter*"
        "*Spotify*"
        "*EclipseManager*"
        "*ActiproSoftwareLLC*"
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
        "*Duolingo-LearnLanguagesforFree*"
        "*PandoraMediaInc*"
        "*Wunderlist*"
        "*Flipboard*"
    )
    
    foreach ($Bloat in $Bloatware) {
        $bloat_output = Get-AppxPackage | Where-Object Name -Like $Bloat | Select -Property Name; #Write-Host "        - Removing: $bloat_output"
        if ($bloat_output -ne $null) { Write-host "        - Bloat app found! Removing: " -f yellow -nonewline; ; write-host "$bloat_output".Split(".")[1].Split("}")[0] -f yellow }
        Get-AppxPackage -Name $Bloat | Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null}
    
    start-sleep 5    
    $Bloatschedules = @(
            "XblGameSaveTaskLogon"
            "XblGameSaveTask"
            "Consolidator"
            "UsbCeip"
            "DmClient"
            "DmClientOnScenarioDownload"
            )
        foreach ($BloatSchedule in $BloatSchedules) {
        if ((Get-ScheduledTask | ? state -ne Disabled | ? TaskName -like $BloatSchedule)){
        Get-ScheduledTask | ? Taskname -eq $BloatSchedule | Disable-ScheduledTask | Out-Null}}
        
    
    
    ## Unpin start menu

$START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
<LayoutOptions StartTileGroupCellWidth="6" />
<DefaultLayoutOverride>
    <StartLayoutCollection>
        <defaultlayout:StartLayout GroupCellWidth="6" />
    </StartLayoutCollection>
</DefaultLayoutOverride>
</LayoutModificationTemplate>
"@
    $layoutFile = "$env:SystemRoot\StartMenuLayout.xml"        
    start-sleep 5
    ### Delete layout file if it already exists
    If (Test-Path $layoutFile) {
        Remove-Item $layoutFile
    }
    ### Creates the blank layout file
    $START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII
    $regAliases = @("HKLM", "HKCU")
    ### Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
    foreach ($regAlias in $regAliases) {
        $basePath = $regAlias + ":\Software\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        IF (!(Test-Path -Path $keyPath)) { 
            New-Item -Path $basePath -Name "Explorer" | Out-Null
        }
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
        Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
    }
    ### Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
    Stop-Process -name explorer -Force
    Start-Sleep -s 5
    ### Enable the ability to pin items again by disabling "LockedStartLayout"
    foreach ($regAlias in $regAliases) {
        $basePath = $regAlias + ":\Software\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
    }
    Stop-Process -name explorer
    Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\
    Remove-Item $layoutFile

    ## unpin Taskbar
    start-sleep -s 5
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband -Name FavoritesChanges -Value 3 -Type Dword -Force | Out-Null
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband -Name FavoritesRemovedChanges -Value 32 -Type Dword -Force | Out-Null
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband -Name FavoritesVersion -Value 3 -Type Dword -Force | Out-Null
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband -Name Favorites -Value ([byte[]](0xFF)) -Force | Out-Null
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCortanaButton -Type DWord -Value 0 | Out-Null
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Search -Name SearchboxTaskbarMode -Value 0 -Type Dword | Out-Null
    set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -Type DWord -Value 0 | Out-Null
    Remove-Item -Path "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" -Recurse -Force | Out-Null
    Stop-Process -name explorer
    start-sleep -s 5

    ## Remove Windows pre-installed bloat printers (Fax, PDF, OneNote) These are almost never used.
        If (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private")) {
        New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -Type DWord -Value 0
        Get-Printer | ? Name -cMatch "OneNote for Windows 10|Microsoft XPS Document Writer|Microsoft Print to PDF|Fax" | Remove-Printer 


# Privacy

    ## Disable Advertising ID
    Write-host "        - Disabling advertising ID." -f yellow
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null}
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
    Start-Sleep -s 2

    ## Disable let websites provide locally relevant content by accessing language list
    Write-host "        - Disabling location tracking." -f yellow
    If (!(Test-Path "HKCU:\Control Panel\International\User Profile")) {
        New-Item -Path "HKCU:\Control Panel\International\User Profile" -Force | Out-Null}
    Set-ItemProperty -Path  "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut"  -Value 1
    Start-Sleep -s 2
  
    ## Disable Show me suggested content in the Settings app
    Write-host "        - Disabling personalized content suggestions." -f Yellow
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Force | Out-Null}
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
    Start-Sleep -s 2

    ## Disable Online Speech Recognition
    Write-host "        - Disabling Online Speech Recognition." -f yellow
    If (!(Test-Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy")) {
        New-Item -Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Force | Out-Null}
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Type DWord -Value 0
    Start-Sleep -s 2

    ## Hiding personal information from lock screen
    Write-host "        - Hiding email and domain information from sign-in screen." -f yellow
    If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\System")) {
            New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Force | Out-Null}
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "DontDisplayLockedUserID" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "DontDisplayLastUsername" -Type DWord -Value 0
    Start-Sleep -s 2

    ## Disable diagnostic data collection
    If (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection")) {
            New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null}
    Set-ItemProperty -Path  "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry"  -Value 0
    Start-Sleep -s 2
    
    ## Disable App Launch Tracking
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null}
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "Start_TrackProgs" -Type DWord -Value 0
    Start-Sleep -s 2

    ## Disable "tailored expirence"
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy")) {   
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Force | Out-Null}
    Set-ItemProperty -Path  "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled"  -Value 0
    Start-Sleep -s 2

    ## Disable Inking & Typing Personalization
    If (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization")) {
    New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization" -Force | Out-Null}
    Set-ItemProperty -Path  "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection"  -Value 1
    Set-ItemProperty -Path  "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection"  -Value 1
    Start-Sleep -s 2
    

    ## Disabling services
    Write-host "      BLOCKING - Tracking startup services" -f green
    $trackingservices = @(
    "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
    "DiagTrack"                                # Diagnostics Tracking Service
    "dmwappushservice"                         # WAP Push Message Routing Service (see known issues)
    "lfsvc"                                    # Geolocation Service
    "TrkWks"                                   # Distributed Link Tracking Client
    "XblAuthManager"                           # Xbox Live Auth Manager
    "XblGameSave"                              # Xbox Live Game Save Service
    "XboxNetApiSvc"                            # Xbox Live Networking Service
                         )

     foreach ($trackingservice in $trackingservices) {
     if((Get-Service -Name $trackingservice | ? Starttype -ne Disabled)){
     Get-Service | ? name -eq $trackingservice | Set-Service -StartupType Disabled}}
        