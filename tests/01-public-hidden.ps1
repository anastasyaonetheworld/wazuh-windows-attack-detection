# Run in an isolated Windows lab VM. No administrator privilege required.
$path = 'C:\Users\Public\wazuh-lab-demo.txt'
Set-Content -Path $path -Value 'Wazuh FIM laboratory demo' -Encoding ASCII
(Get-Item $path).Attributes = (Get-Item $path).Attributes -bor [IO.FileAttributes]::Hidden
Write-Host "Created and hidden: $path"
Write-Host "Cleanup: Remove-Item -Force '$path'"
