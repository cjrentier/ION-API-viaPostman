# 
# Read an ION API file and process it into a Postman environment File
# Christiaan Rentier (Infor) 2021-10-13
#

<#
.SYNOPSIS
	Processing Infor ION API file into a Postman environment file.
	More information on https://learning.postman.com/docs/sending-requests/managing-environments/
.DESCRIPTION
	Preparation by user
	1.	Create Authorized App in ION API of type Backend Service
	2.	Create DocumentFlow (IMS via ION API) using the ION API Client Id sending the document
	3.	Download ION API file *.ionapi file
	4.	Run this Script to create the Postman Environment file
	5.	Import the environment into Postman
.EXAMPLE
	Start the PowerShell script selecting the required methode to test e.g. 
	.\Create-PostmanEnvironment.ps1 -ionapiFile .\myTenant.ionapi -postmanFile .\postman_environment.json
	
#>

#
# Define parameters
#
param (
	[string]
	[Parameter(Mandatory,HelpMessage='The *.ionapi file downloaded from ION API of type Backend Service.')]
		$ionapiFile,
	[string]
	[Parameter(Mandatory,HelpMessage='The Postman file to be created based on *.ionapi file.')]
		$postmanFile		
)


function Read-ionapiFile {
	<#
	.SYNOPSIS
		Read the *.ionapi file of type Backend Service to extract the details.
	.DESCRIPTION
		Prerequisite: First create Authorized App in ION API of type Backend Service and download ION API file *.ionapi file 
		The *.ionapi file is checked if it exists and contains a correctly formed json
		Return with the json object that is read.

		# Layout of the *.ionapi file
		Multi Tenant
			ti   : YOUR_TENANT
			cn   : test_YOUR_TENANT
			dt   : 12
			ci   : YOUR_TENANT~NotXeQFvmWXIWHdGS4VIqObgm265xb
			cs   : WRM6SJgyJbprE2_28buPcDJxjBLe4epHJ7bjktYmERIG4mXRqtJl3Jo2F4MmSi5mOuoJyr3ymrag
			iu   : https://mingle-ionapi.inforcloudsuite.com
			pu   : https://mingle-sso.inforcloudsuite.com:443/YOUR_TENANT/as/
			oa   : authorization.oauth2
			ot   : token.oauth2
			or   : revoke_token.oauth2
			sc   : {}
			ev   : U14783582221
			v    : 1.1
			saak : YOUR_TENANT#LchSMTO7mDzr3sU2JXRkZTDTzXX71i7_0LFrN1Qti3BNCd3h5WMIMULuyEN5BrRe0ZOc_ilL6mHtO
			sask : IZuiNwxHz3X-wXTSmHI1KVYm4ByKoanDnMI80qVLsotL0CeoSu2dLGP1Kui_WXtU827ICKCg39QLsA
			
		On-Premises 
			ti   : infor
			cn   : Test_name
			dt   : 12
			ci   : infor~qlZngY61WCRsT2TCu3YQpWqxeD4u9yu-
			cs   : mVw9TtoTts5gpD-pvjtHguonS7AHyTAq4SMpt8wdYzO95L01xgDqxoe2Ixaf8ke7pt4ux_deQ
			iu   : https://inforostst.infor.com:7443
			pu   : https://inforostst.infor.com/InforIntSTS/
			oa   : connect/authorize
			ot   : connect/token
			or   : connect/revocation
			ev   : J16202142212
			v    : 1.0
			saak : infor#I_ZMiRvgwgfVVhdYbFqPtMeV0xacVT9Av0M2nwIz91Gw6Kt8e-WAy-DrAeC98_Zg
			sask : KRcFj293F_v9PAaeZo43qkcnsO_viG7bCrFDxkuLtx5c5Tj8--UlJluXncJQ
	.PARAMETER
		The input is the *.ionapi file, based on this a body is constructed 
	.OUTPUTS
		The output is the object response containing the relevant Postman environment information
	#>

    [CmdletBinding()]
    [OutputType("System.Object")]

	#
	# Define parameters
	#
	param (
		[string]
		[Parameter(Mandatory,HelpMessage='The *.ionapi file downloaded from ION API of type Backend Service.')]
			$ionapiFile
	)

	#
	# Process the *.ionapi file
	#
	process {
		if (Test-Path $ionapiFile -PathType Leaf) {
			try {
				$result = (Get-Content $ionapiFile | ConvertFrom-Json)
			}
			catch{
				Write-Verbose -Message 'Error: No correct *.ionapi file found, please provide correct *.ionapi file'
				Return ''
			}
		} 
		else {
			Write-Verbose -Message 'Error: No *.ionapi file found, please provide *.ionapi file'
			Return ''
		}
		Return $result
	}
	
}

function Create-postmanObject {
	<#
	.SYNOPSIS
		Create a postman_environment.json object based on the *.ionapi object.
	.DESCRIPTION
		The ionapi object is process into a postman_environment object
	.PARAMETER
		The input is the object from the *.ionapi, based on this a body is constructed 
	.OUTPUTS
		The output is the object response containing the relevant Postman environment information

		Return with the json object that is created.
		# Layout of the Postman Environment file

		{
			"id": "0dd73aeb-74e1-47ad-8578-a8b79a9a89a",
			"name": "YOUR_TENANT",
			"values": [
				{
					"key": "ci",
					"value": "YOUR_TENANT~NotXeQFvmWXIWHdGS4VIqObgm265yLFNva4dZxb",
					"enabled": true
				},
				{
					"key": "cs",
					"value": "WRM6SJgyJbprE2_28buPcDJxjBLe4epHJ7bjktYmERIG4mXRqpT0RggBitJl3Jo2F4MmSi5mOuoJyr3ymrag",
					"enabled": true
				},
				{
					"key": "pu",
					"value": "https://mingle-sso.inforcloudsuite.com:443/YOUR_TENANT/as/",
					"enabled": true
				},
				{
					"key": "ot",
					"value": "token.oauth2",
					"enabled": true
				},
				{
					"key": "saak",
					"value": "YOUR_TENANT#LchSMTO7mDzr3sU2JXRkZTDTzXX71i7_0LFrNvCbz1Qti3BNCd3h5WMIMULuyEN5BrRe0ZOc_ilL6mHtO",
					"enabled": true
				},
				{
					"key": "sask",
					"value": "IZuiNwxHz3X-wXTSmHI1KVYm4ByKoanDnMI80qVLsohaZktL0CeoSu2dLGP1Kui_WXtU827ICKCg39QLsA",
					"enabled": true
				}
			],
			"_postman_variable_scope": "environment",
			"_postman_exported_at": "2021-01-01T12:00:00.000Z",
			"_postman_exported_using": "Postman/7.30.1"
		}

	#>

    [CmdletBinding()]
    [OutputType("System.Object")]

	#
	# Define parameters
	#
	param (
		[object]
		[Parameter(Mandatory,HelpMessage='The ionapi json content downloaded from ION API')]
			$ionapiObject
	)

	#
	# Process the *.ionapi object
	# Original id is like: '0dd73aeb-74e1-47ad-8578-a8b7636bb704'
	#
	process {
		$postmanObject = @{
			id		= 'This_is_Must_Be_Present';
			name	= $ionapiObject.ti;
			values	= @{
				key		= 'ci';
				value	= $ionapiObject.ci;
				enabled	= 'true'
			}, @{
				key		= 'cs';
				value	= $ionapiObject.cs;
				enabled	= 'true'
			}, @{
				key		= 'pu';
				value	= $ionapiObject.pu;
				enabled	= 'true'
			}, @{
				key		= 'ot';
				value	= $ionapiObject.ot;
				enabled	= 'true'
			}, @{
				key		= 'saak';
				value	= $ionapiObject.saak;
				enabled	= 'true'
			}, @{
				key		= 'sask';
				value	= $ionapiObject.sask;
				enabled	= 'true'
			}		
		}
	return $postmanObject
	}
}

#
# Process information from *.ionapi into Postman Environment file
#
Write-Output ('-----------------------------------------------------------------------------------------------------------------')

$ionapiObject = ( Read-ionapiFile -ionapiFile $ionapiFile )
if ( $ionapiObject ) {
	Write-Output ('Processing ionapi file OK	: ' + $ionapiFile )
	
	$postmanObject = ( Create-postmanObject -ionapiObject $ionapiObject )
	if ( $postmanObject ) {
		Write-Output ('Creating Postman Object OK	: ' + $postmanFile )

		Write-Output ('Creating Postman Environment file :	'  + $postmanFile)
		$postmanObject | ConvertTo-Json -depth 20 | Out-File $postmanFile
		
	} else {
		Write-Output ('Creating Postman Object Failed: ' + $postmanFile )
	}

} else {
	Write-Output ('Processing ionapi file Failed: ' + $ionapiFile )
}

Write-Output ('Ready')
