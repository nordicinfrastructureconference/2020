cmtrace "C:\Program Files\Microsoft Configuration Manager\Logs\AdminService.log"
cmtrace "C:\Program Files\Microsoft Configuration Manager\Logs\SMSProv.log"


#Dig into collections

#List all collections
https://ssprps01.contoso.com/AdminService/wmi/SMS_Collection

#Collection Count
https://ssprps01.contoso.com/AdminService/wmi/SMS_Collection/$count

#Choose your columns
https://ssprps01.contoso.com/AdminService/wmi/SMS_Collection?$select=Name


#Sort by name
https://ssprps01.contoso.com/AdminService/wmi/SMS_Collection?$select=Name&$orderby=Name


#Add a couple columns back
https://ssprps01.contoso.com/AdminService/wmi/SMS_Collection?$select=Name,CollectionID,LastMemberChangeTime

#Filter for 'all systems' collection
https://ssprps01.contoso.com/AdminService/wmi/SMS_Collection?$select=Name,CollectionID,LastMemberChangeTime&$filter=Name+eq+'All Systems'

#Filter by collectionID
https://ssprps01.contoso.com/AdminService/wmi/SMS_Collection?$select=Name,CollectionID,LastMemberChangeTime&$filter=CollectionID+eq+'SMS00001'

#List collections containing the word "All"
https://ssprps01.contoso.com/AdminService/wmi/SMS_Collection?$filter=contains(Name,'All')&$orderby=Name&$select=Name,CollectionID

#Same as above, but exclude 'All Systems'
https://ssprps01.contoso.com/AdminService/wmi/SMS_Collection?$filter=contains(Name,'All')+and+Name+ne+'All Systems'+&$orderby=Name&$select=Name,CollectionID
