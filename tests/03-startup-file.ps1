# Run in an isolated Windows lab VM. Creates a harmless text file.
$startup = [Environment]::GetFolderPath('Startup')
$path = Join-Path $startup 'wazuh-lab-demo.txt'
Set-Content -Path $path -Value 'Wazuh Startup folder FIM demo' -Encoding ASCII
Write-Host "Created: $path"
Write-Host "Cleanup: Remove-Item -Force '$path'"
