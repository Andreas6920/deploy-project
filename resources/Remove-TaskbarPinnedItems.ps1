# Prepare provisioning folder + destination file
    $TaskbarLayoutFolder = Join-Path $env:ProgramData "provisioning"
    if (-not (Test-Path $TaskbarLayoutFolder)) {New-Item -Path $TaskbarLayoutFolder -ItemType Directory -Force | Out-Null}

# Download the XML directly to destination
    $link = "https://raw.githubusercontent.com/Andreas6920/deploy-project/refs/heads/main/resources/TaskbarLayout.xml"
    $TaskbarLayoutFile   = Join-Path $TaskbarLayoutFolder "taskbar_layout.xml"
    Invoke-WebRequest -Uri $link -OutFile $TaskbarLayoutFile -UseBasicParsing

# Registry settings
    $regPath = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
    $settings = @(
        @{
            Name  = "StartLayoutFile"
            Value = $TaskbarLayoutFile
            Type  = [Microsoft.Win32.RegistryValueKind]::ExpandString
        },
        @{
            Name  = "LockedStartLayout"
            Value = 1
            Type  = [Microsoft.Win32.RegistryValueKind]::DWord
        }
    )

    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($regPath, $true)
    if ($null -eq $registry) {$registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($regPath, $true)}

    foreach ($s in $settings) {$registry.SetValue($s.Name, $s.Value, $s.Type)}

    $registry.Dispose()

    Stop-Process -Name "Explorer"
    Start-Sleep -Seconds 10
