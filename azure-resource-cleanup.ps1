param (
    $EmailUser,
    $EmailPass
)

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

# Gmail and Gmail account to&from
$SmtpServer = "smtp.gmail.com"
$SmtpPort = "587"
$EmailFrom = "michael.aposto26@azenix.com.au"
$EmailTo = "michael.aposto@azenix.com.au"

# Email Credentials
#$EmailUser = ""
#$EmailPass = "" | ConvertTo-SecureString -AsPlainText -Force

# Email message
$EmailMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo)
$EmailMessage.Subject = "Azure PAYG resource cleanup - Untagged resources"
$EmailMessage.Attachments("./UntaggedResources.csv")
$EmailMessage.IsBodyHtml = $true
$EmailMessage.Body = @"
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
$EmailMessage.Body = $EmailMessage.Body.Replace("ScriptOutput", $results)

# SMTP client and passing HTML body and credentials into message
$SmtpClient = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort)
$SmtpClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailUser, $EmailPass);
$SMTPClient.Send($EmailMessage)
