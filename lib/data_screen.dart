import 'package:flutter/material.dart';
import 'tesla_service.dart';



class NewScreen extends StatelessWidget {
  final String accessToken;

  NewScreen({required this.accessToken});

  Future<Map<String, dynamic>> userDetails() async {
    Map<String, dynamic> userDetails = await getUserDetails(accessToken);
    return userDetails;
  }

  Future<String> vehicleDetails() async {
    Map<String, dynamic> vehicle = await getVehicles(accessToken);
    return vehicle['id'].toString();
  }

  /*

  @override
  Widget build(BuildContext context) {
    final user = userDetails();
    final vehicle = vehicleDetails();
    return Scaffold(
      appBar: AppBar(
        title: Text('Tessy Whisperer'),
      ),
      body: Center(
        child: Text('Access Token is $accessToken , User is $user , Vehicle id is $vehicle'),
      ),
    );
  }

   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tessy Whisperer'),
      ),
      body: FutureBuilder(
        future: Future.wait([userDetails(), vehicleDetails()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            final user = snapshot.data![0];
            final vehicle = snapshot.data![1];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'User: $user\nVehicle ID: $vehicle',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        print('Car image tapped!'); // Replace this with your method
                      },
                      child: Image.network(
                        'https://www.vhv.rs/dpng/d/615-6151527_tesla-roadster-clipart-ferrari-458-hd-png-download.png', // Replace with your image URL
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
