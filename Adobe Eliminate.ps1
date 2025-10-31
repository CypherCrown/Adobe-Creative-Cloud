# PowerShell-Skript zum Deaktivieren unnötiger Autostart-Dienste
# Administrator-Rechte erforderlich!
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# 1. Adobe Creative Cloud Autostart deaktivieren
Write-Host "Deaktiviere Adobe Creative Cloud Autostart..." -ForegroundColor Yellow

# Scheduled Tasks für Adobe deaktivieren
Get-ScheduledTask | Where-Object {$_.TaskName -like "*Adobe*" -or $_.TaskName -like "*Creative*"} | Disable-ScheduledTask

# Registry-Einträge für Adobe entfernen
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        Get-ItemProperty $path | Where-Object {$_.PSObject.Properties.Name -like "*Adobe*" -or $_.PSObject.Properties.Name -like "*Creative*"} | ForEach-Object {
            Remove-ItemProperty -Path $path -Name $_.PSObject.Properties.Name -Force
            Write-Host "Entferne: $($_.PSObject.Properties.Name)" -ForegroundColor Red
        }
    }
}

# 2. Andere unnötige Dienste deaktivieren
$unnecessaryServices = @(
    "AdobeARM",
    "AdobeUpdateService",
    "CCLibrary",
    "Creative Cloud",
    "VLC Plus Player Updater"
)

foreach ($service in $unnecessaryServices) {
    try {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "Deaktiviere Service: $service" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Service $service nicht gefunden oder kann nicht deaktiviert werden" -ForegroundColor Gray
    }
}

# 3. Scheduled Tasks für unnötige Updates deaktivieren
$unnecessaryTasks = @(
    "Adobe Acrobat Update Task",
    "Adobe Uninstaller", 
    "VLC Plus Player Updater",
    "MicrosoftEdgeUpdateTaskMachineUA*",
    "EPSON ET-8550 Series Update*"
)

foreach ($task in $unnecessaryTasks) {
    try {
        Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
        Write-Host "Deaktiviere Task: $task" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Task $task nicht gefunden" -ForegroundColor Gray
    }
}

# 4. Startup-Ordner bereinigen
$startupPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
)

foreach ($startupPath in $startupPaths) {
    if (Test-Path $startupPath) {
        Get-ChildItem $startupPath -Filter "*Adobe*" -Recurse | Remove-Item -Force
        Get-ChildItem $startupPath -Filter "*Creative*" -Recurse | Remove-Item -Force
    }
}

# 5. Services zurücksetzen die nicht gebraucht werden
$optionalServicesToDisable = @(
    "XboxGipSvc",
    "XboxNetApiSvc",
    "WSearch",
    "TabletInputService"
)

foreach ($service in $optionalServicesToDisable) {
    try {
        Set-Service -Name $service -StartupType Manual -ErrorAction SilentlyContinue
        Write-Host "Setze Service $service auf Manual" -ForegroundColor Blue
    }
    catch {
        # Service existiert nicht, überspringen
    }
}

Write-Host "`nBereinigung abgeschlossen!" -ForegroundColor Green
Write-Host "Starten Sie den Computer neu um alle Änderungen zu ubernehmen." -ForegroundColor Cyan

# Zusätzliches Tool zur Autostart-Analyse
Write-Host "`nZusatzliche Analyse-Tools:" -ForegroundColor Magenta
Write-Host "1. AutoRuns von Sysinternals: https://docs.microsoft.com/en-us/sysinternals/downloads/autoruns"
Write-Host "2. Task-Manager -> Autostart"
Write-Host "3. MSConfig für systemweite Einstellungen"


# Erweitertes PowerShell-Skript zum Beenden und Deaktivieren von Adobe-Anwendungen
# Administrator-Rechte erforderlich!

# 1. Alle laufenden Adobe-Prozesse beenden
Write-Host "Beende alle laufenden Adobe-Prozesse..." -ForegroundColor Red

$adobeProcesses = @(
    "Adobe*",
    "Creative*",
    "CCXProcess",
    "CCLibrary",
    "CoreSync",
    "ACSDaemon",
    "AdobeIPCBroker",
    "Adobe Desktop Service",
    "AdobeCRDaemon",
    "CCLibrary.exe",
    "Creative Cloud.exe",
    "Adobe CEF Helper.exe",
    "AdobeCRDaemon.exe"
)

foreach ($process in $adobeProcesses) {
    try {
        Get-Process -Name $process -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "Beende Prozess: $process" -ForegroundColor Red
    }
    catch {
        Write-Host "Prozess $process nicht gefunden oder kann nicht beendet werden" -ForegroundColor Gray
    }
}

# Kurze Pause um Prozesse vollständig zu beenden
Start-Sleep -Seconds 3

# 2. Adobe Creative Cloud Autostart deaktivieren
Write-Host "`nDeaktiviere Adobe Creative Cloud Autostart..." -ForegroundColor Yellow

# Scheduled Tasks für Adobe deaktivieren
$adobeTasks = Get-ScheduledTask | Where-Object {$_.TaskName -like "*Adobe*" -or $_.TaskName -like "*Creative*"}
foreach ($task in $adobeTasks) {
    try {
        Disable-ScheduledTask -TaskName $task.TaskName -ErrorAction SilentlyContinue
        Write-Host "Deaktiviere Task: $($task.TaskName)" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Task $($task.TaskName) konnte nicht deaktiviert werden" -ForegroundColor Gray
    }
}

# 3. Registry-Einträge für Adobe entfernen
Write-Host "`nEntferne Adobe Registry-Einträge..." -ForegroundColor Yellow

$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
)

foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        $entries = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
        if ($entries) {
            $entries.PSObject.Properties | Where-Object {$_.Name -like "*Adobe*" -or $_.Name -like "*Creative*" -or $_.Value -like "*Adobe*"} | ForEach-Object {
                try {
                    Remove-ItemProperty -Path $path -Name $_.Name -Force -ErrorAction SilentlyContinue
                    Write-Host "Entferne Registry: $($_.Name)" -ForegroundColor Red
                }
                catch {
                    Write-Host "Konnte Registry-Eintrag $($_.Name) nicht entfernen" -ForegroundColor Gray
                }
            }
        }
    }
}

# 4. Services deaktivieren
Write-Host "`nDeaktiviere Adobe Services..." -ForegroundColor Yellow

$adobeServices = @(
    "AdobeARMservice",
    "AdobeUpdateService",
    "CCLibrary",
    "Creative Cloud",
    "Adobe Genuine Service",
    "AGSService",
    "Adobe Acrobat Update Service"
)

foreach ($service in $adobeServices) {
    try {
        $serviceObj = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($serviceObj) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "Deaktiviere Service: $service" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Service $service nicht gefunden" -ForegroundColor Gray
    }
}

# 5. Startup-Ordner bereinigen
Write-Host "`nBereinige Startup-Ordner..." -ForegroundColor Yellow

$startupPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
)

foreach ($startupPath in $startupPaths) {
    if (Test-Path $startupPath) {
        Get-ChildItem $startupPath -Filter "*Adobe*" -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue
        Get-ChildItem $startupPath -Filter "*Creative*" -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-Host "Startup-Ordner bereinigt: $startupPath" -ForegroundColor Green
    }
}

# 6. Zusätzliche Cleanup-Maßnahmen
Write-Host "`nFühre zusätzliche Cleanup-Maßnahmen durch..." -ForegroundColor Yellow

# Temporäre Dateien löschen
Get-ChildItem "C:\Users\*\AppData\Local\Temp\*Adobe*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
Get-ChildItem "C:\Windows\Temp\*Adobe*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

# 7. Finale Überprüfung
Write-Host "`nÜberprüfe ob noch Adobe-Prozesse laufen..." -ForegroundColor Cyan

$remainingProcesses = Get-Process | Where-Object {$_.ProcessName -like "*Adobe*" -or $_.ProcessName -like "*Creative*"}
if ($remainingProcesses) {
    Write-Host "Warnung: Folgende Adobe-Prozesse laufen noch:" -ForegroundColor Red
    $remainingProcesses | ForEach-Object { Write-Host "  - $($_.ProcessName)" -ForegroundColor Red }
    
    # Erneutes Beenden versuchen
    $remainingProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Keine Adobe-Prozesse mehr aktiv!" -ForegroundColor Green
}

Write-Host "`nBereinigung abgeschlossen!" -ForegroundColor Green
Write-Host "Starten Sie den Computer neu um alle Änderungen zu übernehmen." -ForegroundColor Cyan

# 8. Überwachungsskript für zukünftige Starts
Write-Host "`nÜberwachungsskript erstellen..." -ForegroundColor Magenta

$monitorScript = @"
`$Watcher = {
    while (`$true) {
        `$adobeProcesses = Get-Process | Where-Object {`$_.ProcessName -like "*Adobe*" -or `$_.ProcessName -like "*Creative*"}
        if (`$adobeProcesses) {
            Write-Host "Adobe Prozess erkannt und beendet: `$(`$adobeProcesses.ProcessName)" -ForegroundColor Yellow
            `$adobeProcesses | Stop-Process -Force
        }
        Start-Sleep -Seconds 10
    }
}

Start-Job -ScriptBlock `$Watcher -Name "AdobeMonitor"
"@

$monitorScript | Out-File -FilePath "$env:USERPROFILE\Desktop\Adobe_Monitor.ps1" -Encoding UTF8
Write-Host "Überwachungsskript erstellt: Adobe_Monitor.ps1 auf dem Desktop" -ForegroundColor Green

Write-Host "`nZusätzliche manuelle Schritte:" -ForegroundColor Yellow
Write-Host "1. Task-Manager -> Autostart: Deaktiviere alle Adobe-Einträge"
Write-Host "2. Creative Cloud App: Einstellungen -> Allgemein -> 'Beim Start von Windows' deaktivieren"
Write-Host "3. System neu starten um Änderungen zu überprüfen"