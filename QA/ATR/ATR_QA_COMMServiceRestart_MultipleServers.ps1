
param(
[string] $username,
[string]$password
)

#creating credential parameter for authentication
$pwd = ConvertTo-SecureString $password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($username, $pwd)

#get server list from config file
$serverList = Get-Content -Path C:\JenkinsScripts\QA\Config\ListOf_QA_Servers.txt

#get TH service name from config file
$CommService = Get-Content -Path C:\JenkinsScripts\QA\Config\ATR_QA_COMMService.txt

#creating session for all servers in list
$session = New-PSSession -ComputerName $serverList -Credential $Cred


$BuildResult = 0

try
{
    ### This script uses for loop instead of parallely invoke due to issues in QAMELAPPS02 machine ###
    for(($i = 0); $i -lt $session.Count ; ($i++))
    {
        Invoke-Command -Session $session[$i] -ScriptBlock {
    

            #get service TrueHome2ServiceHost in variable
            
            $service = Get-Service -Name $using:CommService -ErrorAction SilentlyContinue
          
          if([String]::IsNullOrEmpty($service) )
            {
                
                throw "The service  $($service.Name) does not exist in $env:computername"
            }
            else
            {

                Write-Host "Current Status : $($env:computername),    $($service.Name),     $($service.Status)"

               if($service.Status -eq "Running") #to check if service is running
                {
					Write-Host "Stopping service at : $($env:computername),  $($service.Name)"
                    #stopping service
                    $service.Stop()
                    $service.WaitForStatus('Stopped')
                    $service.Refresh()

                    if($service.Status -eq "Stopped") #to check if service is stopped once more, before starting service
                    {
                        Write-Host "Starting service at : $($env:computername),  $($service.Name) "
                        $service.Start()
                        $service.WaitForStatus('Running')               
                        $service.Refresh()
                        Write-Host "Latest Status : $($env:computername),    $($service.Name),     $($service.Status)"

                    }
                    else
                    {
                        throw "Exception :In $($env:computername), The service $($service.Name) is  $($service.Status) "
                    }

                }
                else
                {
                    throw "Exception :In $($env:computername), The service $($service.Name) is  $($service.Status) "
                }    

              }          
    
        } -ErrorAction Stop
    }
      


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