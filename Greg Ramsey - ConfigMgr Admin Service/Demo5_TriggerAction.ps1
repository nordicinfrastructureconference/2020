

# Adopted from: https://www.asquaredozen.com/2019/11/29/configmgr-adminservice-and-wmi-methods-a-match-made-in-the-cloud-1910/

#region ignorelocalcerterror
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
 }


[ServerCertificateValidationCallback]::Ignore()
 #endregion

 <#
     "DownloadComputerPolicy" = 8
    "DownloadUserPolicy" = 9
    "CollectDiscoveryData" = 10
    "CollectSoftwareInventory" = 11
    "CollectHardwareInventory" = 12
    "EvaluateApplicationDeployments" = 13
    "EvaluateSoftwareUpdateDeployments" = 14
    "SwitchToNextSoftwareUpdatePoint" = 15
    "EvaluateDeviceHealthAttestation" = 16
    "CheckConditionalAccessCompliance" = 125
    "WakeUp" = 150
    "Restart" = 17
    "EnableVerboseLogging" = 20
    "DisableVerboseLogging" = 21

 #>
$SiteServer = "ssprps01.contoso.com"
$creds = Get-Credential

$PostURL = `
    "https://$SiteServer/AdminService/wmi/SMS_ClientOperation.InitiateClientOperation"
$Headers = @{
    "Content-Type" = "Application/json"
}


$targets = @(16777219,16777220)


$Body = @{
    TargetCollectionID = "SMS00001"
    Type = [uint32]8
    RandomizationWindow = 1
    TargetResourceIDs =  $targets
} | ConvertTo-Json

$body
    
$rq = Invoke-RestMethod -Method Post -Uri "$($PostURL)" -Body $Body `
    -Headers $Headers -Credential $creds 
$rq
$rq.OperationID

cmtrace c:\windows\ccm\logs\PolicyAgent.log


$PostURL = `
    "https://$SiteServer/AdminService/wmi/SMS_ClientOperationStatus(" + $rq.OperationID.tostring() + ")"
$rq = Invoke-RestMethod -Method Get -Uri "$($PostURL)" -Credential $creds 
$rq.value


