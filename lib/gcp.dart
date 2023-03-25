// ignore_for_file: avoid_print

import 'package:oauth2_client/google_oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

class Oauth2ClientExample {
  Oauth2ClientExample();

  Future<void> fetchFiles() async {
    var hlp = OAuth2Helper(
      GoogleOAuth2Client(
          redirectUri: 'http://localhost:8080/oauth2redirect',
          // customUriScheme appears to be a required field even though we
          // aren't overriding it for our web app.
          customUriScheme: 'http'),
      grantType: OAuth2Helper.authorizationCode,
      clientId:
          '197678265256-7em2vm2pd0lmtikhkpnhhhqpdfu3prid.apps.googleusercontent.com',
      // N.B. clientSecret shouldn't be needed
      //clientSecret: 'XXX-XXX-XXX',
      scopes: ['https://www.googleapis.com/auth/drive.readonly'],
    );

    var resp = await hlp.get('https://www.googleapis.com/drive/v3/files');

    print(resp.body);
  }
}
