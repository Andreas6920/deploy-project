# Start
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor ([System.Net.ServicePointManager]::SecurityProtocol)
Do { sleep 15 } until ((Test-Connection github.com -Quiet) -eq $true)

# Funktion til at få det aktuelle tidspunkt
function Get-LogDate {return (Get-Date -f "yyyy/MM/dd - HH:mm:ss")}

# Configure Windows
    $url = "https://git.io/JzrB5"
    $path = Join-Path -Path $env:TMP -ChildPath "Winoptimizer.ps1"
    irm $url -OutFile $path
    . $path

    Start-WinAntiBloat
    Start-WinSecurity

# Install printer
    $url = "https://git.io/JzrB5"
    $path = Join-Path -Path $env:TMP -ChildPath "Printer-Installation.ps1"
    irm $url -OutFile $path
    . $path

    Install-Printer -All -NavisionPrinter

# Install Applications

    # Install Chocolatey
    $url = "https://community.chocolatey.org/install.ps1"
    $path = Join-Path -Path $env:TMP -ChildPath "ChocolateyInstall.ps1"
    Write-Host "[$(Get-LogDate)]`t- Preparing Application Installation." -ForegroundColor Green
    irm $url -OutFile $path
    . $path

    ## Install Applications
    Write-Host "[$(Get-LogDate)]`t- Installing Applications:" -ForegroundColor Green
    Write-Host "[$(Get-LogDate)]`t`t- Removing office bloat" -ForegroundColor Yellow
    "Microsoft.MicrosoftOfficeHub", "Microsoft.Office.OneNote" | ForEach-Object {
        if (Get-AppxPackage | Where-Object Name -Like $_) {
            Get-AppxPackage | Where-Object Name -Like $_ | Remove-AppxPackage; Start-Sleep -Seconds 5}}
            
    Write-Host "[$(Get-LogDate)]`t`t- Installing office (This step may take a while...)" -ForegroundColor Yellow
    choco install microsoft-office-deployment --params="'/Product:ProfessionalRetail /64bit /ProofingToolLanguage:da-dk,en-us'" -r -y
    Write-Host "[$(Get-LogDate)]`t`t- Installing Chrome" -ForegroundColor Yellow
    choco install googlechrome --ignore-checksums -r -y
    Write-Host "[$(Get-LogDate)]`t`t- Installing VLC" -ForegroundColor Yellow
    choco install vlc -y -r
    Write-Host "[$(Get-LogDate)]`t`t- Installing 7-zip" -ForegroundColor Yellow
    choco install 7zip.install -y -r
    Write-Host "[$(Get-LogDate)]`t`t- Activating Office" -ForegroundColor Yellow
    start-sleep -s 30; & ([ScriptBlock]::Create((irm https://get.activated.win))) /Ohook
    Write-Host "[$(Get-LogDate)]`t`t- Activating Windows" -ForegroundColor Yellow
    start-sleep -s 10; & ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID

# Install Endpoint Protection

# Action1
    # irm "https://raw.githubusercontent.com/Andreas6920/Other/main/scripts/action.ps1" | iex

# Message
    Add-Type -AssemblyName System.Windows.Forms | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $btn = [System.Windows.Forms.MessageBoxButtons]::OK
    $ico = [System.Windows.Forms.MessageBoxIcon]::Information
    $Title = 'Microsoft Windows Deployment'
    $Message = 'Deployment complete!'
    $Return = [System.Windows.Forms.MessageBox]::Show($Message, $Title, $btn, $ico)
