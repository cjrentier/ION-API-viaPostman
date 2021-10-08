# ION-API-viaPostman
Access ION API via Postman
Below example shows:
* [Prepare the Authorized App of type Backend Service in ION API](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#preparation-in-ion-api)
* [Process *.ionapi content Function Read-ionapiFile](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#process-ionapi-content-using-function-read-ionapifile)
* [Create postman_environment object Function Create-postmanObject](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#create-postman_environmentjson-using-function-create-postmanobject)
* [Use Create-PostmanEnvironment.ps1](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#use-create-postmanenvironmentps1)
* [Load environment file in Postman](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#environment)
* [Use environment in Collections](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#collections)

Check https://docs.infor.com for documentation

## Preparation in ION API
Create in ION API a new Authorized App of type Backend Service

![image](https://user-images.githubusercontent.com/82956918/135427988-8c3b2bef-c450-479e-bd4e-a32243a8b0cf.png)

Download Credentials, 

![image](https://user-images.githubusercontent.com/82956918/135428039-ce7c4da8-6c30-40eb-9e70-d2915228d5ad.png)

Create Service Account and Download the *.ionapi file

![image](https://user-images.githubusercontent.com/82956918/135428050-fad2ffd8-8158-4fb6-82d0-1e9d0dede103.png)

The downloaded *.ionapi file contains below information in JSON format, store this file in a secure place as it contains sensitive user and password information!
```
{
    "ti": "EDUGDENA031_AX3",
    "cn": "CR_IMS_EDUGDENA031_AX3",
    "dt": "12",
    "ci": "EDUGDENA031_AX3~8lXksXEcsa3RhAZlUc2bkc0XRWkWk2dY1MU",
    "cs": "-0Hu2PDtCJPhDg7MqKTGEjsasHxM_4M05paHaWgfq06H34WQgxHbmq7OnT87pMT",
    "iu": "https://mingle-ionapi.inforcloudsuite.com",
    "pu": "https://mingle-sso.inforcloudsuite.com:443/EDUGDENA031_AX3/as/",
    "oa": "authorization.oauth2",
    "ot": "token.oauth2",
    "or": "revoke_token.oauth2",
    "ev": "U147858101",
    "v": "1.0",
    "saak": "EDUGDENA031_AX3#1L41ABBJVczlphHoNAmDxIx8YjIeZJhqMIamo9WCwNHFcR79A",
    "sask": "B8BRpF2IOat88NkxySo2oDB3RtlTKg96UaZ7ou2cGQKTycB6R_Apoo4NAVcGZNVozCPm9A"
}
```
## Process *.ionapi content using Function **Read-ionapiFile**
This function reads the contents of the *.ionapi file. The output of the function is an object containing the content of the *.ionapi file. 
* Use iu and ti to construct the URI for ION API calls. 
* Use pu and ot for token request and refresh.
![image](https://user-images.githubusercontent.com/82956918/135430608-9d6feace-71bc-442b-a807-e26e7fa74261.png)
![image](https://user-images.githubusercontent.com/82956918/135430033-a312dec8-86d7-48ea-855b-e25b663d5aa3.png)

## Create postman_environment.json using Function **Create-postmanObject**
This function creates Postman environment object based on the *.ionapi object.

## Use Create-PostmanEnvironment.ps1
Start the PowerShell script selecting the required methode to test e.g. 
```
	.\Create-PostmanEnvironment.ps1 -ionapiFile .\myTenant.ionapi -postmanFile .\postman_environment.json
```

## Postman
### Environment 
Go to the Environment of that Workspace 
  * Import the postman_environment.json and note the name (this is the Tenant from the environment file but can be renamed)
  * Now the environment can be used for other Collections

![image](https://user-images.githubusercontent.com/82956918/136540245-913a5226-a8ae-4c44-b609-420476ebd260.png)

![image](https://user-images.githubusercontent.com/82956918/136537537-cd970283-64c7-41ee-99bb-8e9a60814c27.png)

### Collections
**New Collection** 

In the New Collection set the Authorization at the Authorization Tab
  * Type = OAuth 2.0
  * Add auth data to = Request Headers
  * Access token = Available Tokens
  * Header Prefix = Bearer

![image](https://user-images.githubusercontent.com/82956918/136536390-9dc27d08-6727-4cf6-8759-69b1248f8ca3.png)

**Configure New Token**
  * Token Name = Define your own name
  * Grant Type = Password Credentials
  * Access Token URL = {{pu}}{{ot}}
  * Client ID = {{ci}}
  * Client Secret = {{cs}}
  * Username = {{saak}}
  * Password = {{sask}}
  * Scope = email
  * Client Authentication = Send as Basic Auth header

![image](https://user-images.githubusercontent.com/82956918/136536275-009663be-4fe8-4831-9d21-39bcb1ec19e9.png)

**Load Environment for that Collection**

Select the Collection in the Collections (the Collection line above the Requests)

At the top right select the Environment loaded before.

![image](https://user-images.githubusercontent.com/82956918/136536903-7e6ef32c-0326-41d6-ab78-f8cb24b4fea2.png)

At the Collection on the Authorization tab of the Collection, scroll to the bottom and **Get New Access Token**

![image](https://user-images.githubusercontent.com/82956918/136537356-48c84742-aa22-46da-a7c7-3049c4e766e6.png)

Click **Use Token**

**Configure new Requests**

When creating a new Request always set on Authorization Tab the Type = **Inherit auth from parent**

![image](https://user-images.githubusercontent.com/82956918/136538029-f34e6690-6685-488c-82fd-9c42b98b5789.png)

Now each request in that Collection can use the OAuth information for that environment easily.

For any questions or details please mail to [Christiaan Rentier](mailto:Christiaan.Rentier@infor.com?subject=ION-API%20via%20Postman)
