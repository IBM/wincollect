try
{
    Write-Host "Getting restricted groups"
    $tempFile = "C:\GroupPolicyResult.txt"
    Gpresult /V /scope Computer > $tempFile
    if (Test-Path -Path $tempFile)
    {
        $Start = Select-String $tempFile -pattern "Restricted" | Select-Object LineNumber
        $End = Select-String $tempFile -pattern "System Services" | Select-Object LineNumber
        for($i = $Start.LineNumber; $i -lt $End.LineNumber; $i += 1)
        {
            $temp += Get-Content -Path $tempFile | Select-Object -Index $i
        }
        Remove-Item -Path $tempFile -Force
        if (($temp -clike "*Groupname: Administrators*") -and ($temp -clike "*Groupname: Event Log Readers*"))
        {
            Write-Host "Administrators and Event Log Readers groups are part of restricted groups. So the agent may not have been installed correctly"
        }
        else {
            Write-Host "Administrators and Event Log Readers groups are not part of restricted groups"
        }
    }
}
catch {
    Write-Error "Error finding restricted groups"
}

Write-Host "GroupPolicy.ps1 is finished"