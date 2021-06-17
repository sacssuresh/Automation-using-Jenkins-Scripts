param(
#[string]$destinationServer
)
#get server list from config file
$serverList = Get-Content -Path C:\JenkinsScripts\PROD\Config\AUTH_ListOfServers.txt
$session = New-PSSession -ComputerName $serverList
$Buildresult = 0


try
{

    $test1_Status = 0
    $test2_Status = 0
    
    $url = 'http://localhost:50005/api/partner?partnerId=3'
    'Running Test #1: ' + $url
    Invoke-Command -Session $session -ScriptBlock {

        $result = $null
        $result = Invoke-WebRequest $using:url
        
        if ($result.StatusCode -eq 200)
        {
          $json = $result.Content
        
          if ($json -eq '{"identifier":"bdbdc890-d51e-459f-9fec-dd1ac78fb1cb","partnerId":3,"name":"ConnectedHome","tenantId":3,"description":"ConnectedHome Default Partner"}')
          {
            '>>>Success!'
            $test1_Status = 1
          }
          else
          {
            '>>>Unexpected Result: '
            $result.Content
          }
        }
        else
        {
          '>>>Invalid http request'
          $result
        }
        
        
        '=================================='
        'Final results:'
        if ($test1_Status -eq 1)
        {
          'All tests passed!' + ' Executed at : ' + $env:COMPUTERNAME
        }
        else
        {
          'At least 1 test failed.'  + ' Executed at : ' + $env:COMPUTERNAME
        }
        ''
        ''
        
       # [void] (Read-Host 'Press ENTER to continue...')
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