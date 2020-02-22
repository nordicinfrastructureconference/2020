#region ignorelocalcerterror
#https://spiderip.com/blog/2018/06/powershell-invoke-webrequest-ignore-certificate-warning
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

$SiteServer = "ssprps01.contoso.com"
$creds = Get-Credential

#basic query
Invoke-RestMethod -Uri "https://$SiteServer/AdminService/v1.0/" -Credential $creds





$rq = $null
$rq = Invoke-RestMethod -Uri "https://$SiteServer/AdminService/v1.0/" -Credential $creds
$rq.value | Out-GridView






$rq = Invoke-RestMethod -Uri "https://$SiteServer/AdminService/wmi/SMS_Collection" `
    -Credential $creds
$rq.value | Out-GridView
$rq.value | where-object {$_.membercount -gt 2} | out-gridview



Function get-wmiresource($WMIClass) {
$rq = Invoke-RestMethod -Uri "https://$SiteServer/AdminService/wmi/$WMIClass" `
    -Credential $creds

$rq.value
}

get-wmiresource SMS_Collection | select name, localmembercount 



#The one big take-away when going from a web page to PowerShell
$rq = $null
$rq = invoke-restmethod `
    "https://$SiteServer/AdminService/wmi/SMS_R_System?$filter=ResourceId eq 16777219" `
    -Credential $creds
$rq.value | select name





#need to use the backtick (escape character)
$rq = $null
$rq = invoke-restmethod `
    "https://$SiteServer/AdminService/wmi/SMS_R_System?`$filter=ResourceId eq 16777219" `
    -Credential $creds
$rq.value | select name







#Create a new Package
$PostURL = "https://$SiteServer/AdminService/wmi/SMS_Package"
$Headers = @{
    "Content-Type" = "Application/json"
}

$Body = @{
    Name = "7-zip"
    PkgSourcePath =  "\\ssprps01\c$\Source\7-zip"
} | ConvertTo-Json

$body
    
$rq = Invoke-RestMethod -Method Post -Uri "$($PostURL)" -Body $Body `
    -Headers $Headers -Credential $creds 
$rq




#Create a Program
$PostURL = "https://$SiteServer/AdminService/wmi/SMS_Program"
$Headers = @{
    "Content-Type" = "Application/json"
}

$Body = @{
    PackageID = $rq.PackageID
    ProgramName =  "x64 Install"
    CommandLine = "7z1900-x64.exe /s"
} | ConvertTo-Json

$body
    
$rq = Invoke-RestMethod -Method Post -Uri "$($PostURL)" -Body $Body `
    -Headers $Headers -Credential $creds 
$rq








#Update a Package
$PostURL = "https://ssprps01.contoso.com/AdminService/wmi/SMS_Package"
$Headers = @{
    "Content-Type" = "Application/json"
}

$Body = @{
    PackageID = $rq.PackageID
    Name = "7-zip"
    Description =  "Freeware"
} | ConvertTo-Json

$body
    
$rq = Invoke-RestMethod -Method Post -Uri "$($PostURL)" -Body $Body `
    -Headers $Headers -Credential $creds 
$rq








#Delete a Package
$PostURL = `
    "https://ssprps01.contoso.com/AdminService/wmi/SMS_Package('$($rq.packageID)')"
$PostURL
$rq = Invoke-RestMethod -Method Delete -Uri "$($PostURL)" -Credential $creds 
$rq