param(
#[string]$destinationServer
)

$serverList = Get-Content -Path C:\JenkinsScripts\PROD\Config\FE_ListOfServers.txt
$session = New-PSSession -ComputerName $serverList
$Buildresult = 0
try
{
    Invoke-Command -Session $session -ScriptBlock {
    

        $test1_Status = 0
        
        $AGName = "tccprodbag.pmelapp.local"
        $PortNumber = 1433
        
        
        'Running Test #1--> Server: ' + $AGName + ', Port: ' + $PortNumber
        $result = $null
        $result = Test-NetConnection -Port $PortNumber -ComputerName $AGName -InformationLevel "Detailed"
        
        if ($result.RemoteAddress -ne "")
        {
          if ($result.TcpTestSucceeded)
          {
            '>>>Success!'
            $test1_Status = 1
          }
          else
          {
            '>>>Connection failed on port ' + $PortNumber + ' to server ' + $AGName
          }
        }
        else
        {
          ">>>Failed to resolve hostname for " + $AGName
        }
        
        
        '=================================='
        'Final results:'
        if ($test1_Status -eq 1) 
        {
          'All tests passed!' + ' Executed at : ' + $env:COMPUTERNAME
        }
        else
        {
          'At least 1 test failed.' + ' Executed at : ' + $env:COMPUTERNAME
        }
        ''
        ''
        
        #[void] (Read-Host 'Press ENTER to continue...')
        #End of file

    } -ErrorAction Stop

$Buildresult = 0
}
catch
{
   $Buildresult = 1
   Write-Host $_
   Write-Host "Build is FAILURE $($Buildresult)"
}
finally
{
    Remove-PSSession $session
}
