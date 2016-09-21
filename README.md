# os_dpe_shell
os_dpe_shell is a powershell extension for DELLEMC´s (Avamar) Data protection Extension for Openstack 


this summary is currently a brainstorm to get the basics working in a plain vanilla openstack


```Powershell
$Admintoken = Get-OSToken -OS_USERNAME Prod_user -OS_PROJECT_NAME clubse_Production -Verbose
$backuptoken = Get-OSToken -OS_USERNAME backup_admin -OS_PROJECT_NAME clubse_Production -Verbose
Get-DPEprojects -token $backuptoken.Token | Add-DPEinstances -token $Admintoken.Token -OS_Instance_ID f4849904-2734-4b34-adfc-8f825ffd8b9a -OS_Instance_Name Test2
```

## Troubleshooting:

*Make sure project admin has a primary project said other to NONE


* test that user sees intsamces from nova via rest:
```Powershell
(Get-OSserver -token $backuptoken.Token -requestURL http://ubuntu3:8774/v2/776e922dceca4773b5986e15d579365b/servers/348285c6-1a89-4fad-acc1-8e9b34619b95).server
```
