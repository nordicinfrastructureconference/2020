cmtrace "C:\Program Files\Microsoft Configuration Manager\Logs\AdminService.log"
cmtrace "C:\Program Files\Microsoft Configuration Manager\Logs\SMSProv.log"

#Verify hierarchy settings, CMG
#security node

"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

#oData link:
https://ssprps01.contoso.com/AdminService/v1.0


#list devices
https://ssprps01.contoso.com/AdminService/v1.0/Device/

#Add a filter:
https://ssprps01.contoso.com/AdminService/v1.0/Device/?$filter=Name+eq+'ssprps01'


#WMI Link:
https://ssprps01.contoso.com/AdminService/wmi/

#WMI Metadata ** Caution!
https://ssprps01.contoso.com/AdminService/wmi/$metadata
file:///C:/Users/ramseygr/OneDrive/Conferences/NICConf2020/ConfigMgr%20Admin%20Service/Scripts/WMImetadata.pdf
