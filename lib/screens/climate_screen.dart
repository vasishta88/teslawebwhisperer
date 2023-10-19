import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teslawebwhisperer/services/app_routes.dart';
import 'package:teslawebwhisperer/services/constants/svg_icon.dart';
import 'package:teslawebwhisperer/services/themes/colors.dart';
import 'package:teslawebwhisperer/views/components/custom_wthbutton.dart';
import '../services/themes/texts.dart';
import '../views/components/circular_slider.dart';
import '../views/components/custom_appbar_button.dart';
import '../views/components/custom_buttombar.dart';
import '../views/components/custom_button_slider.dart';
import '../tesla_service.dart';

import 'home_screen.dart';

class ClimateScreen extends StatefulWidget {
  static const id = "/climate";

  final String accessToken;
  final Map<String, dynamic> userDetails;
  final Map<String, dynamic> vehicleData;
  final String vehicleID;

  const ClimateScreen({
    Key? key,
    required this.accessToken,
    required this.userDetails,
    required this.vehicleData,
    required this.vehicleID,
  }) : super(key: key);

 // const ClimateScreen({super.key});

  @override
  State<ClimateScreen> createState() => _ClimateScreenState();
}

class _ClimateScreenState extends State<ClimateScreen> {
  double volume = 0;
  Timer? _debounceTimer;
  bool? isClimateOn;
  bool isLoading = false;


  int? driverSeatHeaterLevel;
  int? passengerSeatHeaterLevel;

  @override
  void initState() {
    super.initState();
    _fetchClimateState();
    _initializeSeatHeaterLevels();
  }

  Future<void> _fetchClimateState() async {
    isClimateOn = await getClimateState(widget.accessToken, widget.vehicleID);
    volume = (await getDriverTemp(widget.vehicleData))!;
    setState(() {});
  }


  Future<void> _toggleClimate() async {
    await _toggleFeature( turnClimateOff, turnClimateOn, 'Climate');
  }

  void _adjustTemperature(double adjustment) {
    volume += adjustment;

    // Round to the nearest 0.5 increment
    volume = (volume * 2).roundToDouble() / 2;

    // Make sure volume stays within bounds
    if (volume < 16) volume = 16;
    if (volume > 27) volume = 27;

    if (isClimateOn == false) {
      _toggleClimate();
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 1), () {
      setTemperature(widget.accessToken, widget.vehicleID, volume, volume);
    });
    setState(() {});
  }


  Future<void> _toggleFeature(Function deactivate, Function activate, String featureName) async {
    if (isLoading) return;

    // Fetch the most recent state
    await _fetchClimateState();

    setState(() {
      isLoading = true;
    });

    try {
      bool result;
      if (isClimateOn!) {
        result = await deactivate(widget.accessToken, widget.vehicleID);
      } else {
        result = await activate(widget.accessToken, widget.vehicleID);
      }

      // Fetch the state again after toggling to ensure UI reflects the most recent state
      //await _fetchClimateState();

      // Explicitly update isClimateOn based on the result
      if (featureName == 'Climate') {
        setState(() {
          isClimateOn = !isClimateOn!;
        });
      }

    } catch (error) {
      print('Error during toggle $featureName: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _initializeSeatHeaterLevels() async {
    driverSeatHeaterLevel = await getDriverSeatHeater(widget.vehicleData);
    passengerSeatHeaterLevel = await getPassengerSeatHeater(widget.vehicleData);
    setState(() {});
  }

  Future<void> _updateSeatHeater(int heater, int level) async {

    if (isClimateOn == false) {
      _toggleClimate();
    }

    await remoteSeatHeater(widget.accessToken, widget.vehicleID, heater, level);
    if (heater == 0) {
      driverSeatHeaterLevel = level;
    } else {
      passengerSeatHeaterLevel = level;
    }
    setState(() {});
  }

  Widget seatWarmingButton(int level, VoidCallback onPressed, String label) {
    Color buttonColor;
    switch (level) {
      case 0:
        buttonColor = AppColors.backgroundDark;
        break;
      case 1:
        buttonColor = Colors.orange[200]!;
        break;
      case 2:
        buttonColor = Colors.orange[400]!;
        break;
      case 3:
        buttonColor = Colors.deepOrange;
        break;
      default:
        buttonColor = AppColors.backgroundDark;
    }

    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: CircleBorder(),
            elevation: 5.0,
          ),
          onPressed: onPressed,
          child: Icon(
            Icons.event_seat,
            size: 40.0,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10.0),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      ],
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/img_tesla_dark.png',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

        LayoutBuilder(
            builder: (context, constraints) {
            double driverSeatTop = constraints.maxHeight * 0.45;  // 20% from top
            double driverSeatLeft = constraints.maxWidth * 0.52;  // 25% from left

            double passengerSeatTop = constraints.maxHeight * 0.45;  // 20% from top
            double passengerSeatRight = constraints.maxWidth * 0.28;  // 25% from right

          return Stack(
            children: [
              //Top bar
              Expanded(
                flex: 1,
                child: Padding(
                  padding:
                  const EdgeInsets.only(top: 70, left: 36, right: 36),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          AppRoutes.popBack(context);
                        },
                        child: CustomButton(
                          widget: Center(
                            child: SvgIcon.chevron_left.copyWith(
                              newWidth: 13,
                              newHeight: 22,
                              newColor: AppColors.textGrey60,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Texts.strClimate.tr(),
                      const Spacer(),
                      CustomButton(
                        widget: Center(
                          child: SvgIcon.person.copyWith(
                            newWidth: 13,
                            newHeight: 22,
                            newColor: AppColors.textGrey60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Position driver seat button
              Positioned(
                top: driverSeatTop,  // You might need to adjust this value
                left: driverSeatLeft,  // Adjust this value too
                child: seatWarmingButton(
                  driverSeatHeaterLevel ?? 0,
                      () async {
                    // Toggle the heater level for the driver's seat
                    int newLevel = (driverSeatHeaterLevel! + 1) % 4;
                    await _updateSeatHeater(0, newLevel);
                  },
                  "Driver",
                ),
              ),

              //Position passenger seat button

              Positioned(
                top: passengerSeatTop,  // You might need to adjust this value
                left: passengerSeatRight,  // Adjust this value too
                child: seatWarmingButton(
                  passengerSeatHeaterLevel ?? 0,
                      () async {
                    // Toggle the heater level for the passenger's seat
                    int newLevel = (passengerSeatHeaterLevel! + 1) % 4;
                    await _updateSeatHeater(1, newLevel);
                  },
                  "Passenger",
                ),
              ),

          //Bottom bar
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomPaint(
              painter: CustomButtonBorder(),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
                child: Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaY: Shadow.convertRadiusToSigma(5),
                      sigmaX: Shadow.convertRadiusToSigma(5),
                    ),
                    child: Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [

                                isClimateOn == null
                                    ? CircularProgressIndicator()
                                    : IconButton(
                                  icon: Icon(
                                    CupertinoIcons.power,
                                    color: isClimateOn! ? Color(0xff2FB8FF) : Colors.grey, // Blue when on, Grey when off
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    await _toggleClimate();
                                    setState(() {
                                      //isClimateOn = !isClimateOn!;
                                      print('After: $isClimateOn');
                                    });
                                  },
                                ),


                                CupertinoButton(
                                  onPressed: () {},
                                  child: GestureDetector(
                                    onTap: () {_adjustTemperature(-0.5);},
                                    child: const Icon(
                                      CupertinoIcons.back,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                  },
                                  child: Text(
                                    "$volume",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 34),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.right_chevron,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {_adjustTemperature(0.5);},
                                ),
                                const Icon(
                                  CupertinoIcons.airplane,
                                  color: Color(0xffEBEBF5),
                                  size: 30,
                                ),
                              ],
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "On",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "Vent",
                                  style: TextStyle(color: Color(0xffEBEBF5)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          //const CustomBottomBar(),
        ],
          );
            },
        ),
        ],
      ),
    );
  }



  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

}

class CustomButtonBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xff000000).withOpacity(0),
        Colors.white.withOpacity(0.2)
      ],
    ).createShader(const Rect.fromLTWH(0, 0, 50, 50));

    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;

    canvas.drawDRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(40),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 1, size.height - 1),
        const Radius.circular(40),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }

}
