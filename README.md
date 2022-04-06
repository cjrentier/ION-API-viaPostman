# ION-API-viaPostman
Environment variables in Postman can be used to simplify the connection with ION API in different Infor Tenants, this reduces a lot of manual work.

A small PowerShell script is attached to convert the *.ionapi file into a Postman environment file.

A Pre-request script in Postman can be used to automatically retrieve or refresh an OAuth2.0 token.

Below procedure describes in simple steps how to configure Postman and to use the attached scripts.

## Disclaimer
Below procedures and attached PowerShell scripts must be tested and adjusted at the Customer in a test environment before using in Production environment.
All URLs, host names, credentials are either fictional or temporary used for demonstration purpose only, adjust them accordingly to your environment.

As credentials are used in case of Backend Service type, take the highest security measures in storing and using the *.ionapi file!!

The software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.

## Access ION API via Postman
Accessing ION API via Postman can be done easily by following this procedure:
* In the Infor ION API Authorized Apps when using type Backend Service:
  * Create an Authorized App of type Backend Service.
  * Create a Service Account to be used when needed.
  * Download Credentials creating a *.ionapi file, store it in a safe place as it contains user and password!!
* In the Infor ION API Authorized Apps when using type Web:
  * Create an Authorized App of type Web
  * Fill Redirect URL: https://www.postman.com/oauth2/callback
  * Fill Authorized JavaScript Origins: https://www.postman.com/oauth2/callback
  * Download Credentials creating a *.ionapi file, it does not contain a user and password!
* Convert the *.ionapi file into a postman_environment.json file. [Using the Create-PostmanEnvironment.ps1](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#use-create-postmanenvironmentps1)
* In Postman:
  * Go to the Environment of that Workspace.
  * Click **Import** and then click **Upload** to import the postman_environment.json.
  * The Environment will have the variables filled from the file. 
  * Create a new Collection and configure the Authorization tab to use the variables of the Environment selected. [Use environment in Collections](https://github.com/cjrentier/ION-API-viaPostman/blob/main/README.md#collections)
  * Click **Get New Access Token** button and after receiving click "Use Token".
  * Each Request in the Collection must set Authorization Type = **Inherit auth from parent**.
  * Use the {{iu}} and {{tenant}} variables to construct the requests.
  * There are differences depending on the type of Authorized App used: Backend Service or Web client. Both are documented.
* Additionally a Pre-request Script is available to request and use token automatically when using the Backend Service type.
  * Configure the Authorization Tab > Access Token to use the access_token variable.
  * Download the provided example JavaScript and copy it to the Pre-request Script tab.
  * For more details: [Automatic request of new Token after expiry](https://github.com/cjrentier/ION-API-viaPostman#automatic-request-of-new-token-after-expiry)
  * Every new request will call this script and request a new token if needed.

Check https://docs.infor.com for documentation, check [Postman](https://www.getpostman.com/apps) to download and install Postman.

## Use Create-PostmanEnvironment.ps1
Run the PowerShell script to convert the  
```
	.\Create-PostmanEnvironment.ps1 -ionapiFile .\myTenant.ionapi -postmanFile .\postman_environment.json
```

## Postman
### Environment 
Go to the Environment of that Workspace 
  * Import the postman_environment.json and note the name (this is the name of the Authorized App from the environment file but can be renamed)
  * Now the environment can be used for other Collections

### Collections
In the New Collection configure the Authorization Tab to use the variables:
  * Type = OAuth 2.0
  * Add auth data to = Request Headers
  * Access token = Available Tokens
  * Header Prefix = Bearer

![image](https://user-images.githubusercontent.com/82956918/136536390-9dc27d08-6727-4cf6-8759-69b1248f8ca3.png)

**Configure New Token when using Authorized App of type Backend Service**
  * Token Name = Define your own name or use {{cn}} from the environment
  * Grant Type = Password Credentials
  * Access Token URL = {{pu}}{{ot}} (Base URL for calling the authorization server for this tenant and request the Access Token)
  * Client ID = {{ci}} (ClientID that must be passed to the Authorization Server)
  * Client Secret = {{cs}} (Client Secret to pass to the Authorization Server)
  * Username = {{saak}} (Service Account Access Key)
  * Password = {{sask}} (Service Account Secret Key)
  * Scope = email
  * Client Authentication = Send as Basic Auth header

![image](https://user-images.githubusercontent.com/82956918/156803271-63249f1a-ebc9-41a6-919e-124d9bf7a895.png)

Click **Get New Access Token** and click **Use Token** to load the token, now it can be used for new requests.

**Configure New Token when using Authorized App of type Web client**
  * Token Name = Define your own name or use {{cn}} from the environment
  * Grant Type = Authorization Code
  * Callback URL = {{ru}} (Don't check the button Authorize using browser)
  * Auth Token URL = {{pu}}{{oa}} (Base URL for calling the authorization server for this tenant and Authorization)
  * Access Token URL = {{pu}}{{ot}} (Base URL for calling the authorization server for this tenant and request the Access Token)
  * Client ID = {{ci}} (ClientID that must be passed to the Authorization Server)
  * Client Secret = {{cs}} (Client Secret to pass to the Authorization Server)
  * Scope = leave empty
  * Client Authentication = Send as Basic Auth header

![image](https://user-images.githubusercontent.com/82956918/156803163-21df36b1-2163-4e35-9ec7-777318e22ec6.png)

Click **Get New Access Token** which presents a webclient to enter user and password. After **Sign On** a new window is shown to Request for Approval for: Token Name is requesting access to Infor Cloudsuite for the tenant and the user used.

![2022-03-04 17_16_00-Postman1](https://user-images.githubusercontent.com/82956918/156804929-ea157d4b-d508-48cd-87f0-87449b5c38d0.png) ![2022-03-04 17_17_12-Postman2](https://user-images.githubusercontent.com/82956918/156804957-83088717-6628-4849-9c95-65cbfcc97c26.png) 

**Load Environment for that Collection**

Select the Collection in the Collections (the Collection line above the Requests)

At the top right select the Environment loaded before.

![image](https://user-images.githubusercontent.com/82956918/154308641-9203e368-4048-4adb-8ee2-39f8976f5977.png)

**Configure new Requests**

When creating a new Request in that Collection, always set on Authorization Tab the Type = **Inherit auth from parent**

![image](https://user-images.githubusercontent.com/82956918/154309176-2cbd2cf7-f4d9-452d-8eba-4508bf70a297.png)

Now each request in that Collection can use the OAuth information for that environment easily.

Additionally the {{iu}} and {{tenant}} variables can be used to build the URL for the request. {{iu}} (Base URL for calling the ION API Gateway for this tenant/environment)
```
	GET {{iu}}/{{tenant}}/Mingle/SocialService.Svc/User/Detail
```
![image](https://user-images.githubusercontent.com/82956918/155566500-b28b3ea0-a3c5-4c99-b9a0-9c3715774816.png)


# Automatic request of new Token after expiry when using Backend Service Type
Postman can use a Pre-request Script (written in JavaScript) to run before each request is sent. This script can be used to request a new token or to refresh the token when it is expired.

A simple demo Pre-request Script [Pre-request-Script.js](https://github.com/cjrentier/ION-API-viaPostman/blob/main/Pre-request-Script.js) is provided, test and adjust it to fit your project:
* This script will request a new token when no token present yet or refresh when the token is expired.
* The script is designed to be placed on Collection level in the Pre-request Script.
* If placed or used on other level adjust the script accordingly as all parameters are used in the Environment Scope.
* It will check variables present in Environment Scope, read if present and create if not present
  * access_token, this will be used by the Collection / Authorization and all requests will be configured to "Inherit auth from parent"
  * refresh_token, token which can be used for refreshing, when there is a valid access_token
  * expires_in, expiry time in milliseconds
  * refresh_time, the time the token was refreshed
* When refresh the token fails due to whatever reason it will clear the token variables in the environment and at next call request a new token.

The Collection is using an Environment and has been configured using the variables like described above.

Configure manually in the Authorization Tab of the **Collection** the following parameters: 
* Type = OAuth 2.0
* Add auth data to = Request Headers
* Access Token = Available Tokens, 
* use {{access_token}} in the next field, 
* Header Prefix = Bearer. 

There is no need to press the **Get New Access Token** button at the bottom anymore as the script will be executed automatically upon each request.

![image](https://user-images.githubusercontent.com/82956918/156801774-6874c877-1326-4087-884d-cba4a78d133a.png)

For any questions or details please mail to [Christiaan Rentier](mailto:Christiaan.Rentier@infor.com?subject=ION-API%20via%20Postman)
