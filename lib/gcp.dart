// ignore_for_file: avoid_print

import 'package:oauth2_client/google_oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

class Oauth2ClientExample {
  Oauth2ClientExample();

  Future<void> fetchFiles() async {
    var hlp = OAuth2Helper(
      GoogleOAuth2Client(
          // TODO(jeremy): How do we use different redirect URIs for different
          // environments.
          redirectUri: 'http://localhost:8080/assets/oauth2redirect.html',
          // customUriScheme appears to be a required field even though we
          // aren't overriding it for our web app.
          customUriScheme: 'http'),
      grantType: OAuth2Helper.authorizationCode,
      clientId:
          '197678265256-7em2vm2pd0lmtikhkpnhhhqpdfu3prid.apps.googleusercontent.com',
      // We need to provide a client secret but impersonation doesn't actually
      // rely on that being kept confidential.
      clientSecret: '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',
      scopes: ['https://www.googleapis.com/auth/drive.readonly'],
    );

    // TODO(jeremy): I should rewrite this to illustrate how to inject the
    // credential into GCP client libraries.
    var resp = await hlp.get('https://www.googleapis.com/drive/v3/files');

    print(resp.body);
  }
}
