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

import 'home_screen.dart';

class ControlScreen extends StatefulWidget {
  static const id = "/control";

  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  int volume = 0;
  bool driverSeatWarming = false;
  bool passengerSeatWarming = false;

  Widget seatWarmingButton(bool isActive, VoidCallback onPressed, String label) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? Colors.deepOrange : AppColors.backgroundDark,
            shape: CircleBorder(),
            elevation: 5.0,
          ),
          onPressed: onPressed,
          child: Icon(
            Icons.event_seat,
            size: 40.0,
            color: isActive ? Colors.white : Colors.grey,
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


                /*Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      ControlWidget(
                        title: "Ac",
                        icon: Center(
                          child: SvgIcon.snow.copyWith(
                            newHeight: 22,
                            newWidth: 22,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ControlWidget(

                        title: "Fan",
                        icon: Center(
                          child: SvgIcon.wind.copyWith(
                            newHeight: 22,
                            newWidth: 22,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ControlWidget(
                        title: "Heat",
                        icon: Center(
                          child: SvgIcon.wind_water.copyWith(
                            newHeight: 22,
                            newWidth: 22,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ControlWidget(
                        title: "Wind",
                        icon: Center(
                          child: SvgIcon.wind.copyWith(
                            newHeight: 22,
                            newWidth: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),*/
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          seatWarmingButton(
                            driverSeatWarming,
                                () {
                              setState(() {
                                driverSeatWarming = !driverSeatWarming;
                              });
                            },
                            "Driver Seat",
                          ),
                          seatWarmingButton(
                            passengerSeatWarming,
                                () {
                              setState(() {
                                passengerSeatWarming = !passengerSeatWarming;
                              });
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
}
