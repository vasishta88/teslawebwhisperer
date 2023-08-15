import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teslawebwhisperer/screens/charge_screen.dart';
import 'package:teslawebwhisperer/screens/climate_screen.dart';
import 'package:teslawebwhisperer/screens/control_screen.dart';
import 'package:teslawebwhisperer/screens/lock_screen.dart';
import 'package:teslawebwhisperer/services/app_routes.dart';
import 'package:teslawebwhisperer/services/constants/svg_icon.dart';
import 'package:teslawebwhisperer/services/themes/colors.dart';

import '../../screens/charge_screen.dart';
import '../../tesla_service.dart';

class CustomControlPanel extends StatefulWidget {
  //const CustomControlPanel({super.key});
  final String accessToken;
  final String vehicleId;
  final Map<String, dynamic> vehicleData;

  const CustomControlPanel({
    required this.accessToken,
    required this.vehicleId,
    required this.vehicleData,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomControlPanel> createState() => _CustomControlPanelState();
}

class _CustomControlPanelState extends State<CustomControlPanel> {

  /*

  bool? isLocked; // Set it as nullable initially since we don't know the state yet
  bool isLoading = false;  // to keep track of API call status

  @override
  void initState() {
    super.initState();
    _fetchVehicleState();
  }

  Future<void> _fetchVehicleState() async {
    bool lockedState = await getLockedState(widget.accessToken, widget.vehicleId);
    setState(() {
      isLocked = lockedState;
    });
  }

  Future<void> _toggleLock() async {
    if (isLoading) return;  // if an API call is in progress, return
    print('toggle lock is loading: $isLoading');

    setState(() {
      isLoading = true;  // set loading to true before starting the API call
      print('toggle lock is loading 2: $isLoading');
    });
    print('toggle lock is locked: $isLocked');
    try {
      if (isLocked!) {
        print('toggle lock accesstoken: ${widget.accessToken}');
        print('toggle lock vehicleID: ${widget.vehicleId}');
        bool result = await unlockDoor(widget.accessToken, widget.vehicleId);
        print('toggle lock result: $result');
        if (result) {
          setState(() {
            isLocked = false;
            print('toggle lock is locked 3: $isLocked');
          });
        }
      } else {
        bool result = await lockDoor(widget.accessToken, widget.vehicleId);
        if (result) {
          setState(() {
            isLocked = true;
          });
        }
      }
    } catch (error) {
      print('error in toggle lock State: $isLocked');
      print('Error during toggle lock: $error');
      // Handle any errors here, you might want to show a toast or a dialog
    } finally {
      setState(() {
        isLoading = false;  // set loading to false after API call completes
      });
    }
  }

   */

  bool? isLocked, isClimateOn, isSentryOn, isFrunkOpen;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchVehicleStates();
  }

  Future<void> _fetchVehicleStates() async {
    bool lockedState = await getLockedState(widget.accessToken, widget.vehicleId);
    bool climateState = await getClimateState(widget.accessToken, widget.vehicleId);
    bool sentryState = await getSentryState(widget.accessToken, widget.vehicleId);
    //bool frunkState = await getFrunkState(widget.accessToken, widget.vehicleId);

    setState(() {
      isLocked = lockedState;
      isClimateOn = climateState;
      isSentryOn = sentryState;
      isFrunkOpen = false;
    });
  }

  Future<void> _toggleLock() async {
    await _toggleFeature(isLocked!, unlockDoor, lockDoor, 'Lock');
  }

  Future<void> _toggleClimate() async {
    await _toggleFeature(isClimateOn!, turnClimateOff, turnClimateOn, 'Climate');
  }

  Future<void> _toggleSentry() async {
    await _toggleFeature(isSentryOn!, turnSentryOff, turnSentryOn, 'Sentry');
  }

  Future<void> _toggleFrunk() async {
    await _toggleFeature(isFrunkOpen!, openFrunk, openFrunk, 'Frunk');
  }

  Future<void> _toggleFeature(bool currentStatus, Function deactivate, Function activate, String featureName) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      bool result;
      if (currentStatus) {
        result = await deactivate(widget.accessToken, widget.vehicleId);
      } else {
        result = await activate(widget.accessToken, widget.vehicleId);
      }

      setState(() {
        if (featureName == 'Lock') isLocked = !currentStatus;
        if (featureName == 'Climate') isClimateOn = !currentStatus;
        if (featureName == 'Sentry') isSentryOn = !currentStatus;
        if (featureName == 'Frunk') isFrunkOpen = !currentStatus;
      });
    } catch (error) {
      print('Error during toggle $featureName: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }




  bool lockFillColor = true;
  bool windSnowColor = true;
  bool chargeBulbColor = true;
  bool carDetailedColor = true;



  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xD91E1F20),
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(
            offset: Offset(-35, -35),
            blurRadius: 20,
            color: Color.fromRGBO(255, 255, 255, .04),
          ),
          BoxShadow(
            offset: Offset(-45, -55),
            blurRadius: 2,
            color: Color.fromRGBO(0, 0, 0, .02),
          ),
          BoxShadow(
            offset: Offset(-1, 30),
            blurRadius: 20,
            color: Color.fromRGBO(0, 0, 0, .35),
          ),
          BoxShadow(
            offset: Offset(-10, -20),
            blurRadius: 16,
            color: Color(0xFFFFFFF),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
              CupertinoButton(
              child: (isLocked == null)
              ? CircularProgressIndicator()  // Show loading spinner while fetching initial state
              : (isLoading
              ? CircularProgressIndicator()  // Show loading spinner while making API call
              : (isLocked!
              ? SvgIcon.lock.copyWith(newColor: AppColors.textGrey30)
              : SvgIcon.unlock.copyWith(newColor: AppColors.textGrey30))),
          onPressed: _toggleLock,
        ),

          CupertinoButton(
            child: (isClimateOn == null)
                ? CircularProgressIndicator()
                : (isLoading
                ? CircularProgressIndicator()
                : (isClimateOn!
                ? SvgIcon.wind.copyWith(newColor: AppColors.textGrey30)
                : SvgIcon.vent.copyWith(newColor: AppColors.textGrey30))),
            onPressed: () async {
              await _toggleFeature(isClimateOn!, turnClimateOff, turnClimateOn, 'Climate');
            },
          ),



          CupertinoButton(
            child: (isSentryOn == null)
                ? CircularProgressIndicator()
                : (isLoading
                ? CircularProgressIndicator()
                : SvgIcon.location_2.copyWith(
                newColor: isSentryOn! ? Colors.white : AppColors.textGrey30)),
            onPressed: () async {
              await _toggleFeature(isSentryOn!, turnSentryOff, turnSentryOn, 'Sentry');
            },
          ),


          CupertinoButton(
            child: (isFrunkOpen == null)
                ? CircularProgressIndicator()
                : (isLoading
                ? CircularProgressIndicator()
                : SvgIcon.car_1.copyWith(
                newColor: isFrunkOpen! ? Colors.white : AppColors.textGrey30)),
            onPressed: () async {
              await _toggleFeature(isFrunkOpen!, openFrunk, openFrunk, 'Frunk');
            },
          ),
        ],
      ),
    );
  }
}
