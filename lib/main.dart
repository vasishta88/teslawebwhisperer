import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:teslawebwhisperer/services/app_routes.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'tesla_service.dart';
import 'data_screen.dart';
import 'package:teslawebwhisperer/screens/home_screen.dart';
import 'locale_app.dart';

//void main() => runApp(MyApp());

void main() {
  runApp(const LocaleApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tesla Login',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: TeslaLoginScreen(),
      routes: AppRoutes.routes,
    );
  }
}


class TeslaLoginScreen extends StatefulWidget {
  @override
  _TeslaLoginScreenState createState() => _TeslaLoginScreenState();
}

class _TeslaLoginScreenState extends State<TeslaLoginScreen> {
  late WebViewController controller;

  final cookieManager = WebviewCookieManager();


  final http.Client client = http.Client();
  String? accessToken;
  String? codeChallenge;
  Map<String, dynamic>? hiddenInputsandCookies;

  var emailInput;
  var passwordInput;


    @override
  void initState() {
    super.initState();

    // Initialize codeChallenge here
    // Generate 86 random bytes for verifier
    final random = Random.secure();
    final List<int> verifierBytes = List<int>.generate(86, (i) => random.nextInt(256));

    // Create challenge by encoding verifier bytes with URL-safe base64
    String codeVerifier = base64UrlEncode(verifierBytes).replaceAll('=', '');

    // Hash the challenge using SHA-256
    List<int> challengeBytes = sha256.convert(utf8.encode(codeVerifier)).bytes;

    // Create challenge sum by encoding challenge bytes with URL-safe base64
    String codeChallenge = base64UrlEncode(challengeBytes).replaceAll('=', '');

    print('verifierBytes: $verifierBytes');
    print('challengeBytes: $challengeBytes');
    print('codeVerifier: $codeVerifier');
    print('codeChallenge: $codeChallenge');

    //Get method: load the initial url
    final loadUri = Uri.https(
      'auth.tesla.com',
      '/oauth2/v3/authorize',
      {
        'client_id': 'ownerapi',
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
        'redirect_uri': 'https://auth.tesla.com/void/callback',
        'response_type': 'code',
        'scope': 'openid email offline_access',
        'state': 'ODVkOTc3Yjk5YTI2',
      },
    );

    //todo: remove later and check if refresh token works
    cookieManager.clearCookies();

    // Initialize the WebViewController and other logic here
    controller = WebViewController()
      ..clearCache() //todo: remove later and check if refresh token works
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url)  async {

            },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {

            emailInput = await controller.runJavaScriptReturningResult('document.querySelector("input[name=\'identity\']").value');
            passwordInput = await controller.runJavaScriptReturningResult('document.getElementById("form-input-credential").value');
            print('email1: $emailInput');
            print('password1: $passwordInput');


            if (request.url.startsWith('https://auth.tesla.com/void/callback')) {
              print('Callback URL: ${request.url}');
              // Handle the callback and extract tokens
              String hiddenInputsJson = await controller.runJavaScriptReturningResult('''
                (function() {
                  var inputs = document.querySelectorAll('input[type=hidden]');
                  var result = {};
                  var keysToKeep = ['_csrf', '_phase', 'cancel', 'transaction_id', 'correlation_id'];
                  for (var i = 0; i < inputs.length; i++) {
                    if (keysToKeep.includes(inputs[i].name)) {
                      result[inputs[i].name] = inputs[i].value;
                    }
                  }
                  return JSON.stringify(result);
                })()
              ''') as String;

                  // Remove the curly braces at the start and end of the string
                  String cleanedJson = hiddenInputsJson.substring(1, hiddenInputsJson.length - 1);

                  // Split the string into key-value pairs
                  List<String> pairs = cleanedJson.split(',');

                  // Initialize an empty map to store the parsed key-value pairs
                  Map<String, dynamic> hiddenInputsMap = {};

                  // Iterate over each pair
                  for (String pair in pairs) {
                    // Split the pair into a key and a value
                    List<String> keyValue = pair.split(':');

                    // Remove the double quotes from the key and value
                    String key = keyValue[0].substring(1, keyValue[0].length - 1);
                    String value = keyValue[1].substring(1, keyValue[1].length - 1);

                    // Add the key-value pair to the map
                    hiddenInputsMap[key] = value;
                  }

                  print('Hidden Inputs Map: $hiddenInputsMap');


              Map<String, dynamic> hiddenInputsDynamic = Map<String, dynamic>.from(hiddenInputsMap);


              /*
              // Capture cookies
              String cookies = await controller.runJavaScriptReturningResult('document.cookie') as String;
              print('Cookies1: $cookies');

               */


              // Get all cookies for a URL
              List<Cookie> cookieslist = await cookieManager.getCookies(loadUri.toString());
            //(url: 'https://auth.tesla.com');

            // Print all cookies
              for (var cookie in cookieslist) {
                print('Cookie Name: ${cookie.name}, Value: ${cookie.value}');
              }

              // Convert the list of cookies into a cookie string
              String cookies = cookieslist.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');


              print('email2: $emailInput');
              print('password2: $passwordInput');

              final authorizationCode = await obtainAuthorizationCode(hiddenInputsDynamic,cookies, emailInput.toString(), passwordInput.toString(), codeChallenge!);
              print('authcode: $authorizationCode');
              List<String>? tokens = await exchangeAuthorizationCodeForBearerToken(authorizationCode!, codeVerifier);
              final accessToken = tokens![0];
              final refreshToken = tokens![1];
              print('accessToken: $accessToken');
              print('refreshToken: $refreshToken');
              Map<String, dynamic> userDetails = await getUserDetails(accessToken); //todo: Get refresh token before this if access token expired
              print('User Details: $userDetails');
              Map<String, dynamic> vehicleDetails = await getVehicles(accessToken); //todo: Get refresh token before this if access token expired
              print('Vehicle Details: $vehicleDetails');
              String vehicleID = vehicleDetails['response'][0]['id'].toString();
              print('Vehicle ID: $vehicleID');
              Map<String, dynamic> vehicleData = await getVehicleData(accessToken, vehicleID);
              print('Vehicle Data: $vehicleData');
              Future<double?> vehicleRange = getVehicleRange(vehicleData);
              print('Vehicle range: $vehicleRange');
              //todo: handle if accesstoken is null and show an intro error screen
              wakeUp(accessToken, vehicleID);

              // Then navigate to a new screen
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(accessToken: accessToken)),
              );

               */

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    accessToken: accessToken,
                    userDetails: userDetails,
                    vehicleData: vehicleData,
                    vehicleID: vehicleID,
                  ),
                ),
              );





              return NavigationDecision.prevent; // Prevent loading the callback URL
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(loadUri );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tesla Login'),
      ),
      body: WebViewWidget(controller: controller),

    );
  }
}

Future<String?> obtainAuthorizationCode(Map<String, dynamic> hiddenInputs, String cookies, String email, String password, String codeChallenge) async {

  // Construct the URI
  final uri = Uri.parse('https://auth.tesla.com/oauth2/v3/authorize').replace(
    queryParameters: {
      'client_id': 'ownerapi',
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'redirect_uri': 'https://auth.tesla.com/void/callback',
      'response_type': 'code',
      'scope': 'openid email offline_access',
      'state': 'ODVkOTc3Yjk5YTI2',
    },
  );

  // Construct the headers
  final headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Cookie': cookies,
  };

  // Construct the body
  final body = {
    ...hiddenInputs,
    'identity': email,
    'credential': password,
  };
  final bodyEncoded = body.keys.map((key) => '${Uri.encodeComponent(key)}=${Uri.encodeComponent(body[key])}').join('&');
  print('bodyencoded:$bodyEncoded');
  // Make the POST request

  // Make the POST request
  final client = http.Client();
  final request = http.Request('POST', uri)
    ..headers.addAll(headers)
    ..body = bodyEncoded
    ..followRedirects = false;

  final response = await client.send(request);

  // Log the full request
  print('URL: $uri');
  print('Headers: $headers');
  print('Body: $bodyEncoded');

  // Log the response
  print('Response status: ${response.statusCode}');
  print('Response headers: ${response.headers}');
  print('Response reason phrase: ${response.reasonPhrase}');


  // Handle the response (you can modify this part as needed)


  if (response.statusCode == 302) {
    final locationHeader = response.headers['location'];
    print('Response location header: $locationHeader');
    final authorizationCode = Uri.parse(locationHeader!).queryParameters['code'];
    return authorizationCode;
  } else {
    print('Failed to obtain authorization code');
    print('Response status code: $response');
    return null;
  }


}

Future<List<String>?>? exchangeAuthorizationCodeForBearerToken(String authorizationCode, String codeVerifier) async {
  final response = await http.post(
    Uri.parse('https://auth.tesla.com/oauth2/v3/token'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'grant_type': 'authorization_code',
      'client_id': 'ownerapi',
      'code': authorizationCode,
      'code_verifier': codeVerifier,
      'redirect_uri': 'https://auth.tesla.com/void/callback'
    }),
  );

  print('token exchange respnse: ${response.request}');

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    final accessToken = responseBody['access_token'];
    print('AccessToken in 200 : $accessToken');
    final refreshToken = responseBody['refresh_token'];
    return [accessToken,refreshToken];
  } else {
    print('Failed to exchange authorization code for bearer token');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return null;
  }
}

//Call this function if access token doesn't work anymore and you get 401 unauthorized error

Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
  final response = await http.post(
    Uri.parse('https://auth.tesla.com/oauth2/v3/token'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Linux; Android 9.0.0; VS985 4G Build/LRX21Y; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/58.0.3029.83 Mobile Safari/537.36',
      'X-Tesla-User-Agent': 'TeslaApp/3.4.4-350/fad4a582e/android/9.0.0',
    },
    body: jsonEncode({
      'grant_type': 'refresh_token',
      'client_id': 'ownerapi',
      'refresh_token': refreshToken,
      'scope': 'openid email offline_access'
    }),
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    final String bearerToken = responseBody['access_token'];
    final String newRefreshToken = responseBody['refresh_token'];

    // Exchange bearer token for access token
    final exchangeResponse = await http.post(
      Uri.parse('https://auth.tesla.com/oauth2/v3/token'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'client_id': 'ownerapi',
      }),
    );

    if (exchangeResponse.statusCode == 200) {
      final exchangeResponseBody = jsonDecode(exchangeResponse.body);
      exchangeResponseBody['refresh_token'] = newRefreshToken;
      return exchangeResponseBody;
    } else {
      print('Failed to exchange bearer token for access token');
      print('Response status: ${exchangeResponse.statusCode}');
      print('Response body: ${exchangeResponse.body}');
      return {};
    }
  } else {
    print('Failed to refresh access token');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return {};
  }
}


String generateRandomString(int length) {
  const _randomChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  const _randMax = _randomChars.length;
  final random = Random.secure();
  final buffer = StringBuffer();
  for (var i = 0; i < length; i++) {
    buffer.write(_randomChars[random.nextInt(_randMax)]);
  }
  return buffer.toString();
}

//final WebViewCookieManager cookieManager = WebViewCookieManager();





