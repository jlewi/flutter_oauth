# flutter_oauth
Experiment with doing oauth in flutter web apps

## To run it

```
flutter run -d chrome --web-port=8080
```

* We need to pin the web port because the redirect uri is hard coded to localhost:8080
  in gcp.dart and assets/oauth2redirect.html

## How it works

This uses the [Authorization Code Flow with Proof Key for Code Exchange(PKCE)](https://developers.google.com/identity/protocols/oauth2/web-server#httprest_1) to
obtain a refresh token and access token from Google. It uses [tetranetsrl/oauth2_client](https://pub.dev/packages/oauth2_client) to handle
the oauth flow. The refresh token is stored in local storage and can be used to obtain an access token when needed.

The library works by having the user login inside a popup window and then send the authorization request. [BrowserWebAuth](https://github.com/teranetsrl/oauth2_client/blob/e7205bf1e614e3e5ceed8ab2f467a486b3bd581e/lib/src/browser_web_auth.dart#L9) is the code that handles this. It is invoked from [requestAuthorization](https://github.com/teranetsrl/oauth2_client/blob/e7205bf1e614e3e5ceed8ab2f467a486b3bd581e/lib/oauth2_client.dart#L242). The authorization request returns a redirect. The redirect
URL should return an html page which posts an event back to the main window in which the flutter app is running. In this example
[assets/oauth2redirect.html](assets/oauth2redirect.html) is the html page that is returned. It includes the JS code

```javascript
<script type="text/javascript">
  window.onload = function() {
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get('code');
    if(code) {
      window.opener.postMessage(window.location.href, "http://localhost:8080/assets/oauth2redirect.html");
    }
  }
</script>
```

which posts the message back to the main window. [BrowserWebAuth](https://github.com/teranetsrl/oauth2_client/blob/e7205bf1e614e3e5ceed8ab2f467a486b3bd581e/lib/src/browser_web_auth.dart#L22) handles the code by closing the window and using the authorization code to obtain the flow.

Importantly, this means that the authorization code passes through the server in order to be passed along to the client. 
This is why PKCE is used. Since the server doesn't know the code challenge and verifier, it can't exchange the auth code
for the access token. Only the flutter app which knows the code challenge and verifier can do that.

### Implicit Flow

Based on the links below, it seems like the implicit flow is no longer recommended for SPA apps.
  * [Auth0 docs](https://auth0.com/docs/get-started/authentication-and-authorization-flow/implicit-flow-with-form-post) and
  * [Microsoft migration guide](https://learn.microsoft.com/en-us/azure/active-directory/develop/migrate-spa-implicit-to-auth-code)

By extension I don't think the [extension_google_sign_in_as_googleapis_auth](https://pub.dev/packages/extension_google_sign_in_as_googleapis_auth)
package is the right flutter package to use when accessing a user's Google Data. As explained in [StackOverflow Question](https://stackoverflow.com/questions/75835761/how-to-persist-google-api-credentials-in-a-flutter-spa), I think that package uses the implicit flow. However, that 
package maybe suitable when using Google just to signin to your app (i.e. OIDC). 

## Incorporating Into Your Application 

The redirect URL is hardcoded in

* gcp.dart

This would need to be changed in any application.

## Resources
* [StackOverflow Question](https://stackoverflow.com/questions/75835761/how-to-persist-google-api-credentials-in-a-flutter-spa)
* [oauth2_client example](https://pub.dev/packages/oauth2_client/example)
* [flutter/flutter#123485](https://github.com/flutter/flutter/issues/123485) Update flutter and dart to use Auth Code Flow with PKCE