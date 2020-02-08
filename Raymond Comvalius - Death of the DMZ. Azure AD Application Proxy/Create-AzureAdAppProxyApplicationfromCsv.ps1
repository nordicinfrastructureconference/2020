<#
.Synopsis
Create and configure applications published with Azure AD Application Proxy.
Input is provided by a CSV file.
Script has been tested with Kerberos and Passthrough authentication.

.Description


.Example
Create-AzureAdAppProxyApplicationfromCsv -CsvName Filename.csv -verbose | out-file .\AADAP-App-Create.log

Fields in the CSV:
AppName,ExternalURL,InternalURL,AppSPN,ConnectorGroup,AllowGroup,Owner

AppName,ExternalURL, and InternalURL are required fields

Defaults are:
$ConnectorGroup = "Default"
$AadGroupName = <None>
$ApplicationSpn = <No SSO>
$OwnerUPN = <None>

.Link
New-AzureADApplicationProxyApplication
#>



Param
(
[parameter(mandatory=$true,HelpMessage="Please, provide an CSV name.")]
[ValidateNotNullOrEmpty()]
$CsvName
)

Write-Verbose -Message "Importing the Csv '$CsvName'"
$Apps = Import-Csv $CsvName -Delimiter ";"


Foreach ($App in $Apps) {
$AppName = $App.AppName
Write-Verbose -Message "Populating Application: '$AppName'"

if ((Get-AzureADApplication -Filter "DisplayName eq '$AppName'").count -gt 0) {
    #Modify the existing application
    $AppObjectId =  (Get-AzureADApplication -Filter "displayName eq '$AppName'").ObjectId
    Write-Verbose -Message "Set-AzureADApplication properties for '$AppNAme' with ID '$AppObjectId'"
    Set-AzureADApplicationProxyApplication -ObjectId $AppObjectId -ExternalUrl $App.ExternalURL -InternalUrl $App.InternalURL

} else {
    #Create a new application
    # Publish a new Azure AD Application Proxy Application with SSO Mode: None
    Write-Verbose -Message "Create New-AzureADApplication '$AppNAme'"
    New-AzureADApplicationProxyApplication -DisplayName $App.AppName -ExternalUrl $App.ExternalURL -InternalUrl $App.InternalURL 
    $AppObjectId =  (Get-AzureADApplication -Filter "displayName eq '$AppName'").ObjectId
}

# Set the Connector Group Name
if ($App.ConnectorGroup) {
    Write-Verbose -Message "Connector Group to be used is '$($App.ConnectorGroup)'."
    $ConnectorGroupName = $App.ConnectorGroup
} else {
    Write-Verbose -Message "Default Connector group will be used."
    $ConnectorGroupName = "Default"
}


$ConnectorGroupId = (Get-AzureADApplicationProxyConnectorGroup -Filter "name eq '$ConnectorGroupName'").Id
Write-Verbose -Message "Configuring '$ConnectorGroupName' with ID '$ConnectorGroupId' as the Connector group."
Set-AzureADApplicationProxyApplication -ObjectId $AppObjectId -ConnectorGroupId $ConnectorGroupId 

#Enable Inbody link translation when using msappproxy.net for external URL
if ($App.ExternalURL -contains '.msappproxy.net') {
    Write-Verbose -Message "Enabling in body link translation for .msappproxy.net external URL."
    Set-AzureADApplicationProxyApplication -ObjectId $AppObjectId -IsTranslateLinksInBodyEnabled $true
} else {
    Write-Verbose -Message "Disable in body link translation for custom domain external URL."
    Set-AzureADApplicationProxyApplication -ObjectId $AppObjectId -IsTranslateLinksInBodyEnabled $false
}

# Set Application SPN and enable Kerberos KCD when SPN is defined
if ($App.AppSPN) {
    Write-Verbose -Message "Configuring Kerberos SSO for the application '$AppObjectID'." 
    Set-AzureADApplicationProxyApplicationSingleSignOn -ObjectId $AppObjectId -SingleSignOnMode OnPremisesKerberos -KerberosInternalApplicationServicePrincipalName $App.AppSPN -KerberosDelegatedLoginIdentity OnPremisesUserPrincipalName
} else {
    Write-Verbose -Message "Disabling SSO for the application '$AppObjectID'." 
    Set-AzureADApplicationProxyApplicationSingleSignOn -ObjectId $AppObjectId -SingleSignOnMode None
} #if SSOMode = Kerberos


# Configure the Authorization for an Azure AD Group
$AppResourceId = (Get-AzureADServicePrincipal -Filter "displayName eq '$AppName'").ObjectId
$AllowGroup = $App.AllowGroup
If ($AllowGroup) {
    Write-Verbose -Message "Obtain Group Object ID for '$($AllowGroup)'."
    $AadGroupObjectId = (Get-AzureADGroup -Filter "displayName eq '$AllowGroup'").ObjectId


    Write-Verbose -Message "Obtain the application resource ID for '$AppName'"
    $AppResourceId = (Get-AzureADServicePrincipal -Filter "displayName eq '$AppName'").ObjectId

    # Check existing assignment
    If (Get-AzureADServiceAppRoleAssignment -ObjectId $AppResourceId) {
        $AppRoleAssignedPrincipal = (Get-AzureADServiceAppRoleAssignment -ObjectId $AppResourceId).PrincipalDisplayName
        if ($AppRoleAssignedPrincipal -ne $AllowGroup) {
            Write-Verbose -Message "Removing existing App Role Assignment for '$AppRoleAssignedPrincipal'." 
            Remove-AzureADServiceAppRoleAssignment -ObjectId $AppResourceId
        }
    } 

    If (!(Get-AzureADServiceAppRoleAssignment -ObjectId $AppResourceId)) {
        Write-Verbose -Message "Authorize '$($AllowGroup)' for accessing '$AppName'."
        New-AzureADServiceAppRoleAssignment -ObjectId $AppResourceId -PrincipalId $AadGroupObjectId -ResourceId $AppResourceId -Id ([Guid]::Empty)
    }

}

#Set owner on the Azure AD App Proxy Application
$AppOwnerUPN = $App.OwnerUPN
$AddAppOwner = $true
If ($AppOwnerUPN) {    
    Write-Verbose -Message "Obtaining objectID for user '$AppOwnerUPN'" 
    $AppOwnerObjectID = (Get-AzureADUser -Filter "userprincipalname eq '$AppOwnerUPN'").ObjectId
    if ($AppOwnerObjectID) {
        $CurrentAppOwners = Get-AzureADServicePrincipal -ObjectId $AppResourceId | Get-AzureADServicePrincipalOwner
        Foreach ($CurrentAppOwner in $CurrentAppOwners) {
            if ($CurrentAppOwner.userPrincipalName -eq $AppOwnerUPN) {
                $AddAppOwner = $false
                Write-Verbose -Message "'$AppownerUPN' already is an owner of application '$AppName'"
            }
        }
    } else {
        Write-Verbose -Message "User '$AppOwnerUPN' not found to add as owner for '$AppName'."
    } 
    if ($AddAppOwner -and $AppOwnerObjectID) {
        Write-Verbose -Message "Adding user '$AppOwnerUPN' with ID '$AppOwnerObjectID' to the Azure AD App Proxy Application"
        Add-AzureADServicePrincipalOwner -ObjectId $AppResourceId -RefObjectId $AppOwnerObjectID
    }
}
    
    
Write-Verbose -Message "Finished configuring '$AppName'."
}