
param(
[string] $username,
[string]$password
)

do not run

#creating credential parameter for authentication
$pwd = ConvertTo-SecureString $password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($username, $pwd)

#get server list from config file
$serverList = "QAMELAPPS01"

#get TH service name from config file
$ThService = Get-Content -Path C:\JenkinsScripts\QA\Config\logpusherService.txt

#creating session for all servers in list
$session = New-PSSession -ComputerName $serverList -Credential $Cred


$result = 0

Write-Host "                Server Name         Service Name        Status"
Write-Host "                ------------------------------------------------"

try
{

        #to check if files are empty
    if(([String]::IsNullOrWhiteSpace($serverList)) -or ([String]::IsNullOrWhiteSpace($ThService) ))
    {
    
        throw "List of servers or List or Services files are empty"

        
    
    }
    else
    {
        Invoke-Command -Session $session -ScriptBlock {
    

            #get service TrueHome2ServiceHost in variable

            $service = Get-Service -Name $using:ThService -ErrorAction SilentlyContinue

            if([String]::IsNullOrEmpty($service) )
            {
          
                throw "The service $using:ThService does not exist in $env:computername"
            }
            else
            {
             Write-Host "Current Status : $($env:computername),    $($service.Name),     $($service.Status)"

                if($service.Status -eq "Running")
                {
                    
                    throw "running service exception"
                }

                Write-Host "after if block"
               
            }
                  
    
    } -ErrorAction Stop 


        $result = 0

    }

    
        
    
}
catch
{
    $result = 1
    Write-Host $_
    Write-Host "result is FAILURE" $result
}

exit $result


