#Query for one device inline:
https://ssprps01.contoso.com/AdminService/wmi/SMS_R_System(16777219)


#Query by netbios name
https://ssprps01.contoso.com/AdminService/wmi/SMS_R_System?$filter=NetbiosName+eq+'ssprps01'

#Only show ResourceID
https://ssprps01.contoso.com/AdminService/wmi/SMS_R_System?$filter=Name%20eq%20%27ssprps01%27&$select=ResourceId


#ResourceID Challenges
https://ssprps01.contoso.com/AdminService/wmi/SMS_R_System?$filter=ResourceId+eq+16777219

#Query OS
https://ssprps01.contoso.com/AdminService/wmi/SMS_G_System_OPERATING_SYSTEM?$filter=ResourceID+eq+16777219

#Query Deployment
https://ssprps01.contoso.com/AdminService/wmi/SMS_ClientAdvertisementStatus?$filter=ResourceID+eq+16777219

#Query by OS Name
https://ssprps01.contoso.com/AdminService/wmi/SMS_R_System?$select=Name,OperatingSystemNameandVersion&$filter=contains(OperatingSystemNameandVersion,%27Microsoft%20Windows%20NT%20Workstation%2010.0%27)


Query by username
https://ssprps01.contoso.com/AdminService/wmi/SMS_R_User?$filter=contains(Name,%27ramseygr%27)




