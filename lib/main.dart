import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}

enum AppState {
  choosingLocation,
  confirmingFare,
  waitingForPickup,
  riding,
  postRide
}

enum RideStatus { pickingUp, riding, completed }

class Ride {
  final String id;
  final String driverId;
  final String passengerId;
  final int fare;
  final RideStatus status;

  Ride(
      {required this.id,
      required this.driverId,
      required this.passengerId,
      required this.fare,
      required this.status});

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
        id: json['id'],
        driverId: json['driver_id'],
        passengerId: json['passenger_id'],
        fare: json['fare'],
        status: RideStatus.values
            .firstWhere((e) => e.toString().split('.').last == json['status']));
  }
}

class Driver {
  final String id;
  final String model;
  final String number;
  final bool isAvailable;
  final LatLng location;

  Driver(
      {required this.id,
      required this.model,
      required this.number,
      required this.isAvailable,
      required this.location});

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      model: json['model'],
      number: json['number'],
      isAvailable: json['is_available'],
      location: LatLng(json['latitude'], json['longitude']),
    );
  }
}
