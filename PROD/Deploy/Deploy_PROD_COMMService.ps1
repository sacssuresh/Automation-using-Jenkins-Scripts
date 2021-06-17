
param(
[string]$destinationServer,
[string] $username,
[string]$password
)



#creating credential parameter for authentication
$pwd = ConvertTo-SecureString $password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($username, $pwd)

#creating session for all servers in list
$session = New-PSSession -ComputerName $destinationServer -Credential $Cred


$result = 0

Write-Host "                Server Name         Service Name        Status"
Write-Host "                ------------------------------------------------"

try
{

    
        Invoke-Command -Session $session -ScriptBlock {
    

            #get service TrueHome2ServiceHost in variable

            $service = Get-Service -Name "TrueHome2CommunicationServiceHost"

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
                    Write-Host "Exception :In $($env:computername), The service $($service.Name) is  $($service.Status) "
                }

            }
            else
            {
                Write-Host "Exception :In $($env:computername), The service $($service.Name) is  $($service.Status) "
            }              
    
    } -ErrorAction Stop


        $result = 0
    
}
catch
{
    $result = 1
    Write-Host $_
    Write-Host "result is FAILURE" $result
}

exit $result


