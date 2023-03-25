# flutter_oauth
Experiment with doing oauth in flutter web apps

## To run it

```
flutter run -d chrome --web-port=8080
```

* We need to pin the web port because the redirect uri is hard coded to localhost:8080
  in gcp.dart

## Resources

[oauth2_client example](https://pub.dev/packages/oauth2_client/example)