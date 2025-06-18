$info = Get-ComputerInfo
$xmlString = $info | ConvertTo-Xml -As String -Depth 3
$xmlString | Out-File -FilePath "C:\Skripte\computerinfo.xml" -Encoding UTF8