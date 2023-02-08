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

# Beginning of html email script segment

$smtp = "smtp.azenix.com.au"
$emailFrom = "Azure Cleanup Team"
$emailTo = "michael.aposto@azenix.com.au"
$subject = "Azure PAYG resource cleanup - Untagged resources"

# HTML Template
$emailBody = @"
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Untagged resource EDM</title>
  </head>
  <body style="margin: 0; padding: 0;">
  <!-- Header -->
    <table style="width: 100%; background-color: #0080FF;">
        <tr>
            <td style="padding: 20px;">
                <h1 style="text-align: center; font-weight: bold; color= #fff;">Azenix Azure Cleanup Weekly Audit</h1>
            </td>
        </tr>
    </table>

  <!-- Body -->
    <table style="width: 100%; padding: 40px;">
        <tr>
            <td>
                <p style="font-size: 18px; color: #000;">This email is a reminder to tag the resources in the Azenix Azure PAYG subscription.</p>
                <p style="font-size: 18px; color: #000;">The following resources are untagged, please either tag or remove them from the subscription.</p>
                <p style="font-size: 18px; color: #000;">ScriptOutput</p>
            </td>
        </tr>
        <tr>
        	<td>
            	<p style="font-size: 18px; color: #000;">Regards,</p>
            </td>
        </tr>
    </table>
    
    <!-- Footer -->
    <table style="width: 100%; background-color: #333;">
        <tr>
            <td style="padding: 20px; color: #fff;">
                <p style="text-align: center; font-size: 12px;">Please report issues with this email to michael.aposto@azenix.com.au</p>
            </td>
        </tr>
    </table>
  </body>
</html>
"@

# Replace ScriptOutput text with untagged script results
 $emailBody = $emailBody.Replace("ScriptOutput", $results)

# Send email

Send-MailMessage -To $emailTo -From $emailFrom -Subject $subject -Body $emailBody -BodyAsHtml -SmtpServer $smtp
