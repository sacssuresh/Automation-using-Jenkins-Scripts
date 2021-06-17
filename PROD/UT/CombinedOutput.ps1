$Logfile = "C:\JenkinsScripts\PROD\Output\AuthOutput.log"
$CombinedOutput = (Select-String -Path $Logfile -Pattern "Final results:" -Context 1).Context.PostContext
$CombinedOutput


