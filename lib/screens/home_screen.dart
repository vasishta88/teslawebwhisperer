import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:teslawebwhisperer/services/constants/svg_icon.dart';
import 'package:teslawebwhisperer/views/components/custom_button_app_bar.dart';
import 'package:teslawebwhisperer/services/themes/colors.dart';
import 'package:teslawebwhisperer/views/components/custom_controller_menu.dart';

import 'package:teslawebwhisperer/services/themes/texts.dart';
import 'package:teslawebwhisperer/services/themes/text_styles.dart';

import 'package:teslawebwhisperer/tesla_service.dart';
import 'package:teslawebwhisperer/widgets.dart';

import '../main.dart';
import '../services/app_routes.dart';

import 'package:uni_links/uni_links.dart';

class HomeScreen extends StatefulWidget {
  static const id = "/home";

  final String accessToken;
  final Map<String, dynamic> userDetails;
  final Map<String, dynamic> vehicleData;
  final String vehicleID;
  //const HomeScreen({Key? key, required this.accessToken}) : super(key: key);

  const HomeScreen({
    Key? key,
    required this.accessToken,
    required this.userDetails,
    required this.vehicleData,
    required this.vehicleID,
  }) : super(key: key);




  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bool darkMode = false;

  bool selectedCar = true;
  bool selectedLightning = false;
  bool selectedKey = false;
  bool selectedPerson = false;

  //Deep Link and Google Assistant

  void initUniLinks() async {
    // Attach a listener to the links stream
    linkStream.listen((String? link) {
      // Parse the link and handle it within your app
      if (link != null) {
        Uri uri = Uri.parse(link);
        if (uri.host == 'setTemperature') {
          // Extract the temperature parameter and handle the action
          var temperature = uri.queryParameters['temperature'];
          if (temperature != null) {
            setTemperature(widget.accessToken, widget.vehicleID, double.parse(temperature), double.parse(temperature));
          }
        }
      }
    }, onError: (err) {
      // Handle exception by warning the user their action failed
    });
  }


  //String? vehicleID;

/*
  Future<Map<String, dynamic>> userDetails() async {
    Map<String, dynamic> userDetails = await getUserDetails(widget.accessToken);
    return userDetails;
  }

  Future<String> vehicleDetails() async {
    Map<String, dynamic> vehicle = await getVehicles(widget.accessToken);
    setState(() {
      vehicleID = vehicle['id'].toString();
    });
    return vehicleID!;
  }


  Future<double?> getVehicleRange(String? vehicleId) async {

    if (vehicleId == null) {
      return null;
    }


    Map<String, dynamic> vehicleData = await getVehicleData(widget.accessToken, vehicleId!);

    if (vehicleData.containsKey('charge_state') && vehicleData['charge_state'].containsKey('battery_range')) {
      return vehicleData['charge_state']['battery_range'].toDouble();
    } else {
      throw Exception('Failed to fetch vehicle range from the data');
    }
  }

   */





  //String vehicleID = vehicleDetails();


  @override
  Widget build(BuildContext context) {
    return ScaffoldGradientBackground(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: AppColors.unlockPageGradient,
      ),
      appBar: AppBar(
        toolbarHeight: lerpDouble(4, 17, 6),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.appBarGradient,
            ),
          ),
        ),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FutureBuilder<String>(
              future: getVehicleNameOrModel(widget.vehicleData),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LinearProgressIndicator();  // return a widget indicating loading
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}', style: AppTextStyles.sfProDisplay28.copyWith(color: Colors.white));
                } else {
                  return Text('${snapshot.data}', style: AppTextStyles.sfProDisplay28.copyWith(color: Colors.white));
                }
              },
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.0),
              child: BatteryRangeDisplay(batteryRangeFuture: getVehicleRange(widget.vehicleData)),
            )
          ],
        ),
        leadingWidth: 140,
        actions: [Padding(
          padding: const EdgeInsets.only(right: 22.0),
          child: CustomButtonAppBar(widget: SvgIcon.off, onPressed: () async {
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
        )],
      ),
      extendBody: true,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/img_tesla_grey.png"))),
              ),
              CustomControlPanel(
                accessToken: widget.accessToken,
                vehicleId: widget.vehicleID,
                vehicleData: widget.vehicleData,
              ),
              const SizedBox(
                height: 60,
              ),
              Center(
                child: GlassmorphicContainer(
                  width: MediaQuery.of(context).size.width / 1.16,
                  height: 500,
                  borderRadius: 40,
                  blur: 20,
                  alignment: Alignment.bottomCenter,
                  border: 1,
                  linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey.withOpacity(0.10),
                        Colors.grey.withOpacity(0.10),
                      ],
                      stops: const [
                        0.1,
                        1,
                      ]),
                  borderGradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      const Color(0xFFffffff).withOpacity(0.2),
                      const Color((0xFF282A2F)),
                    ],
                  ),
                  child: Column(
                    children: [

                      MenuItem(
                        icon: SvgIcon.vent,
                        title: [Texts.strClimate.tr(), Texts.strInterior20.tr()],
                        onTap: () => AppRoutes.pushClimateScreen(
                          context,
                          accessToken: widget.accessToken,
                          userDetails: widget.userDetails,
                          vehicleData: widget.vehicleData,
                          vehicleID: widget.vehicleID,
                        ),
                      ),

                      Padding(
                          padding: const EdgeInsets.only(top: 40.0, left: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgIcon.location,
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Texts.strLocation.tr(),
                                        FutureBuilder<String?>(
                                          future: getVehicleLocation(widget.vehicleData),
                                          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return CircularProgressIndicator();  // return a widget indicating loading
                                            } else if (snapshot.hasError) {
                                              return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white));
                                            } else {
                                              return Text('Address: ${snapshot.data}', style: TextStyle(color: Colors.white));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                              ),
                            ],
                          ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          onPressed: () {},
          child: AppIconButtonPressed(
            image: const AssetImage("assets/icons/ic_add.png"),
            onPressed: () {},//todo: Google Assistant Integration
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        child: ClipPath(
          clipper: MyClipper(),
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 80),
            painter: RPSCustomPainter(),
            child: Container(
              height: 80,

            ),
          ),
        ),
      ),
    );
  }
}

class AppIconButtonPressed extends StatelessWidget {
  final AssetImage image;
  final void Function()? onPressed;

  const AppIconButtonPressed({
    Key? key,
    required this.image,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff5D5E5F),
            Color(0xff000000),
          ],
        ),
      ),
      child: Container(
        width: 55,
        height: 55,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xff0C0D0E),
              Color(0xff3E434B),
            ],
          ),
        ),
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff16181B),
                Color(0xff2C3035),
              ],
            ),
          ),
          child: SizedBox(
            width: 25,
            height: 25,
            child: Image(
              image: image,
            ),
          ),
        ),
      ),
    );
  }
}

class BottomBarIcon extends StatelessWidget {
  final AssetImage image;
  bool isActive;

  // void Function()? onPressed;

  BottomBarIcon({
    super.key,
    required this.image,
    required this.isActive,
    // required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CupertinoButton(
        onPressed: null,
        child: Stack(
          children: [
            isActive
                ? Align(
              alignment: Alignment.center,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.blue,
                    )
                  ],
                ),
              ),
            )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Align(
                alignment: Alignment.center,
                child: Image(
                  color: isActive ? Colors.blue.shade200 : Colors.white,
                  image: image,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => shapePath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path_0 = shapePath(size);
    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Colors.black.withOpacity(0.50);
    paint0Fill.imageFilter = ImageFilter.blur(
      sigmaX: Shadow.convertRadiusToSigma(40),
      sigmaY: Shadow.convertRadiusToSigma(40),
    );

    // inner shadow
    final shadowPaint1 = Paint()
      ..blendMode = BlendMode.overlay
      ..colorFilter =
      ColorFilter.mode(Colors.white.withOpacity(0.22), BlendMode.overlay)
      ..imageFilter = ImageFilter.blur(
          sigmaX: Shadow.convertRadiusToSigma(3),
          sigmaY: Shadow.convertRadiusToSigma(3));

    canvas.drawPath(path_0.shift(const Offset(0.5, 0.2)), shadowPaint1);
    // blur
    canvas.drawPath(path_0, paint0Fill);

    // inner shadow
    final shadowPaint2 = Paint()
      ..blendMode = BlendMode.overlay
      ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.overlay)
      ..imageFilter = ImageFilter.blur(
          sigmaX: Shadow.convertRadiusToSigma(21),
          sigmaY: Shadow.convertRadiusToSigma(21));
    canvas.drawPath(path_0.shift(const Offset(-3, -20)), shadowPaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

Path shapePath(Size size) {
  Path path_0 = Path();
  path_0.moveTo(0, size.height * 0.4515833);
  path_0.cubicTo(
      0,
      size.height * 0.4086077,
      size.width * 0.003320077,
      size.height * 0.3672936,
      size.width * 0.009267051,
      size.height * 0.3362654);
  path_0.lineTo(size.width * 0.04192103, size.height * 0.1658974);
  path_0.cubicTo(size.width * 0.06223282, size.height * 0.05992192,
      size.width * 0.09031718, 0, size.width * 0.1196736, 0);
  path_0.lineTo(size.width * 0.3187897, 0);
  path_0.cubicTo(
      size.width * 0.3407769,
      0,
      size.width * 0.3622385,
      size.height * 0.03365282,
      size.width * 0.3802897,
      size.height * 0.09643564);
  path_0.lineTo(size.width * 0.4341077, size.height * 0.2836308);
  path_0.cubicTo(
      size.width * 0.4737154,
      size.height * 0.4213962,
      size.width * 0.5262846,
      size.height * 0.4213962,
      size.width * 0.5658923,
      size.height * 0.2836308);
  path_0.lineTo(size.width * 0.6197103, size.height * 0.09643564);
  path_0.cubicTo(size.width * 0.6377615, size.height * 0.03365269,
      size.width * 0.6592231, 0, size.width * 0.6812103, 0);
  path_0.lineTo(size.width * 0.8803256, 0);
  path_0.cubicTo(
      size.width * 0.9096821,
      0,
      size.width * 0.9377667,
      size.height * 0.05992192,
      size.width * 0.9580795,
      size.height * 0.1658974);
  path_0.lineTo(size.width * 0.9907333, size.height * 0.3362654);
  path_0.cubicTo(size.width * 0.9966795, size.height * 0.3672936, size.width,
      size.height * 0.4086077, size.width, size.height * 0.4515833);
  path_0.lineTo(size.width, size.height);
  path_0.lineTo(0, size.height);
  path_0.lineTo(0, size.height * 0.4515833);
  path_0.close();

  return path_0;
}

class MenuItem extends StatelessWidget {
  final Widget icon;
  final List<Widget> title;
  final VoidCallback onTap;

  MenuItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0, left: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: title,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SvgIcon.chevron_right,
            ),
          ],
        ),
      ),
    );
  }
}

