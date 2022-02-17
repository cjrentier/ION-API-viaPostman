// This script will request a new token when no token present yet or refresh when the token is expired
// 2022-02-17
// The script is designed to be placed on Collection level in the Pre-request Script, 
// if placed or used on other level adjust the script accordingly as all parameters are used in the Environment Scope
// It will check variables present in Environment Scope, read if present and create if not present
// 		access_token, this will be used by the Collection / Authorization and all requests will be configured to "Inherit auth from parent"
// 		refresh_token,
// 		expires_in,
// 		refresh_time, the time the token was refreshed
// Configure manually in the Authorization Tab of the Collection the following parameters: Access Token = Available Tokens, use {{access_token}} in the next field, Header Prefix = Bearer
//
// https://learning.postman.com/docs/sending-requests/variables/
//

if ( pm.environment.has("access_token") ) {
	var currentAccess_token = pm.environment.get("access_token");
	if ( currentAccess_token.length > 0 ) {
		console.log(`Access Token found in Environment: ${currentAccess_token}`);
	} else {
		console.log(`Access Token found empty in Environment.`);
	}
} else {
	console.log(`Access Token not found in Environment and newly added.`);
	pm.environment.set("access_token", "");
	var currentAccess_token = "";
}

// Refresh Token is received after first request, however due to tenant refresh it could be invalid.
if ( pm.environment.has("refresh_token") ) {
	var currentRefresh_token = pm.environment.get("refresh_token");
	if ( currentRefresh_token.length > 0 ) {
		console.log(`Refresh Token found in Environment: ${currentRefresh_token}`);
	} else {
		console.log(`Refresh Token found empty in Environment.`);
	}
} else {
	pm.environment.set("refresh_token", "");
	var currentRefresh_token = "";
	console.log(`Refresh Token not found in Environment and newly added.`);
}


// Expires time is received after first request, however due to tenant refresh it could be invalid.
if ( pm.environment.has("expires_in") ) {
	var currentExpires_in = pm.environment.get("expires_in");
	if ( currentExpires_in > 0 ) {
		console.log(`Expires in found in Environment: ${currentExpires_in}`);
	} else {
		var currentExpires_in = 0;
		console.log(`Expires in found empty in Environment.`);
	}
} else {
	pm.environment.set("expires_in", 0);
	var currentExpires_in = 0;
	console.log(`Expires in not found in Environment and newly added.`);
}

var tokenDate = new Date(2000,0,1);
var datestring = tokenDate.getFullYear() + "-" + (tokenDate.getMonth()+1) + "-" + tokenDate.getDate()  + " " + tokenDate.getHours() + ":" + tokenDate.getMinutes();

// Expires time is received after first request, however due to tenant refresh it could be invalid.
if ( pm.environment.has("refresh_time") ) {
	var currentRefresh_time = Date.parse(pm.environment.get("refresh_time"));
	if ( currentRefresh_time > 0 ) {
		console.log(`Refresh time found in Environment: ${currentRefresh_time}`);
	} else {
		var currentRefresh_time = tokenDate ;
		console.log(`Refresh time found empty in Environment.`);
	}
} else {
	pm.environment.set("refresh_time", tokenDate );
	var currentRefresh_time = tokenDate ;
	console.log(`Refresh time not found in Environment and newly added.`);
}

pm.expect(pm.environment.has('ci')).to.be.true;
pm.expect(pm.environment.has('cs')).to.be.true;
pm.expect(pm.environment.has('pu')).to.be.true;
pm.expect(pm.environment.has('ot')).to.be.true;
pm.expect(pm.environment.has('saak')).to.be.true;
pm.expect(pm.environment.has('sask')).to.be.true;

var auth_url = pm.environment.get('pu') + pm.environment.get('ot');
console.log(`Authentication URL: ${auth_url}`);
var clientId = pm.environment.get('ci');
console.log(`clientId: ${clientId}`);
var clientSecret = pm.environment.get('cs');
console.log(`clientSecret: ${clientSecret}`);
var userName = pm.environment.get('saak');
console.log(`Username: ${userName}`);
var userPassword = pm.environment.get('sask');
console.log(`Password: ${userPassword}`);

// Constructing the request for the token
var getTokenRequest = {
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

// If token refresh time was >= the expiry time then request a new token
// If no token is present then the currentRefresh_time was set to 2000-01-01
if (( new Date() - currentRefresh_time ) >= currentExpires_in ) 
{
	console.log(`New token needed, sendRequest for new token.`);
	pm.sendRequest(getTokenRequest, function (err, res) {
		// Use the access_token received to set the environment and in the local variables
        var currentAccess_token = res.json().access_token
		pm.environment.set("access_token", currentAccess_token );
		console.log(`New access_token: ${currentAccess_token}`);

		// Use the refresh_token received to set the environment
        var currentRefresh_token = res.json().refresh_token
		pm.environment.set("refresh_token", currentRefresh_token );
		console.log(`New refresh_token: ${currentRefresh_token}`);

		// Set the refresh_time to now
        pm.environment.set("refresh_time", new Date());
        
        // Set the currentExpires_in variable to the time given in the response if it exists
        if(res.json().expires_in){
            currentExpires_in = res.json().expires_in * 1000;
        }
        pm.environment.set("expires_in", currentExpires_in);
		console.log(`Expires in : ${currentExpires_in}`);
  });
} else {
	console.log(`Existing token used.`);
}