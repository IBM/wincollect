#Checks the "My" (or "Personal") certificate store of the local machine for a certificate issued to this machine
param 
(
    [string]$hostname = $env:computername
)

Write-Output "Searching for certificate issued to '$hostname' in LocalMachine certificate store 'Personal'"
[Environment]::SetEnvironmentVariable(
        'WC_CLIENT_CERT_THUMBPRINT', 
        (Get-ChildItem -Path cert:\LocalMachine\My | 
        Where-Object Subject -Like "*CN=$hostname*" | 
        Select-Object -First 1).Thumbprint, 
        'Machine')
