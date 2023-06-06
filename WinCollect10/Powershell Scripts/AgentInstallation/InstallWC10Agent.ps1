
$file = '\\yournetworkshare\wincollect\10\wincollect-10.0.1-276.x64.msi'
$computerName = 'yourtargetendpoint'


$session = New-PSSession -ComputerName $computerName
Copy-Item -Path $file -ToSession $session -Destination c:\windows\temp\wincollect-10.0.1-276.x64.msi

Invoke-Command -Session $session -ScriptBlock {
    Start-Process msiexec.exe -Wait -ArgumentList '/i C:\Windows\Temp\wincollect-10.0.1-276.x64.msi QUICK_INSTALL="yes" WC_DEST="172.18.233.102" ADMIN_GROUP="true"'
}
Remove-PSSession $session
