# ION-API-viaPostman
## Disclaimer
Below procedures and attached PowerShell scripts must be tested and adjusted at the Customer in a test environment before using in Production environment.
All URLs, host names, credentials are either fictional or temporary used for demonstration purpose only, adjust them accordingly to your environment.

As credentials are used, take the highest security measures in storing and using the *.ionapi file!!

The software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.

## Access ION API via Postman
Below example shows:
* [Prepare the Authorized App of type Backend Service in ION API](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#preparation-in-ion-api)
* [Process *.ionapi content Function Read-ionapiFile](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#process-ionapi-content-using-function-read-ionapifile)
* [Create postman_environment object Function Create-postmanObject](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#create-postman_environmentjson-using-function-create-postmanobject)
* [Use Create-PostmanEnvironment.ps1](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#use-create-postmanenvironmentps1)
* [Load environment file in Postman](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#environment)
* [Use environment in Collections](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#collections)

Check https://docs.infor.com for documentation, check [Postman](https://www.getpostman.com/apps) to download and install Postman.

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
    "ti": "<your Tenant>",
    "cn": "CR_IMS_<your Tenant>",
    "dt": "12",
    "ci": "<your Tenant or Infor OS farm>~8lXksXEcsa3RhA1MU",
    "cs": "-0Hu2PDtCJPhDg7MqKTGEjsasHxM_4M05paHaWgfq0mq7OnT87pMT",
    "iu": "https://mingle-ionapi.inforcloudsuite.com",
    "pu": "https://mingle-sso.inforcloudsuite.com:443/<your Tenant>/as/",
    "oa": "authorization.oauth2",
    "ot": "token.oauth2",
    "or": "revoke_token.oauth2",
    "ev": "U147858101",
    "v": "1.0",
    "saak": "<your Tenant>#1L41ABBJVczlphHoNAmDJhqMIamo9WCwNHFcR79A",
    "sask": "B8BRpF2IOat88NkxySo2oDB3RtGQKTycB6R_Apoo4NAVcGZNVozCPm9A"
}
```
## Process *.ionapi content using Function **Read-ionapiFile**
This function reads the contents of the *.ionapi file. The output of the function is an object containing the content of the *.ionapi file. 
* Use iu and ti to construct the URI for ION API calls. 
* Use pu and ot for token request and refresh.

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

![image](https://user-images.githubusercontent.com/82956918/136540513-dbb640c6-6a84-4cf0-aa60-8ae41010a51e.png)

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

At the Collection on the Authorization tab of the Collection, scroll to the bottom and click **Get New Access Token**

![image](https://user-images.githubusercontent.com/82956918/136537356-48c84742-aa22-46da-a7c7-3049c4e766e6.png)

Click **Use Token**

**Configure new Requests**

When creating a new Request always set on Authorization Tab the Type = **Inherit auth from parent**

![image](https://user-images.githubusercontent.com/82956918/136538029-f34e6690-6685-488c-82fd-9c42b98b5789.png)

Now each request in that Collection can use the OAuth information for that environment easily.

# Automatic request of new Token after expiry
Postman can use a Pre-Request script (written in JavaScript) to run before each request is sent. This script can be used to request a new token or to refresh the token when it is expired.

The Collection is using an Environment and has been configured using the variables like described above.

Configure manually in the Authorization Tab of the **Collection** the following parameters: Access Token = Available Tokens, use {{access_token}} in the next field, Header Prefix = Bearer.

![image](https://user-images.githubusercontent.com/82956918/154132561-2c374b54-9af1-4dab-9724-a684b47effdb.png)

* This script will request a new token when no token present yet or refresh when the token is expired.
* The script is designed to be placed on Collection level in the Pre-request Script.
* If placed or used on other level adjust the script accordingly as all parameters are used in the Environment Scope.
* It will check variables present in Environment Scope, read if present and create if not present
** access_token, this will be used by the Collection / Authorization and all requests will be configured to "Inherit auth from parent"
** refresh_token, token which can be used for refreshing, when there is a valid access_token
** expires_in, expiry time in seconds
** refresh_time, the time the token was refreshed

For any questions or details please mail to [Christiaan Rentier](mailto:Christiaan.Rentier@infor.com?subject=ION-API%20via%20Postman)
