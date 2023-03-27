// ignore_for_file: avoid_print

import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/google_oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:googleapis/bigquery/v2.dart' as bq;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_auth/src/auth_http_utils.dart' as utils;
// TODO(jeremy): Is this the right package to import? Or is there
// a version that is platform agnostic?
import 'package:http/http.dart' as http;

class Oauth2ClientExample {
  Oauth2ClientExample();

  Future<String> fetchTables() async {
    // Set the redirect URI relative to the location the app is running from.
    Uri redirect = Uri.base.resolve('/assets/oauth2redirect.html');
    print("Redirect URI: ${redirect.toString()}");
    var hlp = OAuth2Helper(
      GoogleOAuth2Client(
          // TODO(jeremy): How do we use different redirect URIs for different
          // environments.
          redirectUri: redirect.toString(),
          // customUriScheme appears to be a required field even though we
          // aren't overriding it for our web app.
          customUriScheme: 'http'),
      grantType: OAuth2Helper.authorizationCode,
      clientId:
          '197678265256-7em2vm2pd0lmtikhkpnhhhqpdfu3prid.apps.googleusercontent.com',
      // We need to provide a client secret but impersonation doesn't actually
      // rely on that being kept confidential.
      clientSecret: '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',
      scopes: [bq.BigqueryApi.bigqueryScope],
      // Per: https://developers.google.com/identity/protocols/oauth2/web-server#offline
      // We need to request offline access in order to get a refresh token.
      authCodeParams: {
        'access_type': 'offline',
      },
    );

    // Refresh token should be populated if one was requested.
    AccessTokenResponse? token = await hlp.getToken();

    DateTime expiry = token!.expirationDate!;
    auth.AccessToken accessToken =
        auth.AccessToken('Bearer', token!.accessToken!, expiry.toUtc());

    String? refreshToken;
    if (token.refreshToken != null && token.refreshToken! != "") {
      refreshToken = token.refreshToken;
    }

    if (refreshToken == null) {
      print("No refresh token found");
    }

    auth.AccessCredentials credentials = new auth.AccessCredentials(
        accessToken, token!.refreshToken, token.scope!);

    http.Client client = new http.Client();
    auth.ClientId clientId = auth.ClientId(hlp.clientId, hlp.clientSecret);
    auth.AuthClient? gcpClient =
        utils.AutoRefreshingClient(client, clientId, credentials);
    bq.BigqueryApi bqApi = bq.BigqueryApi(gcpClient!);

    bq.TableList table = await bqApi.tables.list('githubarchive', 'month');

    return "Got ${table.tables!.length} tables";
  }
}
