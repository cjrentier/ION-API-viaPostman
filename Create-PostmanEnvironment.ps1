# 
# Read an ION API file and process it into a Postman environment File
# Christiaan Rentier 2021-10-13
# 2022-02-17 Tenant (ti) added to environment to use it in the Token Name and the URLs of each request
# 2022-02-24 iu added to environment to use it in the URLs of each request 
# 2022-03-04 type of Webclient added having field ru additional
# 2022-04-11 Simplified the script, declaration of output file is not needed but hard-coded based on input file
# 2022-12-16 Added support for enforcing Scopes
# 2023-01-10 Added empty string to prevent null values in Scopes when not set
# 2023-03-20 Updated any string that possibly contain sensitive information to explicitly state this

<#
.SYNOPSIS
	Processing Infor ION API file into a Postman environment file.
	More information on https://learning.postman.com/docs/sending-requests/managing-environments/
.DESCRIPTION
	Preparation by user
	1.	Create Authorized App in ION API of type Backend Service
	2.	Create DocumentFlow (IMS via ION API) using the ION API Client Id sending the document
	3.	Download ION API file *.ionapi file and store it in a safe place!
	4.	Run this Script to create the Postman Environment file
	5.	Import the environment into Postman
.EXAMPLE
	Start the PowerShell script selecting the *.ionapi file to be processed
	.\Create-PostmanEnvironment.ps1 -ionapiFile .\myTenant.ionapi
	This creates a Postman Environment file called .\myTenant_postman_environment.json in the same directory the *.ionapi file is placed
	
#>

#
# Define parameters
#
param (
	[string]
	[Parameter(Mandatory,HelpMessage='The *.ionapi file downloaded from ION API of type Backend Service.')]
		$ionapiFile		
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
			ci   : YOUR_TENANT~Security-Sensitive-Information
			cs   : Secret-Security-Sensitive-Information
			iu   : https://<Base URL for calling the ION API Gateway for this tenant/environment>
			pu   : https://<Base URL for calling the authorization server for this tenant/environment>
			oa   : authorization.oauth2
			ot   : token.oauth2
			or   : revoke_token.oauth2
			sc   : ["INFOR-IFS","Infor-AuditMonitor","Infor-IDM","Infor-ION","Infor-LN","Infor-Mingle","Infor-MinglePN"],
			ev   : A1234567890
			v    : 1.1
			saak : YOUR_TENANT#Access-Key-Security-Sensitive-Information
			sask : Secret-Key-Security-Sensitive-Information
			
		On-Premises 
			ti   : infor
			cn   : Test_name
			dt   : 12
			ci   : infor~Security-Sensitive-Information
			cs   : Secret-Security-Sensitive-Information
			iu   : https://inforostst.customer.com:7443
			pu   : https://inforostst.customer.com/InforIntSTS/
			oa   : connect/authorize
			ot   : connect/token
			or   : connect/revocation
			ev   : A1234567890
			v    : 1.0
			saak : infor#Access-Key-Security-Sensitive-Information
			sask : Secret-Key-Security-Sensitive-Information
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
		$fileExtension = [System.IO.Path]::GetExtension($ionapiFile)
		if ($fileExtension -eq '.ionapi') {
			Return $result
		} else {
			Write-Verbose -Message 'Error: Extension of file must be *.ionapi, please provide *.ionapi file'
			Return ''
		}
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
		The output is the object response containing the relevant Postman environment information based on the fields from the *.ionapi input

		Return with the json object that is created.
		# Layout of the Postman Environment file

		{
			"id": "0ab2cd-34cd-12ab-1234-Example",
			"name": "your description in ION API",
			"values": [
				{
					"key": "tenant",
					"value": "YOUR_TENANT",
					"enabled": true
				},
				{
					"key": "iu",
					"value": "<Base URL for calling the ION API Gateway for this tenant/environment>",
					"enabled": true
				},
				{
					"key": "ci",
					"value": "YOUR_TENANT~Security-Sensitive-Information",
					"enabled": true
				},
				{
					"key": "cs",
					"value": "Secret-Security-Sensitive-Information",
					"enabled": true
				},
				{
					"key": "pu",
					"value": "<Base URL for calling the authorization server for this tenant/environment>",
					"enabled": true
				},
				{
					"key": "ot",
					"value": "token.oauth2",
					"enabled": true
				},
				{
					"key": "saak",
					"value": "YOUR_TENANT#Access-Key-Security-Sensitive-Information",
					"enabled": true
				},
				{
					"key": "sask",
					"value": "Secret-Key-Security-Sensitive-Information",
					"enabled": true
				},
				{
					"key": "sc",
					"value": "INFOR-IFS,Infor-AuditMonitor"
					"enabled": true
				}				
			],
			"_postman_variable_scope": "environment",
			"_postman_exported_at": "2023-03-20T12:00:00.000Z",
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
			name	= $ionapiObject.cn;		# cn	Application name
			values	= @{
				key		= 'tenant';
				value	= $ionapiObject.ti; # ti	Tenant identifier
				enabled	= 'true'
			}, @{
				key		= 'cn';
				value	= $ionapiObject.cn; # cn	Application name
				enabled	= 'true'
			}, @{
				key		= 'ci';
				value	= $ionapiObject.ci;	# ci	ClientID that must be passed to the Authorization Server
				enabled	= 'true'
			}, @{
				key		= 'cs';
				value	= $ionapiObject.cs;	# cs	Client Secret to pass to the Authorization Server
				enabled	= 'true'
			}, @{
				key		= 'iu';
				value	= $ionapiObject.iu;	# iu	Base URL for calling the ION API Gateway for this tenant/environment
				enabled	= 'true'
			}, @{
				key		= 'pu';
				value	= $ionapiObject.pu;	# pu	Base URL for calling the authorization server for this tenant/environment
				enabled	= 'true'
			}, @{
				key		= 'oa';
				value	= $ionapiObject.oa;	# oa	Path to append to "pu" to create the Authorization URL
				enabled	= 'true'
			}, @{
				key		= 'ot';
				value	= $ionapiObject.ot;	# ot	Path to append to "pu" to create the Access Token URL
				enabled	= 'true'
			}, @{
				key		= 'or';
				value	= $ionapiObject.or;	# or	Path to append to "pu" to revoke a previously obtained token
				enabled	= 'true'
			}, @{
				key		= 'ru';
				value	= $ionapiObject.ru;	# ru	Redirect URL (used for type Web Client)
				enabled	= 'true'
			}, @{
				key		= 'saak';
				value	= $ionapiObject.saak;	# SAAK	Service Account Access Key (used for type Backend Service)
				enabled	= 'true'
			}, @{
				key		= 'sask';
				value	= $ionapiObject.sask;	# SASK	Service Account Secret Key (used for type Backend Service)
				enabled	= 'true'
			}, @{
				key		= 'scopes';
				value	= '' + $ionapiObject.sc;	# Scopes, can be enforced, add empty string to prevent null values
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
	$fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($ionapiFile)
	$fileDirectory = [System.IO.Path]::GetDirectoryName($ionapiFile)
	Write-Output ('Processing ionapi file OK	: ' + $ionapiFile )
	
	$postmanObject = ( Create-postmanObject -ionapiObject $ionapiObject )
	if ( $postmanObject ) {
		$postmanFile = $fileDirectory + '\' + $fileNameWithoutExtension + '_postman_environment.json'
		Write-Output ('Creating Postman Object OK	: ' + $postmanFile )

		Write-Output ('Creating Postman Environment OK : '  + $postmanFile)
		$postmanObject | ConvertTo-Json -depth 20 | Out-File $postmanFile
		
	} else {
		Write-Output ('Creating Postman Object Failed: ' + $postmanFile )
	}

} else {
	Write-Output ('Processing ionapi file Failed: ' + $ionapiFile + ' Use -verbose option or check location or protection of directory.')
}

Write-Output ('Ready')
