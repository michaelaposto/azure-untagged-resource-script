# Script to list untagged resources

# Create resource variable
$resources = Get-AzResource | Where-Object {$null -eq $_.Tags -or $_.Tags.Count -eq 0}

# Create results array which stores the untagged resources to be used in weekly email
$results = @()

# Loop to store the the untagged resources, resource type and the resource group in the results array
foreach ($resource in $resources){
    $results += New-Object PSObject -Property @{
        Name   = $resource.Name
        Type   = $resource.resourcetype 
        RGName = $resource.resourcegroupname
    }
}

# Test to see if the array is functioning correctly
Write-Output $results 

# Convert array into a .csv and send in email to azenix members 
$results | Export-Csv -Path "UntaggedResources.csv" -NoTypeInformation