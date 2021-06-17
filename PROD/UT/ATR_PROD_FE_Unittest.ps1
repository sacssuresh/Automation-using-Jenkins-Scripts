param(
#[string]$destinationServer # NEED TO BE RUN ON PMELFE01

)


$serverList = Get-Content -Path C:\JenkinsScripts\PROD\Config\FE_ListOfServers.txt
#creating session for server
$session = New-PSSession -ComputerName $serverList 

$BuildResult = 0

$test1_Status = 0
$test2_Status = 0

$url = 'http://localhost:50004/api/identity?userId=3'
'Running Test #1: ' + $url
try
{      
        Invoke-Command -Session $session -ScriptBlock {  

        $result = $null
        $result = Invoke-WebRequest $using:url
        
        if ($result.StatusCode -eq 200)
        {
          if ($result.Content -eq '3')
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
        
        $url = 'http://localhost:50004/api/identity?userId=592610'
        'Running Test #2: ' + $url
        
        $result = $null
        $result = Invoke-WebRequest $url
        
        if ($result.StatusCode -eq 200)
        {
          if ($result.Content -eq '0')
          {
            '>>>Success!'
            $test2_Status = 1
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
        if (($test1_Status -eq 1) -and ($test2_Status -eq 1))
        {
          'All tests passed!' + ' Executed at : ' + $env:COMPUTERNAME
        }
        else
        {
          'At least 1 test failed.' + ' Executed at : ' + $env:COMPUTERNAME
        }
        ''
        ''
    } -ErrorAction Stop
 $BuildResult = 0 
 }
catch
{
    $BuildResult = 1
    Write-Host $_
    Write-Host "Build result is FAILURE" $BuildResult
}

exit $BuildResult

#End of file