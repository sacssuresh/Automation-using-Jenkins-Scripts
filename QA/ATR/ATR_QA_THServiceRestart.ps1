
param(
[string]$destinationServer,
[string] $username,
[string]$password
)

#creating credential parameter for authentication
$pwd = ConvertTo-SecureString $password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($username, $pwd)

#taking TH service name from config file
$ThService = Get-Content -Path C:\JenkinsScripts\QA\Config\ATR_QA_THService.txt
$ThService.Trim() #remove whitespaces 

#creating session for server
$session = New-PSSession -ComputerName $destinationServer -Credential $Cred

$BuildResult = 0

try
{
  
    
        Invoke-Command -Session $session -ScriptBlock {    

            #get service TrueHome2ServiceHost in variable

            $service = Get-Service -Name $using:ThService -ErrorAction SilentlyContinue


            #to check if service is present in server : in case wrong service name is passed script should not run/throw exception

            if([String]::IsNullOrEmpty($service) )
            {
                
                throw "The service $($service.Name) does not exist in $env:computername"
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
                    Write-Host "Stopping service at : $($env:computername),  $($service.Name) $($service.Status)"


                    if($service.Status -eq "Stopped") #to check if service is stopped once more, before starting service
                    {
                        #starting service 
                        $service.Start()
                        $service.WaitForStatus('Running')               
                        $service.Refresh()
                        Write-Host "Starting service at : $($env:computername),    $($service.Name),   $($service.Status)" 

                    }
                    else
                    {                       

                        #if service is other than RUNNING it will throw exception
                        throw  "Exception :In $($env:computername), The service $($service.Name) is $($service.Status) "
                    }

                }
                else
                {                   

                     #if service is other than STOPPED it will throw exception and script wil terminate
                     throw  "Exception :In $($env:computername), The service $($service.Name) is $($service.Status) "
                }   
            }           
    
         } -ErrorAction Stop


 $BuildResult = 0
     
    
}
catch
{
    $BuildResult = 1
    Write-Host $_
    Write-Host "Build result is FAILURE" $BuildResult
}
finally
{            
    Remove-PSSession $session # to end session
}

exit $BuildResult


