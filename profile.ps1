﻿$Global:OS_USERNAME = "admin"
$Global:OS_PASSWORD = "Password123!"
$Global:OS_KEYSTONE_IP = "192.168.2.203"
$Global:OS_KEYSTONE_PORT = 5000
$GLobal:MC_USERNAME = "MCUser"
$Global:MC_Password = "Password123_"
$Global:AVAMAR_IP = "192.168.2.31"
$Global:DPE_API_IP = "172.16.3.13"
$Global:OS_DOMAIN = "default"
$Global:OS_Zone_ID = "nova"
$Global:OS_API_VER = "v3"
$Global:OS_ADMIN_PROJECT_NAME = 'admin'
$Global:OS_PROVIDER_PROJECT_NAME = 'avamar'
$Global:OS_PROJECT_PROJECT_NAME = 'projectdodo_Production'
$Global:OS_PROVIDER_USERNAME = "backup_admin"
$Global:OS_PROVIDER_PASWORD = "Password123!"
$Global:OS_ADMIN_USERNAME = "admin"
$Global:OS_ADMIN_PASWORD = "Password123!"
$Global:OS_PROJECT_USERNAME = "Prod_admin"
$Global:OS_PROJECT_PASWORD = "Password123!"
Get-DPEADMINToken
Get-DPEProjectToken
Get-DPEProviderToken