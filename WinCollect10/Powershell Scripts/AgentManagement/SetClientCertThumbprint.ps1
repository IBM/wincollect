#Checks the "My" (or "Personal") certificate store of the local machine for a certificate issued to this machine.
#Make sure to replace <hostname> with your machine's hostname
[Environment]::SetEnvironmentVariable(
        'WC_CLIENT_CERT_THUMBPRINT', 
        (Get-ChildItem -Path cert:\LocalMachine\My | 
        Where-Object Subject -Like "*CN=<hostname>*" | 
        Select-Object -First 1).Thumbprint, 
        'Machine')
