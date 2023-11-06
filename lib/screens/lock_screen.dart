import 'dart:math';

import 'package:neumorphic_ui/neumorphic_ui.dart';
import 'package:teslawebwhisperer/screens/intro_page.dart';
import 'package:teslawebwhisperer/services/app_routes.dart';
import 'package:teslawebwhisperer/services/constants/svg_icon.dart';

import '../main.dart';
import '../tesla_service.dart';
import '../views/components/custom_button.dart';
import '../views/components/custom_button_app_bar.dart';
import 'home_screen.dart';

class LockScreen extends StatefulWidget {
  static const id = "/lock";

  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool animation = false;
  late AuthTokenProvider authTokenProvider;
  bool hasError = false; // Flag to track if there's an error
  bool isLoading = true; // Flag to control the display of the loading animation

  @override
  void initState() {
    draw();
    super.initState();
    authTokenProvider = AuthTokenProvider(); // Create an instance
    checkAndNavigate();

  }


  void checkAndNavigate() async {
    //await Future.delayed(Duration(seconds: 1));

    String? currentAccessToken = await authTokenProvider.getAccessToken();

    if (currentAccessToken == null || await authTokenProvider.isAccessTokenExpired()) {
      final String? refreshToken = await authTokenProvider.getRefreshToken();
      if (refreshToken != null) {
        final newTokenData = await authTokenProvider.refreshAccessToken(refreshToken);
        if (newTokenData != null && newTokenData['access_token'] is String) {
          currentAccessToken = newTokenData['access_token'];
          await authTokenProvider.storeTokenData(
            newTokenData['access_token'],
            newTokenData['refresh_token'],
            newTokenData['expires_in'],
          );
          navigateToHome(currentAccessToken!); // Proceed to the home screen
        } else {

            setState(() {
              hasError = true;
              isLoading = false;
            });


          //showErrorDialog(context); // Show error and possibly navigate to MainLoginScreen
        }
      } else {

        setState(() {
          hasError = true;
          isLoading = false;
        });

        //showErrorDialog(context); // No refresh token available, navigate to MainLoginScreen
      }
    } else {
      navigateToHome(currentAccessToken); // Access token is valid, proceed to the home screen
    }
  }

  void navigateToHome(String accessToken) async {
    // Obtain user and vehicle details, then navigate to HomeScreen
    try {
      Map<String, dynamic> userDetails = await getUserDetails(accessToken);
      Map<String, dynamic> vehicleDetails = await getVehicles(accessToken);
      String vehicleID = vehicleDetails['response'][0]['id'].toString();
      await wakeUp(accessToken, vehicleID);
      Map<String, dynamic> vehicleData = await getVehicleData(accessToken, vehicleID);

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(seconds: 1),
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
            accessToken: accessToken,
            userDetails: userDetails,
            vehicleData: vehicleData,
            vehicleID: vehicleID,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Create a fade transition for the incoming screen
            var fadeIn = Tween(begin: 0.0, end: 1.0).animate(animation);

            // Create a slide transition for the incoming screen
            var slideIn = Tween(
              begin: Offset(1.0, 0.0), // Starts from the right
              end: Offset(0.0, 0.0),
            ).animate(animation);

            // Create a fade transition for the outgoing screen
            var fadeOut = Tween(begin: 1.0, end: 0.0).animate(secondaryAnimation);

            // Create a slide transition for the outgoing screen
            var slideOut = Tween(
              begin: Offset(0.0, 0.0),
              end: Offset(-1.0, 0.0), // Moves to the left
            ).animate(secondaryAnimation);

            return Stack(
              children: <Widget>[
                SlideTransition(
                  position: slideOut,
                  child: FadeTransition(
                    opacity: fadeOut,
                    child: Container(), // Replace with the widget you want to slide out
                  ),
                ),
                SlideTransition(
                  position: slideIn,
                  child: FadeTransition(
                    opacity: fadeIn,
                    child: child, // This is your new screen widget
                  ),
                ),
              ],
            );
          },
        ),
      );





      /*
      Navigator.pushReplacement( // Use pushReplacement to prevent going back to the lock screen
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            accessToken: accessToken,
            userDetails: userDetails,
            vehicleData: vehicleData,
            vehicleID: vehicleID,
          ),
        ),
      );*/
    } catch (e) {
      showErrorDialog(context); // Handle errors by showing a dialog or navigating to MainLoginScreen
    }
  }

  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Authentication Error'),
            content: Text(
                'Unable to retrieve access token. Please log in again.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TeslaLoginScreen())); // Close the dialog
                  // Navigate to login screen or another appropriate action
                },
              ),
            ],
          ),
    );
  }

  void draw() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
    animation = true;
    setState(() {});
  }

  Widget buildLockButton() {
    if (hasError) {
      // If there is an error, show the login button
      return CustomButton(
        widget: Align(
          alignment: Alignment.center,
          child: SvgIcon.lock, // Replace with your login icon
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TeslaLoginScreen()),
          );
        },
        sizeCon1h: 50,
        sizeCon1w: 50,
        sizeCon2h: 44,
        sizeCon2w: 44,
        sizeCon3h: 44,
        sizeCon3w: 44,
      );
    } else if (isLoading) {
      // If still loading, show a loading animation
      return CircularProgressIndicator();// Use a linear progress indicator if preferred
    } else {
      // Otherwise, show the lock button
      return CustomButton(
        widget: Align(
          alignment: Alignment.center,
          child: SvgIcon.unlock,
        ),
        onPressed: () {
          AppRoutes.pushIntroScreen(context);
          // Your logic when the button is pressed
        },
        sizeCon1h: 50,
        sizeCon1w: 50,
        sizeCon2h: 44,
        sizeCon2w: 44,
        sizeCon3h: 44,
        sizeCon3w: 44,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232527),
      body: SafeArea(
        child: Column(
          children: [
            /// button appBar
            Padding(
              padding: const EdgeInsets.only(right: 30, top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButtonAppBar(widget: SvgIcon.off, onPressed: () async {
                    // Create an instance of AuthTokenProvider
                    final authTokenProvider = AuthTokenProvider();
                    // Call the method to clear tokens
                    await authTokenProvider.clearTokens();
                    // Navigate to the TeslaLoginScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TeslaLoginScreen()),
                    );
                  }),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 350,
              decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [
                Colors.lightBlueAccent.withOpacity(0.4),
                const Color.fromRGBO(0, 0, 0, 0)
              ])),
              child: Stack(
                children: [
                  AnimatedAlign(
                    alignment:
                        animation ? Alignment.topCenter : Alignment.center,
                    duration: const Duration(seconds: 2),
                    child: const Text(
                      "Volt Voice",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  AnimatedAlign(
                    alignment:
                        animation ? Alignment.bottomCenter : Alignment.center,
                    duration: const Duration(seconds: 2),
                    child: AnimatedContainer(
                      width:
                          animation ? MediaQuery.of(context).size.width : 250,
                      height: animation ? 310 : 250,
                      duration: const Duration(seconds: 2),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage("assets/images/img_tesla_white_2.png"),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            SizedBox(
              height: 79,
              width: 165,
              child: Neumorphic(
                style: NeumorphicStyle(
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(40)),
                  depth: -10,
                  color: const Color(0xFF18191B),
                  shadowDarkColorEmboss: const Color.fromRGBO(0, 0, 0, 0.3),
                  shadowLightColorEmboss:
                      const Color.fromRGBO(255, 255, 255, 0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(flex: 3),
                    const Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    const Spacer(flex: 2),
                    buildLockButton(),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
