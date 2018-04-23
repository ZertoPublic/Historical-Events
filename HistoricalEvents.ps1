#requires -Version 5
#requires -RunAsAdministrator
<#
.SYNOPSIS
   This script queries the Zerto Events API and outputs the events to an XML file. 
.DESCRIPTION
   Detailed explanation of script
.EXAMPLE
   Examples of script execution
.VERSION 
   Applicable versions of Zerto Products script has been tested on.  Unless specified, all scripts in repository will be 5.0u3 and later.  If you have tested the script on multiple
   versions of the Zerto product, specify them here.  If this script is for a specific version or previous version of a Zerto product, note that here and specify that version 
   in the script filename.  If possible, note the changes required for that specific version.  
.LEGAL
   Legal Disclaimer:

----------------------
This script is an example script and is not supported under any Zerto support program or service.
The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without 
limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability 
to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages.  The entire risk arising out of the use or 
performance of the sample scripts and documentation remains with you.
----------------------
#>
#------------------------------------------------------------------------------#
# Declare variables
#------------------------------------------------------------------------------#
#Examples of variables:

##########################################################################################################################
#Any section containing a "GOES HERE" should be replaced and populated with your site information for the script to work.#  
##########################################################################################################################
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

$strZVMIP = "ZVM IP"
$zvpPort = "9669"
$strVCUser = "vCenter User Account"
$strVCPw = "vCenter Password"
$outFile = "C:\EventsList-AlertTurnedOnLastWeek.xml"
$TypeXML = "application/xml"
#------------------------------------------------------------------------------#
# Nothing to configure below this line
#------------------------------------------------------------------------------#
Write-Host -ForegroundColor Yellow "Informational line denoting start of script GOES HERE." 
Write-Host -ForegroundColor Red "   Legal Disclaimer:

----------------------
This script is an example script and is not supported under any Zerto support program or service.
The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without 
limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability 
to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages.  The entire risk arising out of the use or 
performance of the sample scripts and documentation remains with you.
----------------------
"
#------------------------------------------------------------------------------#
# Setting Cert Policy - required for successful auth with the Zerto API 
#------------------------------------------------------------------------------#
Write-Host "The cert policy original is  $([System.Net.ServicePointManager]::CertificatePolicy)"
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy -WarningAction SilentlyContinue
Write-Host "The cert policy is now  $([System.Net.ServicePointManager]::CertificatePolicy)"

#------------------------------------------------------------------------------#
#Authenticating with Zerto APIs
#------------------------------------------------------------------------------#
$xZertoSessionURI = "https://" + $strZVMIP + ":"+$zvpPort+"/v1/session/add"
$authInfo = ("{0}:{1}" -f $strVCUser,$strVCPw)
$authInfo = [System.Text.Encoding]::UTF8.GetBytes($authInfo)
$authInfo = [System.Convert]::ToBase64String($authInfo)
$headers = @{Authorization=("Basic {0}" -f $authInfo)}
$xZertoSessionResponse = Invoke-WebRequest -Uri $xZertoSessionURI -Headers $headers -Method POST

#------------------------------------------------------------------------------#
#Extracting x-zerto-session from the response, and adding it to the actual API
#------------------------------------------------------------------------------#
$xZertoSession = $xZertoSessionResponse.headers.get_item("x-zerto-session")

$zertoSessionHeader_xml = @{"Accept"="application/xml"
"x-zerto-session"=$xZertoSession}

#------------------------------------------------------------------------------#
#Invoking Zerto's API
#------------------------------------------------------------------------------#
$vpgListApiUrl = "https://" + $strZVMIP + ":"+$zvpPort+"/v1/events?eventType=AlertTurnedOn&startDate=2014-04-09&endDate=2014-04-16"
Invoke-RestMethod -Uri $vpgListApiUrl -TimeoutSec 100 -Headers $zertSessionHeader_xml -OutFile $outFile -ContentType $TypeXML
#https://zvm_ip:port/v1/events?startDate={STARTDATE}&endDate={ENDDATE}&vpg={VPG}&eventType={EVENTTYPE}&siteName={SITENAME}&entityType={ENTITYTYPE}&userName={USERNAME}
#------------------------------------------------------------------------------#
##End of script
#------------------------------------------------------------------------------#