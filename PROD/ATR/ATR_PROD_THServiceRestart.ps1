
param(
[string] $username,
[string]$password
)

#do not run


#creating credential parameter for authentication
$pwd = ConvertTo-SecureString $password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($username, $pwd)

#get server list from config file
$serverList = Get-Content -Path C:\JenkinsScripts\PROD\Config\TH_ListOfServers.txt

#get TH service name from config file
$ThService = Get-Content -Path C:\JenkinsScripts\PROD\Config\ATR_PROD_THService.txt

#creating session for all servers in list
$session = New-PSSession -ComputerName $serverList -Credential $Cred


$BuildResult = 0

try
{

  $jobresult =  Invoke-Command -Session $session -ThrottleLimit 5 -ScriptBlock {
    

            #get service TrueHome2ServiceHost in variable

            $service = Get-Service -Name $using:ThService -ErrorAction SilentlyContinue

            if([String]::IsNullOrEmpty($service) )
            {
                
                throw "The service  $($service.Name) does not exist in $env:computername"
            }
            else
            {
                 Write-Host "Current Status : $($env:computername),    $($service.Name),     $($service.Status)"

          <#  fgdfg    if($service.Status -eq "Running") #to check if service is running
                {
                    #stopping service
                    $service.Stop()
                    $service.WaitForStatus('Stopped')
                    $service.Refresh()
                    Write-Host "Stopping service at : $($env:computername),    $($service.Name),     $($service.Status)"


                    if($service.Status -eq "Stopped") #to check if service is stopped once more, before starting service
                    {
                        #starting service 
                        $service.Start()
                        $service.WaitForStatus('Running')               
                        $service.Refresh()
                        Write-Host "Starting service at : $($env:computername),    $($service.Name),     $($service.Status)"

                    }
                    else
                    {
                        throw "Exception :In $($env:computername), The service $($service.Name) is  $($service.Status)"
                    }

                }
                else
                {
                     throw "Exception :In $($env:computername), The service $($service.Name) is  $($service.Status)"
                }  #>  
            }

                    
    
    } -ErrorAction Stop -AsJob

$jobresult | Wait-Job #wait until job are completed

Receive-Job -Id $jobresult.Id #to get output of job

$BuildResult = 0
      
    
}
catch
{
    $BuildResult = 1
    Write-Host $_
    Write-Host "result is FAILURE" $BuildResult
}
finally
{            
    Remove-PSSession $session # to end session
}

exit $BuildResult


