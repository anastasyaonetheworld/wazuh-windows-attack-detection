# Run ONLY on your isolated Windows lab VM as administrator.
# Creates a harmless Run entry pointing to notepad.exe.
$key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
New-ItemProperty -Path $key -Name 'WazuhLabDemo' -Value "$env:WINDIR\System32\notepad.exe" -PropertyType String -Force | Out-Null
Write-Host 'Run value created: WazuhLabDemo'
Write-Host "Cleanup: Remove-ItemProperty -Path '$key' -Name 'WazuhLabDemo'"
