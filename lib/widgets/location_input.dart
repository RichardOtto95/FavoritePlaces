import 'dart:convert';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onPickLocation});

  final void Function(PlaceLocation location) onPickLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;

  var _isGettingLocation = false;

  String get locationImage {
    if (_pickedLocation == null) {
      return "";
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return "https://maps.googleapis.com/maps/api/staticmap?"
        "center=$lat,$lng&size=600x300&zoom=14"
        "&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794"
        "&markers=color:red%7Clabel:A%7C$lat,$lng"
        "&key=AIzaSyA6XZLzc7dHFZn2GpLTpEk8wtDXn4_iZ5w";
  }

  void _savePlace(double latitude, longitude) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyA6XZLzc7dHFZn2GpLTpEk8wtDXn4_iZ5w",
    );

    final response = await http.get(url);

    final resData = json.decode(response.body);

    final address = resData["results"][0]["formatted_address"];

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      widget.onPickLocation(_pickedLocation!);
      _isGettingLocation = false;
    });
  }

  void _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    _savePlace(lat, lng);
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );

    if (pickedLocation == null) return;

    setState(() {
      _isGettingLocation = true;
    });

    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(.2),
            ),
          ),
          child: _pickedLocation != null
              ? Image.network(
                  locationImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : _isGettingLocation
                  ? const CircularProgressIndicator()
                  : Text(
                      "No location chosen",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              onPressed: _getCurrentLocation,
              label: const Text("Get Current Location"),
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              onPressed: _selectOnMap,
              label: const Text("Select on map"),
            ),
          ],
        ),
      ],
    );
  }
}
