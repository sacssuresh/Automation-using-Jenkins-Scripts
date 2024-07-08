
param(
[string]$destinationServer,
[string] $username,
[string]$password
)



#creating credential parameter for authentication
$pwd = ConvertTo-SecureString $password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($username, $pwd)

#taking COMM service name from config file
$CommService = Get-Content -Path C:\JenkinsScripts\QA\Config\ATR_QA_COMMService.txt


#creating session for all servers in list
$session = New-PSSession -ComputerName $destinationServer -Credential $Cred


$BuildResult = 0


try
{

    
        Invoke-Command -Session $session -ScriptBlock {
    

            #get comm service in variable

            $service = Get-Service -Name $using:CommService -ErrorAction SilentlyContinue

             #to check if service is present in server : in case wrong service name is passed script should not run/throw exception

            if([String]::IsNullOrEmpty($service) )
            {
                
                throw "The service $using:ThService does not exist in $env:computername"
            }
            else
            {

                Write-Host "Current Status : $($env:computername),    $($service.Name),     $($service.Status)"

                if($service.Status -eq "Running") #to check if service is running
                {
                    #stopping service
                    $service.Stop()
                    $service.WaitForStatus('Stopped')
                    $service.Refresh()
                    Write-Host "Latest Status : $($env:computername),    $($service.Name),     $($service.Status)"


                    if($service.Status -eq "Stopped") #to check if service is stopped once more, before starting service
                    {
                        #starting service 
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


        $BuildResult = 0
    
}
catch
{
    $BuildResult = 1
    Write-Host $_
    Write-Host "result is FAILURE" $BuildResult
}

exit $BuildResult


