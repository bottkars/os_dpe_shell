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
	[Parameter(ParameterSetName = "1",Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
    $OS_PROJECT_NAME,
	[Parameter(ParameterSetName = "1",Mandatory = $false)]
	[ValidateSet('project','domain')]$scope,
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
"scope": {"project": {"domain": {"id": "default"},"name": “<admin_project_name>"}}}}#>
switch ($scope)
	{
	"project"
		{
		$OS_SCOPE_NAME = $OS_PROJECT_NAME
		}
	"domain"
		{
		$OS_SCOPE_NAME = $OS_DOMAIN
		}
	}
$jsonbody = [ordered]@{auth = [ordered]@{
                identity = [ordered]@{
                    methods = @("password")
                    password = [ordered]@{
                        user = [ordered]@{
                            name = $OS_USERNAME
							password = $OS_Password
							domain = @{id = $OS_DOMAIN
							}
                        }
                    }
					scope = [ordered]@{
							$scope = @{
							name = $OS_SCOPE_NAME
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
$content = $token.Content | ConvertFrom-Json
$object = New-Object -TypeName psobject
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
#$requestURL = "http://$($OS_CONTROLLER_IP):$($OS_CONTROLLER_PORT)/v2.1/compute/v2.1/$Myself"
$requestURL =  "http://ubuntu3:8774/compute/v2.1"#/7d206ea3-e379-4a21-ac25-3d1fb612e9ef"
Write-Verbose $requestURL
Invoke-RestMethod -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Get -Uri $requestURL #| Select-Object -ExpandProperty $Myself
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
Write-Verbose $requestURL
Invoke-RestMethod -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Get -Uri $requestURL | Select-Object -ExpandProperty $Myself
}
Function Unregister-DPEprotectionProviders
{
### register protection provider
    [CmdletBinding()]
    Param
    (
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
    $token,
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
    $DPE_Providerid,
	[ValidateNotNullOrEmpty()]
    $DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    $DPE_API_VER = "v1"
    )
$Method = "delete"
$Myself = $MyInvocation.MyCommand.Name.Substring(14)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/$Myself/$DPE_Providerid"
Write-Verbose $requestURL
Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method $Method -Uri $requestURL
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
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	$DPE_Providername,
	$Comment,
	[ValidateNotNullOrEmpty()]
    $DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    [int]$AVAMAR_PORT = 9443,
    $DPE_API_VER = "v1"
    )
$Myself = $MyInvocation.MyCommand.Name.Substring(12)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
$Jsonbody = [ordered]@{
 protectionProviders = @( @{name = $DPE_Providername
 description = $Comment
 url = "https://$($AVAMAR_IP):$($AVAMAR_PORT)"
 user = "$MC_USERNAME"
 password= "$MC_Password"}
 )
 } | ConvertTo-Json
$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/$Myself"
Write-Verbose $requestURL
if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
    {
    write-Host $PSCmdlet.MyInvocation.BoundParameters
	Write-Verbose $Jsonbody
    }
Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Post -Body $Jsonbody -Uri $requestURL
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
	if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
		{
		write-Host $PSCmdlet.MyInvocation.BoundParameters
		Write-Verbose $Jsonbody
		}
    Write-Verbose $requestURL
    Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Post -Body $Jsonbody -Uri $requestURL
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
$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/projects/$OS_Project_ID/$Myself"
Write-Verbose $requestURL
	if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
		{
		write-Host $PSCmdlet.MyInvocation.BoundParameters
		Write-Host $Jsonbody
		}

Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method $Method -Body $Jsonbody -Uri $requestURL
}
end
{
    #
    #Write-Verbose $requestURL
    #
}
}
Function Get-DPEinstances
{
    [CmdletBinding(DefaultParameterSetName = '0')]
    Param
    (
	[Parameter(ParameterSetName = "0",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
    $token,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$false,ParameterSetName = '0')]
	[ValidateNotNullOrEmpty()]
    [string]$OS_Instance_ID,
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
    $Method = "Get"

	Write-Verbose $OS_Instance_ID
	$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/$Myself/$OS_Instance_ID"
	Write-Verbose $requestURL
	if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
		{
		write-Host $PSCmdlet.MyInvocation.BoundParameters
		}

	Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method $Method -Uri $requestURL
	}

process

{
}
end
{
    #
    #Write-Verbose $requestURL
    #
}
}
Function Remove-DPEinstances
{
    [CmdletBinding(DefaultParameterSetName = '0')]
    Param
    (
	[Parameter(ParameterSetName = "0",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
    $token,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$false,ParameterSetName = '0')]
	[ValidateNotNullOrEmpty()]
    [string]$OS_Instance_ID,
	[ValidateNotNullOrEmpty()]
    [alias('zone')]$OS_ZONE_ID = $Global:OS_Zone_ID,
	$DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    $DPE_API_VER = "v1"
    )
begin
    {
    $OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
    $Myself = $MyInvocation.MyCommand.Name.Substring(10)
    $Providers = @()
    $Method = "Delete"

	Write-Verbose $OS_Instance_ID
	$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/$Myself/$OS_Instance_ID"
	Write-Verbose $requestURL
	if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
		{
		write-Host $PSCmdlet.MyInvocation.BoundParameters
		}

	Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method $Method -Uri $requestURL
	}

process

{
}
end
{
    #
    #Write-Verbose $requestURL
    #
}
}

Function Start-DPEbackups
{
    [CmdletBinding(DefaultParameterSetName = '0')]
    Param
    (
	[Parameter(ParameterSetName = "0",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
    $token,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$false,ParameterSetName = '0')]
	[ValidateNotNullOrEmpty()]
    [string]$OS_Instance_ID,
	[ValidateNotNullOrEmpty()]
    [alias('zone')]$OS_ZONE_ID = $Global:OS_Zone_ID,
	$DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    $DPE_API_VER = "v1"
    )
begin
    {
    $OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
    $Myself = $MyInvocation.MyCommand.Name.Substring(9

	)
    $Providers = @()
    $Method = "Post"

	Write-Verbose $OS_Instance_ID
	$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/instances/$OS_Instance_ID/$Myself"
	Write-Verbose $requestURL
	if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
		{
		write-Host $PSCmdlet.MyInvocation.BoundParameters
		}

	Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method $Method -Uri $requestURL
	}

process

{
}
end
{
    #
    #Write-Verbose $requestURL
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
    Write-Verbose $requestURL
    Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method $Method -Uri $requestURL | Select-Object -ExpandProperty $Myself
}
}

Function Remove-DPEprojects
{
     [CmdletBinding()]
    Param
    (
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
    $token,
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
    [Alias('ID')]$DPE_Project_ID,
	[ValidateNotNullOrEmpty()]
	$DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    $DPE_API_VER = "v1"
    )
begin
    {
    $OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
    $Myself = $MyInvocation.MyCommand.Name.Substring(10)
    $Method = "DELETE"
    }

process
{
}
end
{
    $requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/$Myself/$DPE_Project_ID"
    Write-Verbose $requestURL
    Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method $Method -Uri $requestURL | Select-Object -ExpandProperty $Myself
}
}
function Get-OSservers
{
    [CmdletBinding()]
    Param
    (
    $OS_NOVA_IP = "$Global:OS_KEYSTONE_IP",
    [int]$OS_NOVA_PORT = 8774,
    $token,
	$OS_PROJECT_ID
    )
$Myself = $MyInvocation.MyCommand.Name.Substring(6)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
#
$requestURL = "http://$($OS_NOVA_IP):$($OS_NOVA_PORT)/v2.1/$OS_PROJECT_ID/$Myself"
#$requestURL =  "http://ubuntu3:8774/v2/776e922dceca4773b5986e15d579365b/servers/348285c6-1a89-4fad-acc1-8e9b34619b95"
Write-Verbose $requestURL
Invoke-RestMethod -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Get -Uri $requestURL | Select-Object -ExpandProperty $Myself | Select-Object * -ExcludeProperty links
}

function Get-OSprojects
{
    [CmdletBinding()]
    Param
    (
    $OS_CONTROLLER_IP = "192.168.2.203",
    [int]$OS_CONTROLLER_PORT = 5000,
    $token,
	$OS_API_VER = "v3"
	)
$Myself = $MyInvocation.MyCommand.Name.Substring(6)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
#
$requestURL = "http://$($OS_CONTROLLER_IP):$($OS_CONTROLLER_PORT)/$OS_API_VER/$Myself/"
#$requestURL =  "http://ubuntu3:8774/v2/776e922dceca4773b5986e15d579365b/servers/348285c6-1a89-4fad-acc1-8e9b34619b95"
Write-Verbose $requestURL
$Projects = Invoke-RestMethod -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Get -Uri $requestURL | Select-Object -ExpandProperty $Myself
$Projects.pstypenames.Insert(0,'OS_PROCECTS')
Write-Output $Projects
}

function Get-OSgroups
{
    [CmdletBinding()]
    Param
    (
    $OS_CONTROLLER_IP = $Global:OS_KEYSTONE_IP,
    [int]$OS_CONTROLLER_PORT = $Global:OS_KEYSTONE_PORT,
    $token,
	$OS_API_VER = $Global:OS_API_VER
	)
$Myself = $MyInvocation.MyCommand.Name.Substring(6)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
#
$requestURL = "http://$($OS_CONTROLLER_IP):$($OS_CONTROLLER_PORT)/$OS_API_VER/$Myself"
#$requestURL =  "http://ubuntu3:8774/v2/776e922dceca4773b5986e15d579365b/servers/348285c6-1a89-4fad-acc1-8e9b34619b95"
Write-Verbose $requestURL
$Object = Invoke-RestMethod -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Get -Uri $requestURL | Select-Object -ExpandProperty $Myself
$Object.pstypenames.Insert(0,'OS_groups')
Write-Output $Object
}

function Get-OSroles
{
    [CmdletBinding()]
    Param
    (
    $OS_CONTROLLER_IP = $Global:OS_KEYSTONE_IP,
    [int]$OS_CONTROLLER_PORT = $Global:OS_KEYSTONE_PORT,
    $token,
	$OS_API_VER = $Global:OS_API_VER
	)
$Myself = $MyInvocation.MyCommand.Name.Substring(6)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
#
$requestURL = "http://$($OS_CONTROLLER_IP):$($OS_CONTROLLER_PORT)/$OS_API_VER/$Myself"
#$requestURL =  "http://ubuntu3:8774/v2/776e922dceca4773b5986e15d579365b/servers/348285c6-1a89-4fad-acc1-8e9b34619b95"
Write-Verbose $requestURL
$Object = Invoke-RestMethod -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Get -Uri $requestURL | Select-Object -ExpandProperty $Myself
$Object.pstypenames.Insert(0,'OS_groups')
Write-Output $Object
}

function Get-OSregions
{
    [CmdletBinding()]
    Param
    (
    $OS_CONTROLLER_IP = $Global:OS_KEYSTONE_IP,
    [int]$OS_CONTROLLER_PORT = $Global:OS_KEYSTONE_PORT,
    $token,
	$OS_API_VER = $Global:OS_API_VER
	)
$Myself = $MyInvocation.MyCommand.Name.Substring(6)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
#
$requestURL = "http://$($OS_CONTROLLER_IP):$($OS_CONTROLLER_PORT)/$OS_API_VER/$Myself"
#$requestURL =  "http://ubuntu3:8774/v2/776e922dceca4773b5986e15d579365b/servers/348285c6-1a89-4fad-acc1-8e9b34619b95"
Write-Verbose $requestURL
$Object = Invoke-RestMethod -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Get -Uri $requestURL | Select-Object -ExpandProperty $Myself
$Object.pstypenames.Insert(0,'OS_groups')
Write-Output $Object
}

function Get-OSdomains
{
    [CmdletBinding()]
    Param
    (
    $OS_CONTROLLER_IP = $Global:OS_KEYSTONE_IP,
    [int]$OS_CONTROLLER_PORT = $Global:OS_KEYSTONE_PORT,
    $token,
	$OS_API_VER = $Global:OS_API_VER
	)
$Myself = $MyInvocation.MyCommand.Name.Substring(6)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
#
$requestURL = "http://$($OS_CONTROLLER_IP):$($OS_CONTROLLER_PORT)/$OS_API_VER/$Myself"
#$requestURL =  "http://ubuntu3:8774/v2/776e922dceca4773b5986e15d579365b/servers/348285c6-1a89-4fad-acc1-8e9b34619b95"
Write-Verbose $requestURL
$Object = Invoke-RestMethod -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Get -Uri $requestURL | Select-Object -ExpandProperty $Myself
$Object.pstypenames.Insert(0,'OS_groups')
Write-Output $Object
}

function Get-OSusers
{
    [CmdletBinding()]
    Param
    (
    $OS_CONTROLLER_IP = $Global:OS_KEYSTONE_IP,
    [int]$OS_CONTROLLER_PORT = $Global:OS_KEYSTONE_PORT,
    $token,
	$OS_API_VER = $Global:OS_API_VER
	)
$Myself = $MyInvocation.MyCommand.Name.Substring(6)
$OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
#
$requestURL = "http://$($OS_CONTROLLER_IP):$($OS_CONTROLLER_PORT)/$OS_API_VER/$Myself"
#$requestURL =  "http://ubuntu3:8774/v2/776e922dceca4773b5986e15d579365b/servers/348285c6-1a89-4fad-acc1-8e9b34619b95"
Write-Verbose $requestURL
$Object = Invoke-RestMethod -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Get -Uri $requestURL | Select-Object -ExpandProperty $Myself
$Object.pstypenames.Insert(0,'OS_groups')
Write-Output $Object
}

<#
‘{"options" : [{"name": "ddr", "value" : "false"}], "name" : “dataset-3", "description" : "backup to GSAN"}’
http(s)://dpe-api-server:8080/v1/projects/{id}/datasets
#>

<#{
"tenants": [{
"id": "2ec759536aab436f8d5a826e0160c051",
"name": "coke",
"capacityInMB": 150000,
"protectionProviders": [{
"id": "2a7384ab-b630-432b-863f-ad9449af8781","name": "vm-qa-0184.asl.lab.emc.com"}]}]}
#>
Function Add-DPEdatasets
{
    [CmdletBinding()]
    Param
    (
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
    $token,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
	[ValidateNotNullOrEmpty()]
    [alias('id')][string]$DPE_Project_ID,
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
    [string]$DPE_DATASETNAME,
    [switch]$ddr,
	$DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    $DPE_API_VER = "v1"
	)
begin
    {
    $OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
    $Myself = $MyInvocation.MyCommand.Name.Substring(7)
    }

process
{
    $Jsonbody = [ordered]@{
		options = @(
					@{ name = 'ddr'
					 value = $ddr.IsPresent.ToString().ToLower()
					 })
                name = $DPE_DATASETNAME
    } | ConvertTo-Json -Depth 7

	$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/projects/$DPE_Project_ID/$Myself"

	if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
		{
		Write-Verbose $requestURL
		$Jsonbody
		}
    Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Post -Body $Jsonbody -Uri $requestURL
}
end
{
	}
}

Function Get-DPEdatasets
{
    [CmdletBinding()]
    Param
    (
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
    $token,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
	[ValidateNotNullOrEmpty()]
    [alias('id')][string]$DPE_Project_ID,
	$DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    $DPE_API_VER = "v1"
	)
begin
    {
    $OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
    $Myself = $MyInvocation.MyCommand.Name.Substring(7)
    }

process
{
	$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/projects/$DPE_Project_ID/$Myself"

		Write-Verbose $requestURL

    Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Get -Body $Jsonbody -Uri $requestURL | Select-Object -ExpandProperty $Myself
}
end
{
	}
}

<#
{"description" : "backup retention",
"name" : “<retention_name>",
"retentionDuration" : {
"unit" : "months",
"duration" : “3”},
"retentionType" : "computed",
"mode" : "backup"}

Function Add-DPEretentions
{
    [CmdletBinding()]
    Param
    (
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
    $token,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='1')]
	[ValidateNotNullOrEmpty()]
    [alias('id')][string]$DPE_Project_ID,
	[Parameter(ParameterSetName = "1",Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[ValidateSet(computed, advanced, never)]
    [string]$DPE_retentionType,
	[Parameter(ParameterSetName = "1",Mandatory = $false]
	[ValidateNotNullOrEmpty()]
	[ValidateSet('backup','replication')]
    [string]$DPE_retentionMode = "replication",
	[ValidateSet('days', 'weeks', 'months', 'years')]
	$DPERetentionUnits
	$DPE_API_IP = $Global:DPE_API_IP,
    [int]$DPE_API_PORT = 8080,
    $DPE_API_VER = "v1"
	)
begin
    {
    $OS_AUTH_HEADER = @{ "X-AUTH-TOKEN" = $token }
    $Myself = $MyInvocation.MyCommand.Name.Substring(7)
    }

process
{
    $Jsonbody = [ordered]@{
		options = @(
					@{ name = 'ddr'
					 value = $ddr.IsPresent.ToString().ToLower()
					 })
                name = $DPE_DATASETNAME
    } | ConvertTo-Json -Depth 7

	$requestURL = "http://$($DPE_API_IP):$($DPE_API_PORT)/$DPE_API_VER/projects/$DPE_Project_ID/$Myself"

	if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
		{
		Write-Verbose $requestURL
		$Jsonbody
		}
    Invoke-RestMethod  -ContentType "application/json" -Headers $OS_AUTH_HEADER -Method Post -Body $Jsonbody -Uri $requestURL
}
end
{
	}
}
#>