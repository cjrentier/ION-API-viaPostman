// This script will request a new token when no token present yet or refresh when the token is expired
// 2022-05-09
// The script is designed to be placed on Collection level in the Pre-request Script, 
// if placed or used on other level adjust the script accordingly as all parameters are used in the Environment Scope
// It will check variables present in Environment Scope, read if present and create if not present
// 		access_token, this will be used by the Collection / Authorization and all requests will be configured to "Inherit auth from parent"
// 		refresh_token,
// 		expires_in, in milliseconds
// 		refresh_time, the time the token was refreshed
// Configure manually in the Authorization Tab of the Collection the following parameters: 
// 		Access Token = Available Tokens, 
//		use {{access_token}} in the next field, 
//		Header Prefix = Bearer
//
// Flow of the script:
// 		In case the token is expired and we have a refresh token it will refresh the access token
//			If the refresh fails it will request both a new refresh and access token
// 		In case the token is expired and we have no refresh token it will request both a new refresh and access token
//		In all other cases we will use the availible access_token, 
//          If that fails with unauthorized manually empty the environment variable access_token and refresh_token! 
//
// https://learning.postman.com/docs/sending-requests/variables/
// Remark: sendRequest is an asynchronous call in JavaScript
//

let currentAccess_token = "";
let currentRefresh_token = "";
let currentExpires_in = 0;
let tokenDate = new Date(2000,0,1);		// Set to Januari 2000
let currentRefresh_time = tokenDate;	// Set to Januari 2000
let currentToken_age = 0;

// Access Token is received after first request, however due to tenant refresh it could be invalid.
if ( pm.environment.has("access_token") ) {
	currentAccess_token = pm.environment.get("access_token");
	if ( currentAccess_token && currentAccess_token.length > 0 ) {
		console.log(`Access Token found in Environment: ${currentAccess_token}`);
	} else {
		currentAccess_token = "";
		console.log(`Access Token found empty in Environment.`);
	}
} else {
	currentAccess_token = "";
	console.log(`Access Token not found in Environment and newly added.`);
	pm.environment.set("access_token", "");
}

// Refresh Token is received after first request, however due to tenant refresh it could be invalid.
if ( pm.environment.has("refresh_token") ) {
	currentRefresh_token = pm.environment.get("refresh_token");
	if ( currentRefresh_token && currentRefresh_token.length > 0 ) {
		console.log(`Refresh Token found in Environment: ${currentRefresh_token}`);
	} else {
		currentRefresh_token = "";
		console.log(`Refresh Token found empty in Environment.`);
	}
} else {
	currentRefresh_token = "";
	pm.environment.set("refresh_token", "");
	console.log(`Refresh Token not found in Environment and newly added.`);
}

// Expires time in milliseconds is received after first request, however due to tenant refresh it could be invalid.
if ( pm.environment.has("expires_in") ) {
	currentExpires_in = pm.environment.get("expires_in");
	if ( currentExpires_in && currentExpires_in > 0 ) {
		console.log(`Expires in found in Environment: ${currentExpires_in}`);
	} else {
		currentExpires_in = 0;
		console.log(`Expires in found empty in Environment.`);
	}
} else {
	currentExpires_in = 0;
	pm.environment.set("expires_in", 0);
	console.log(`Expires in not found in Environment and newly added.`);
}

// Refresh time (date type) is received after first request, however due to tenant refresh it could be invalid.
if ( pm.environment.has("refresh_time") ) {
	currentRefresh_time = Date.parse(pm.environment.get("refresh_time"));
	if ( currentRefresh_time && currentRefresh_time > 0 ) {
		console.log(`Refresh time found in Environment: ${currentRefresh_time}`);
	} else {
		currentRefresh_time = tokenDate;
		console.log(`Refresh time found empty in Environment.`);
	}
} else {
	currentRefresh_time = tokenDate;
	pm.environment.set("refresh_time", tokenDate );
	console.log(`Refresh time not found in Environment and newly added.`);
}

pm.expect(pm.environment.has('ci')).to.be.true;
pm.expect(pm.environment.has('cs')).to.be.true;
pm.expect(pm.environment.has('pu')).to.be.true;
pm.expect(pm.environment.has('ot')).to.be.true;
pm.expect(pm.environment.has('saak')).to.be.true;
pm.expect(pm.environment.has('sask')).to.be.true;

let auth_url = pm.environment.get('pu') + pm.environment.get('ot');
console.log(`Authentication URL: ${auth_url}`);
let clientId = pm.environment.get('ci');
console.log(`clientId: ${clientId}`);
let clientSecret = pm.environment.get('cs');
console.log(`clientSecret: ${clientSecret}`);
let userName = pm.environment.get('saak');
console.log(`Username: ${userName}`);
let userPassword = pm.environment.get('sask');
console.log(`Password: ${userPassword}`);

// Constructing the request for refreshing a token
let authorizationToken = 'Bearer ' + currentAccess_token;
console.log(`authorizationToken: ${authorizationToken}`);

let refreshTokenRequest = {
      url:  auth_url, 
      method: 'POST',
      header: {
		'Accept': 'application/json',
		'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {
        mode: 'urlencoded',
        urlencoded: [
			{ key: 'refresh_token', value: currentRefresh_token },
			{ key: 'client_id', value: clientId },
			{ key: 'client_secret', value: clientSecret },
			{ key: 'grant_type', value: 'refresh_token' }
			]
      }
};

// Constructing the request for a new token
let getTokenRequest = {
      url:  auth_url, 
      method: 'POST',
      header: {
		'Accept': 'application/json',
		'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {
        mode: 'urlencoded',
        urlencoded: [
			{ key: 'grant_type', value: 'password' },
			{ key: 'client_id', value: clientId },
			{ key: 'client_secret', value: clientSecret },
        	{ key: 'username', value: userName },
        	{ key: 'password', value: userPassword },
			{ key: 'scope', value: 'email' }
			]
      }
};

// If age of current token >= the expiry time including 60 seconds for safety then refresh the token in case a refresh_token is present
// If no token is present then the currentRefresh_time was set to 2000-01-01, currentExpires_in was set to 0 and currentRefresh_token was set empty
currentToken_age = ( ( new Date() - currentRefresh_time )  + 60000 );
console.log(`Current Token is ${currentToken_age} milliseconds old`);

if ( currentToken_age >= currentExpires_in ) {
	console.log('Current Token is expired or not valid.');
	if (currentRefresh_token.length > 0 ) {
		console.log('Token is expired and a refresh token is present, trying to refresh token first.');
		pm.sendRequest(refreshTokenRequest, function (err, res) {
			// Use the access_token received to set the environment and in the local variables
			currentAccess_token = res.json().access_token
			if (currentAccess_token) {
				pm.environment.set("access_token", currentAccess_token );
				console.log(`New access_token after refresh: ${currentAccess_token}`);
                // Set the refresh_time to now
                pm.environment.set("refresh_time", new Date());
                currentRefresh_time = new Date();
                // Set the currentExpires_in variable to the time given in the response if it exists
                if(res.json().expires_in){
                    currentExpires_in = res.json().expires_in * 1000;
                } else {
                    currentExpires_in = 0;
                }
                pm.environment.set("expires_in", currentExpires_in);
                console.log(`New access_token after refresh expires in : ${currentExpires_in}`);
                console.log('Refreshing token finished');  
			} else {
				console.log('Refreshing token failed, request a new access_token and refresh_token.');
                pm.sendRequest(getTokenRequest, function (err, res) {
                    // Use the access_token received to set the environment and in the local variables
                    currentAccess_token = res.json().access_token
                    pm.environment.set("access_token", currentAccess_token );
                    console.log(`New access_token: ${currentAccess_token}`);

                    // Use the refresh_token received to set the environment
                    currentRefresh_token = res.json().refresh_token
                    pm.environment.set("refresh_token", currentRefresh_token );
                    console.log(`New refresh_token: ${currentRefresh_token}`);

                    // Set the refresh_time to now
                    pm.environment.set("refresh_time", new Date());
                    currentRefresh_time = new Date();
                    
                    // Set the currentExpires_in variable to the time given in the response if it exists
                    if(res.json().expires_in){
                        currentExpires_in = res.json().expires_in * 1000;
                    } else {
                        currentExpires_in = 0;
                    }
                    pm.environment.set("expires_in", currentExpires_in);
                    console.log(`Expires in : ${currentExpires_in}`);
                    console.log('Getting new token finished.');  
                });

			}
		});
	} else {
		console.log('No refresh_token found, new access_token needed, sendRequest for new token.');
		pm.sendRequest(getTokenRequest, function (err, res) {
			// Use the access_token received to set the environment and in the local variables
			currentAccess_token = res.json().access_token
			pm.environment.set("access_token", currentAccess_token );
			console.log(`New access_token: ${currentAccess_token}`);

			// Use the refresh_token received to set the environment
			currentRefresh_token = res.json().refresh_token
			pm.environment.set("refresh_token", currentRefresh_token );
			console.log(`New refresh_token: ${currentRefresh_token}`);

			// Set the refresh_time to now
			pm.environment.set("refresh_time", new Date());
			currentRefresh_time = new Date();
			
			// Set the currentExpires_in variable to the time given in the response if it exists
			if(res.json().expires_in){
				currentExpires_in = res.json().expires_in * 1000;
			} else {
				currentExpires_in = 0;
			}
			pm.environment.set("expires_in", currentExpires_in);
			console.log(`Expires in : ${currentExpires_in}`);
			console.log('Getting new token finished.');  
		});
	}
} else {
	console.log(`Existing access_token is used, else manually empty the environment variable access_token and refresh_token!`);
}
