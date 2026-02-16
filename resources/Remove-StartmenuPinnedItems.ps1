# verify system version, windows 10 or 11
    $BuildNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber
    if([int]$BuildNumber -ge 22000){$ThisIsWindows11 = $True; $ThisIsWindows10 = $False;}
    else{$ThisIsWindows11 = $False; $ThisIsWindows10 = $True;}
    if($ThisIsWindows10){$SystemVersion = "Windows 10"}
    if($ThisIsWindows11){$SystemVersion = "Windows 11"}

# Cleaning
    Write-Host "`t    Cleaning Start Menu ($SystemVersion):" -f Green    

    if($ThisIsWindows10){
        # Prepare
            $link = "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/StartMenuLayout.xml"
            $File = "$($env:SystemRoot)\StartMenuLayout.xml"
            $keys = "HKLM:\Software\Policies\Microsoft\Windows\Explorer","HKCU:\Software\Policies\Microsoft\Windows\Explorer"; 
                
        # Download blank Start Menu file
            Write-Host "`t        - Downloading Start Menu file." -f Yellow;
            (New-Object net.webclient).Downloadfile("$link", "$file"); 
                            
        # Unlock start menu, disable pinning, replace with blank file
            Write-Host "`t        - Unlocking and replacing current file." -f Yellow;
            $keys | ForEach-Object { if(!(test-path $_)){ New-Item -Path $_ -Force | Out-Null; Set-ItemProperty -Path $_ -Name "LockedStartLayout" -Value 1; Set-ItemProperty -Path $_ -Name "StartLayoutFile" -Value $File } }
            
        # Restart explorer
            Stop-Process -Name "Explorer"; Start-Sleep -Seconds 10

        # Enable pinning
            Write-Host "`t        - Fixing pinning." -f Yellow
            $keys | ForEach-Object { Set-ItemProperty -Path $_ -Name "LockedStartLayout" -Value 0 }
            
        #Restart explorer
            Stop-Process -Name "Explorer"; Start-Sleep -Seconds 10

        # Save menu to all users
            Write-Host "`t        - Save changes to all users." -f Yellow
            Import-StartLayout -LayoutPath $File -MountPath $env:SystemDrive\

        # Clean up after script
            Remove-Item $File
            Write-Host "`t        - Start menu cleaning complete." -f Yellow;  Start-Sleep -S 3;}

    If($ThisIsWindows11){

        Start-Sleep -s 3
        $FileUrl = "https://raw.githubusercontent.com/Andreas6920/WinOptimizer/main/res/start2.bin"
        $DestinationPath = "C:\Users\$env:USERNAME\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin"

        # Download og gem filen
            try {   Write-Host "`t        - Downloading new start menu template." -f Yellow
                    Invoke-RestMethod -Uri $FileUrl -OutFile $DestinationPath
                    Write-Host "`t        - Complete." -f Yellow
                    Write-Host "`t        - Restarting explorer." -f Yellow
                    Write-Host "`t        - Start menu cleaning complete." -f Yellow;  Start-Sleep -S 3;
                    Stop-Process -Name "Explorer"; Start-Sleep -Seconds 10} 
            catch { Write-Host "Failed to download file: $_" -ForegroundColor Red}}