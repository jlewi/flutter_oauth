# flutter_oauth
Experiment with doing oauth in flutter web apps

## To run it

```
flutter run -d chrome --web-port=8080
```

* We need to pin the web port because the redirect uri is hard coded to localhost:8080
  in gcp.dart

## Notes: 

The redirect URL is hardcoded in two places
* gcp.dart
* web/oauth2redirect.html


## Resources
[StackOverflow Question](https://stackoverflow.com/questions/75835761/how-to-persist-google-api-credentials-in-a-flutter-spa)
[oauth2_client example](https://pub.dev/packages/oauth2_client/example)