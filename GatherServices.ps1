#Global variable used to keep count through servers.txt list
$Global:Count = 0

#Output to console
Write-Host "`nScript executed by $env:username for $(Get-Date -f ""MM-dd-yyyy hh:mm:ss"")"

#Check if a C:\temp\servers.txt exists 
$FileCheck = Test-Path C:\temp\servers.txt

#Based on outcome if $FileCheck, the script will run accordingly...
if ($FileCheck -eq $True)
{
    #Output to console
    Write-Host "Script found c:\temp\servers.txt"
    Write-Host "Script is executing query against list of servers in c:\temp\servers.txt..."

    #Get contents of C:\temp\servers.txt into a variable
    $Servers = gc C:\temp\servers.txt

    #Loops through each server name in C:\temp\servers.txt
    #This script does not attempt to ping your server
    #Please ensure you are actually able to ping the server first
    foreach ($Server in $Servers)
    {

        #This queries the win32_service wmiobject for all running services
        #and selects the relevant data fields only
        #then exports it to csv
        $Query = Get-WmiObject "Win32_Service" -ComputerName $Server | Where {$_.State -eq 'Running'} | Select Name, State, StartName, Status, PathName, StartMode, AcceptPause, AcceptStop, Caption, Description | Export-Csv c:\temp\$(hostname)_servicesOutput.csv -NoTypeInformation
        
        #Increments counter variable after each query
        $Global:Count ++

        #Checks if the script has reached the bottom of C:\temp\servers.txt
        if ($Global:Count -eq ($Servers | Measure-Object -Line | Select -ExpandProperty Lines))
        {
            #Output to console
            Write-Host "Script execution completed; please check below files:`n"

            #Lists the files to console
            ls c:\temp\*servicesOutput.csv | Select Name, LastWriteTime, Length | ft -AutoSize
        }
    }
}

#If the script cannot find the C:\temp\servers.txt file
else 
{
    Write-Host "Script could not find a c:\temp\servers.txt"
    Write-Host "Script exiting..."
    Exit
}

