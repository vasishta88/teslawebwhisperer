import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';


final _baseUrl = 'https://owner-api.teslamotors.com';


//Data

Future<Map<String, dynamic>> getUserDetails(String accessToken) async {
  final response = await http.get(
    Uri.parse('https://owner-api.teslamotors.com/api/1/users/me'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    return responseBody;
  } else {
    print('Failed to get user details');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return {};
  }
}

Future<Map<String, dynamic>> getVehicles(String accessToken) async {
  final response = await http.get(
    Uri.parse('https://owner-api.teslamotors.com/api/1/vehicles'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    return responseBody;
  } else {
    print('Failed to get user details');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return {};
  }
}

Future<Map<String, dynamic>> getVehicleData(String accessToken, String vehicleId) async {
  const maxRetries = 3;  // Define how many times you want to retry.
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/1/vehicles/$vehicleId/vehicle_data'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody.containsKey('response')) {
          return responseBody['response'];
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch vehicle data: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (retryCount == maxRetries - 1) {
        throw e;  // If we've reached the maximum number of retries, throw the exception.
      }
      retryCount++;
      await Future.delayed(Duration(seconds: 2));  // Introducing a delay before retrying.
    }
  }

  throw Exception('Failed to fetch vehicle data after $maxRetries attempts.');
}


/*
Future<Map<String, dynamic>> getVehicleData(String accessToken, String vehicleId) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/api/1/vehicles/$vehicleId/vehicle_data'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    if (responseBody.containsKey('response')) {
      return responseBody['response'];
    } else {
      throw Exception('Unexpected response format');
    }
  } else {
    throw Exception('Failed to fetch vehicle data: ${response.reasonPhrase}');
  }
}

*/

/*
Future<double?> getVehicleRange(String? vehicleId, String accessToken) async {

  if (vehicleId == null) {
    return null;
  }


  Map<String, dynamic> vehicleData = await getVehicleData(accessToken, vehicleId!);

  if (vehicleData.containsKey('charge_state') && vehicleData['charge_state'].containsKey('battery_range')) {
    return vehicleData['charge_state']['battery_range'].toDouble();
  } else {
    throw Exception('Failed to fetch vehicle range from the data');
  }
}





Future<String> getVehicleNameOrModel(String? vehicleId, String accessToken) async {
  if (vehicleId == null) {
    throw Exception('Vehicle ID is null');
  }

  Map<String, dynamic> vehicleData = await getVehicleData(accessToken, vehicleId!);

  if (vehicleData.containsKey('vehicle_state')) {
    if (vehicleData['vehicle_state']['vehicle_name'] != null) {
      return vehicleData['vehicle_state']['vehicle_name'];
    } else if (vehicleData.containsKey('vehicle_config') && vehicleData['vehicle_config'].containsKey('car_type')) {
      return vehicleData['vehicle_config']['car_type'];
    } else {
      return 'Tesla';
    }
  } else {
    return 'Tesla';
  }
}


Future<String?> getVehicleLocation(String? vehicleId, String accessToken) async {
  if (vehicleId == null) {
    return null;
  }

  Map<String, dynamic> vehicleData = await getVehicleData(accessToken, vehicleId);

  if (vehicleData.containsKey('drive_state')) {
    double latitude = vehicleData['drive_state']['latitude'];
    double longitude = vehicleData['drive_state']['longitude'];

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Return just the street address
        return place.street ?? "Address not found";
      } else {
        throw Exception('No address found for the given coordinates.');
      }
    } catch (e) {
      throw Exception('Failed to fetch address: $e');
    }
  } else {
    throw Exception('Failed to fetch vehicle location from the data');
  }
}


 */


Future<bool> getLockedState(String accessToken, String vehicleId) async {
  Map<String, dynamic> vehicleData = await getVehicleData(accessToken, vehicleId);
  if (vehicleData.containsKey('vehicle_state') && vehicleData['vehicle_state'].containsKey('locked')) {
    return vehicleData['vehicle_state']['locked'];
  } else {
    throw Exception('Failed to fetch locked state from the data');
  }
}


Future<bool> getClimateState(String accessToken, String vehicleId) async {
  Map<String, dynamic> vehicleData = await getVehicleData(accessToken, vehicleId);
  if (vehicleData.containsKey('climate_state') && vehicleData['climate_state'].containsKey('is_auto_conditioning_on')) {
    return vehicleData['climate_state']['is_auto_conditioning_on'];
  } else {
    throw Exception('Failed to fetch climate state from the data');
  }
}


Future<bool> getSentryState(String accessToken, String vehicleId) async {
  Map<String, dynamic> vehicleData = await getVehicleData(accessToken, vehicleId);
  if (vehicleData.containsKey('vehicle_state') && vehicleData['vehicle_state'].containsKey('sentry_mode')) {
    return vehicleData['vehicle_state']['sentry_mode'];
  } else {
    throw Exception('Failed to fetch locked state from the data');
  }
}


Future<double?> getVehicleRange(Map<String, dynamic> vehicleData) async {
  if (vehicleData.containsKey('charge_state') && vehicleData['charge_state'].containsKey('battery_range')) {
    return vehicleData['charge_state']['battery_range'].toDouble();
  } else {
    throw Exception('Failed to fetch vehicle range from the data');
  }
}

/*
Future<bool> getLockedState(Map<String, dynamic> vehicleData) async {
  if (vehicleData.containsKey('vehicle_state') && vehicleData['vehicle_state'].containsKey('locked')) {
    return vehicleData['vehicle_state']['locked'];
  } else {
    throw Exception('Failed to fetch locked state from the data');
  }
}

Future<bool> getClimateState(Map<String, dynamic> vehicleData) async {
  if (vehicleData.containsKey('climate_state') && vehicleData['climate_state'].containsKey('is_auto_conditioning_on')) {
    return vehicleData['climate_state']['is_auto_conditioning_on'];
  } else {
    throw Exception('Failed to fetch climate state from the data');
  }
}

Future<bool> getSentryState(Map<String, dynamic> vehicleData) async {
  if (vehicleData.containsKey('vehicle_state') && vehicleData['vehicle_state'].containsKey('sentry_mode')) {
    return vehicleData['vehicle_state']['sentry_mode'];
  } else {
    throw Exception('Failed to fetch locked state from the data');
  }
}

 */

Future<String> getVehicleNameOrModel(Map<String, dynamic> vehicleData) async {
  if (vehicleData.containsKey('vehicle_state')) {
    if (vehicleData['vehicle_state']['vehicle_name'] != null) {
      return vehicleData['vehicle_state']['vehicle_name'];
    } else if (vehicleData.containsKey('vehicle_config') && vehicleData['vehicle_config'].containsKey('car_type')) {
      return vehicleData['vehicle_config']['car_type'];
    } else {
      return 'Tesla';
    }
  } else {
    return 'Tesla';
  }
}

Future<String?> getVehicleLocation(Map<String, dynamic> vehicleData) async {
  if (vehicleData.containsKey('drive_state')) {
    double latitude = vehicleData['drive_state']['latitude'];
    double longitude = vehicleData['drive_state']['longitude'];

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Return just the street address
        return place.street ?? "Address not found";
      } else {
        throw Exception('No address found for the given coordinates.');
      }
    } catch (e) {
      throw Exception('Failed to fetch address: $e');
    }
  } else {
    throw Exception('Failed to fetch vehicle location from the data');
  }
}


//Commands


Future<Map<String, dynamic>> wakeUp(String accessToken, String vehicleId) async {
  final expiry = DateTime.now().add(Duration(seconds: 30));
  while (DateTime.now().isBefore(expiry)) {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/1/vehicles/$vehicleId/wake_up'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body)['response'];
      if (responseBody['state'] == 'online') {
        return responseBody;
      }
    } else {
      throw Exception('Failed to wake up vehicle: ${response.reasonPhrase}');
    }

    // Wait for 1 second before the next attempt
    await Future.delayed(Duration(seconds: 10));
  }

  throw Exception('Failed to wake up vehicle: timeout');
}


Future<bool> setTemperature(String accessToken, String vehicleId, double driverTemp, double passengerTemp) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/api/1/vehicles/$vehicleId/command/set_temps'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'driver_temp': driverTemp,
      'passenger_temp': passengerTemp,
    }),
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    if (responseBody['result'] == true) {
      return true;
    } else {
      throw Exception('Failed to set temperature: ${responseBody['reason']}');
    }
  } else {
    throw Exception('Failed to set temperature: ${response.reasonPhrase}');
  }
}

Future<bool> lockDoor(String accessToken, String vehicleId) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/api/1/vehicles/$vehicleId/command/door_lock'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  print('API Response: ${response.body}');


  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    if (responseBody['response']['result'] == true) {
      return true;
    } else {
      throw Exception('Failed to unlock the door: ${responseBody['response']['reason']}');
    }
  } else {
    throw Exception('Failed to unlock the door: ${response.reasonPhrase}');
  }
}


Future<bool> unlockDoor(String accessToken, String vehicleId) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/api/1/vehicles/$vehicleId/command/door_unlock'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  print('API Response: ${response.body}');


  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    if (responseBody['response']['result'] == true) {
      return true;
    } else {
      throw Exception('Failed to unlock the door: ${responseBody['response']['reason']}');
    }
  } else {
    throw Exception('Failed to unlock the door: ${response.reasonPhrase}');
  }
}



Future<bool> turnClimateOn(String accessToken, String vehicleId) async {

  print('climate start accesstoken: $accessToken');
  print('climate start vehicleID: $vehicleId');

  final response = await http.post(
    Uri.parse('$_baseUrl/api/1/vehicles/$vehicleId/command/auto_conditioning_start'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  print('auto_conditioning_start API Response: ${response.body}');
  print('auto_conditioning_start API code: ${response.statusCode}');


  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    if (responseBody['response']['result'] == true) {
      return true;
    } else {
      throw Exception('Failed to auto_conditioning_start: ${responseBody['response']['reason']}');
    }
  } else {
    throw Exception('Failed to auto_conditioning_start: ${response.reasonPhrase}');
  }
}



Future<bool> turnClimateOff(String accessToken, String vehicleId) async {

  print('auto_conditioning_stop accesstoken: $accessToken');
  print('auto_conditioning_stop vehicleID: $vehicleId');

  final response = await http.post(
    Uri.parse('$_baseUrl/api/1/vehicles/$vehicleId/command/auto_conditioning_stop'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  print('auto_conditioning_stop API Response: ${response.body}');
  print('auto_conditioning_stop API code: ${response.statusCode}');


  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    if (responseBody['response']['result'] == true) {
      return true;
    } else {
      throw Exception('Failed to auto_conditioning_stop: ${responseBody['response']['reason']}');
    }
  } else {
    throw Exception('Failed to auto_conditioning_stop: ${response.reasonPhrase}');
  }
}


Future<bool> turnSentryOff(String accessToken, String vehicleId) async {
  print('set_sentry_mode accesstoken: $accessToken');
  print('set_sentry_mode vehicleID: $vehicleId');

  final response = await http.post(
    Uri.parse('$_baseUrl/api/1/vehicles/$vehicleId/command/set_sentry_mode'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'on': false,
    }),
  );

  print('set_sentry_mode API Response: ${response.body}');
  print('set_sentry_mode API code: ${response.statusCode}');

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    if (responseBody['response']['result'] == true) {
      return true;
    } else {
      throw Exception('Failed to set_sentry_mode off: ${responseBody['response']['reason']}');
    }
  } else {
    throw Exception('Failed to set_sentry_mode off: ${response.reasonPhrase}');
  }
}



Future<bool> turnSentryOn(String accessToken, String vehicleId) async {
  print('set_sentry_mode accesstoken: $accessToken');
  print('set_sentry_mode vehicleID: $vehicleId');

  final response = await http.post(
    Uri.parse('$_baseUrl/api/1/vehicles/$vehicleId/command/set_sentry_mode'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'on': true,
    }),
  );

  print('set_sentry_mode API Response: ${response.body}');
  print('set_sentry_mode API code: ${response.statusCode}');

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    if (responseBody['response']['result'] == true) {
      return true;
    } else {
      throw Exception('Failed to set_sentry_mode off: ${responseBody['response']['reason']}');
    }
  } else {
    throw Exception('Failed to set_sentry_mode off: ${response.reasonPhrase}');
  }
}



Future<bool> openFrunk(String accessToken, String vehicleId) async {
  print('set_sentry_mode accesstoken: $accessToken');
  print('set_sentry_mode vehicleID: $vehicleId');

  final response = await http.post(
    Uri.parse('$_baseUrl/api/1/vehicles/$vehicleId/command/actuate_trunk'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'which_trunk': 'front',
    }),
  );

  print('set_sentry_mode API Response: ${response.body}');
  print('set_sentry_mode API code: ${response.statusCode}');

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    if (responseBody['response']['result'] == true) {
      return true;
    } else {
      throw Exception('Failed to set_sentry_mode off: ${responseBody['response']['reason']}');
    }
  } else {
    throw Exception('Failed to set_sentry_mode off: ${response.reasonPhrase}');
  }
}