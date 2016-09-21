function Get-OSToken
{
    [CmdletBinding()]
    Param
    (
	[ValidateNotNullOrEmpty()] 
    $OS_USERNAME = $Global:OS_USERNAME,
	[ValidateNotNullOrEmpty()] 
    $OS_Password = $Global:OS_PASSWORD,
	[ValidateNotNullOrEmpty()] 
    $OS_DOMAIN = $Global:OS_DOMAIN,
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()] 
    $OS_PROJECT_NAME,
	[ValidateNotNullOrEmpty()] 
    $OS_KEYSTONE_IP = $Global:OS_KEYSTONE_IP,
	[ValidateNotNullOrEmpty()] 
    [int]$OS_KEYSTONE_PORT = $Global:OS_KEYSTONE_PORT,
    $OS_API_VER = "v3"
    )

<#
{"auth": {
"identity": {
"methods": ["password"],
"password":
{"user": {"password": "<provider_password>", "domain":{"id": "default"},"name": "<provider_user>"}}},
"scope": {"project": {"domain": {"id": "default"},"name": �<admin_project_name>"}}}}#>
$jsonbody = [ordered]@{auth = [ordered]@{
                identity = [ordered]@{
                    methods = @("password")
                    password = [ordered]@{
                        user = [ordered]@{
                            name = $OS_USERNAME
							password = $OS_Password
							domain = @{id = "default" 
							}
                        }
                    }
					scope = [ordered]@{
							project = @{
							id = $OS_PROJECT_NAME
						}
					}#>
                  }
                } 
            } | ConvertTo-Json -Depth 7
$uri = "http://$($OS_KEYSTONE_IP):$($OS_KEYSTONE_PORT)/$OS_API_VER/auth/tokens"
Write-Verbose "connecting to $uri"
if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
    {
    #write-Host $PSCmdlet.MyInvocation.BoundParameters
	Write-Host -ForegroundColor Yellow $jsonbody
    }
$token = Invoke-WebRequest -ContentType "application/json" -Body $jsonbody -Method POST -Uri $uri
Write-Verbose $token.Headers.'X-Subject-Token'
if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
    {
    write-Host $PSCmdlet.MyInvocation.BoundParameters
	Write-Host -ForegroundColor Yellow $token 
    }
$object.pstypenames.insert(0,'OS_TOKEN')
$object | Add-Member -MemberType NoteProperty -Name Token -Value $token.Headers.'X-Subject-Token'
$object | Add-Member -MemberType NoteProperty -Name Content -Value $content.token
Write-Output $object
}
<#
function Get-OSserver
{
    [CmdletBinding()]
    Param
    (
    $OS_CONTROLLER_IP = "192.168.2.203",
    [int]$OS_CONTROLLER_PORT = 8774,
    $token
    )
$Myself = $MyInvocation.MyCommand.Name.Substring(6)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
#
}
#>
Function Get-DPEprotectionProviders
{
### get protection provider
    [CmdletBinding()]
    Param
    (
    [Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()] 
    $token,
	[ValidateNotNullOrEmpty()] 
    $DPE_API_IP = $GLOBAL:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    $DPE_API_VER = "v1"
    )
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
$Myself = $MyInvocation.MyCommand.Name.Substring(7)
$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/protectionProviders"
}




Function Register-DPEprotectionProviders
{
### register protection provider
    [CmdletBinding()]
    Param
    (
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()] 
    $token,
	[ValidateNotNullOrEmpty()] 
    $MC_USERNAME = $GLobal:MC_USERNAME,
	[ValidateNotNullOrEmpty()] 
    $MC_Password = $global:MC_Password,
	[ValidateNotNullOrEmpty()] 
    $AVAMAR_IP = $GLobal:AVAMAR_IP,
	[ValidateNotNullOrEmpty()] 
    $DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    [int]$AVAMAR_PORT = 9443,
    $DPE_API_VER = "v1"
    )
$Myself = $MyInvocation.MyCommand.Name.Substring(12)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
$Jsonbody = [ordered]@{
 protectionProviders = @( @{name = "AVENode1"
 description = "The 1st backup appliance"
 url = "https://$($AVAMAR_IP):$($AVAMAR_PORT)"
 user = "$MC_USERNAME"
 password= "$MC_Password"}
 )
 } | ConvertTo-Json
$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/$Myself"
    {
    write-Host $PSCmdlet.MyInvocation.BoundParameters
	Write-Verbose $Jsonbody
    }

}

<#{
"tenants": [{
"id": "2ec759536aab436f8d5a826e0160c051",
"name": "coke",
"capacityInMB": 150000,
"protectionProviders": [{
"id": "2a7384ab-b630-432b-863f-ad9449af8781","name": "vm-qa-0184.asl.lab.emc.com"}]}]}
#>
Function Add-DPEprojects
{

     [CmdletBinding()]
    Param
    (
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()] 
    $token,
	[ValidateNotNullOrEmpty()] 
	$DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    $DPE_API_VER = "v1",
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()] 
    [string]$OS_Project_ID, 
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()] 
    [string]$OS_Project_Name,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
    [alias('id')]$DPE_Provider_ID,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
    [alias('name')]$DPE_Provider_Name,
    [int]$capacityMB =  500000
    )
begin
    {
    $OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
    $Myself = $MyInvocation.MyCommand.Name.Substring(7)
    $Providers = @()
    }

process
{
    $Providers += @{name = $DPE_Provider_Name
                    id = $DPE_Provider_ID}
}
end
{

    $Jsonbody = [ordered]@{
    $Myself = @( @{name = $OS_Project_Name
                   id = $OS_Project_ID
                   capacityInMB = $capacityMB
                   protectionProviders = $Providers
                   })
    } | ConvertTo-Json -Depth 7                   
	
	$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/$Myself"
		{
		write-Host $PSCmdlet.MyInvocation.BoundParameters
		Write-Verbose $Jsonbody
		}
	}
}
Function Add-DPEinstances
{
    [CmdletBinding(DefaultParameterSetName = '0')]
    Param
    (
	[Parameter(ParameterSetName = "0",Mandatory = $true)]
	[ValidateNotNullOrEmpty()] 
    $token,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName = '0')]
	[ValidateNotNullOrEmpty()] 
    [alias('id')][string]$OS_Project_ID, 
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$false,ParameterSetName = '0')]
	[ValidateNotNullOrEmpty()] 
    [string[]]$OS_Instance_ID,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$false,ParameterSetName = '0')]
	[ValidateNotNullOrEmpty()] 
    [string[]]$OS_Instance_Name,
	[ValidateNotNullOrEmpty()] 
    [alias('zone')]$OS_ZONE_ID = $Global:OS_Zone_ID,
	$DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    $DPE_API_VER = "v1"
    )
begin
    {
    $OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
    $Myself = $MyInvocation.MyCommand.Name.Substring(7)
    $Providers = @()
    $Method = "Post"
    }

process

{
Write-Verbose $OS_Project_ID
$instances = @()
foreach ($instance in $OS_Instance_ID)
        {
        $Instances+= [ordered]@{
        name = $OS_Instance_Name       
        #href= "string"
        #name= "string"
        id= $OS_Instance_ID
        zoneId= $OS_Zone_ID
        #description= "string"
        #contact= "string"
        #phone= "string"
        #email= "string"
        #location= "string"
            }
        }
$Jsonbody = [ordered]@{
            $Myself = @($instances)
            }| ConvertTo-Json
Write-host $Jsonbody
$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/projects/$OS_Project_ID/$Myself"        
Write-Verbose $requestURL
	if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
		{
		write-Host $PSCmdlet.MyInvocation.BoundParameters
		Write-Verbose $Jsonbody
		}
Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method $Method -Body $Jsonbody -Uri $requestURL 
}
end
{

               
    #


}
}

Function Get-DPEprojects
{

     [CmdletBinding()]
    Param
    (
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()] 
    $token,
	[ValidateNotNullOrEmpty()] 
	$DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    $DPE_API_VER = "v1"
    )
begin
    {
    $OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
    $Myself = $MyInvocation.MyCommand.Name.Substring(7)
    $Method = "GET"
    }

process
{

}
end
{
    $requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/$Myself"


}
}


function Get-OSserver
{
    [CmdletBinding()]
    Param
    (
    $OS_CONTROLLER_IP = "192.168.2.203",
    [int]$OS_CONTROLLER_PORT = 8774,
    $token,
	$requestURL
    )
$Myself = $MyInvocation.MyCommand.Name.Substring(6)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
#

}