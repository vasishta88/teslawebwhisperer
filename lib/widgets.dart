
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VehicleIdDisplay extends StatelessWidget {
  final Future<String> vehicleIdFuture;

  VehicleIdDisplay({required this.vehicleIdFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: vehicleIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return Text(snapshot.data!);
        } else {
          return Text("Unknown state");
        }
      },
    );
  }
}

class BatteryRangeDisplay extends StatelessWidget {
  final Future<double?> batteryRangeFuture;

  BatteryRangeDisplay({required this.batteryRangeFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double?>(
      future: batteryRangeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text(
            "Error: ${snapshot.error}",
            style: TextStyle(color: Colors.white),
          );
        } else if (snapshot.hasData) {
          return Text(
            "${snapshot.data!} miles",  // Assuming the unit is miles
            style: TextStyle(color: Colors.white),
          );
        } else {
          return Text(
            "Unknown state",
            style: TextStyle(color: Colors.white),
          );
        }
      },
    );
  }
}


