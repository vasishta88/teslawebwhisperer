import 'dart:async';

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

  int? driverSeatHeaterLevel;
  int? passengerSeatHeaterLevel;

  @override
  void initState() {
    super.initState();
    _initializeSeatHeaterLevels();
  }

  Future<void> _initializeSeatHeaterLevels() async {
    driverSeatHeaterLevel = await getDriverSeatHeater(widget.vehicleData);
    passengerSeatHeaterLevel = await getPassengerSeatHeater(widget.vehicleData);
    setState(() {});
  }

  Future<void> _updateSeatHeater(int heater, int level) async {
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
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          Column(
            children: [
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
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(top: 100.0),  // Adjusting position
                  child: CustomButtonSlider(
                    onAngleChanged: (angle) {
                      double calculatedTemp = ((angle / (3.14 * 2)) * 11.5 + 16).toDouble();
                      if (calculatedTemp < 16) {
                        volume = 16;
                      } else if (calculatedTemp > 27) {
                        volume = 27;
                      } else {
                        volume = calculatedTemp;
                      }

                      // Cancel any previous timer
                      _debounceTimer?.cancel();

                      // Start a timer which waits for 1 second (or your preferred duration)
                      // before calling the service.
                      _debounceTimer = Timer(Duration(seconds: 1), () {
                        setTemperature(widget.accessToken,widget.vehicleID,volume, volume);  // Assuming setDriverTemp takes the temperature as a parameter
                      });

                      setState(() {});
                    },

                    vehicleData: widget.vehicleData,
                  ),
                ),
              ),



              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        seatWarmingButton(
                          driverSeatHeaterLevel ?? 0,
                              () async {
                            // Toggle the heater level for the driver's seat
                            int newLevel = (driverSeatHeaterLevel! + 1) % 4;
                            await _updateSeatHeater(0, newLevel);
                          },
                          "Driver Seat",
                        ),
                        seatWarmingButton(
                          passengerSeatHeaterLevel ?? 0,
                              () async {
                            // Toggle the heater level for the passenger's seat
                            int newLevel = (passengerSeatHeaterLevel! + 1) % 4;
                            await _updateSeatHeater(1, newLevel);
                          },
                          "Passenger Seat",
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),


          const CustomBottomBar(),
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


