import 'package:FasterBusiness/classes/mService.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';

class Mlocation {
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Mlocation();
  Future grantPermission() async {
    print('Location');
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }
    if (_permissionGranted != PermissionStatus.granted) return;
    if (_permissionGranted == PermissionStatus.granted) {
      await serviceEnable();
    }
  }

  Future serviceEnable() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }
    if (_serviceEnabled) {
      await getLocation();
      Mservice.userLocation = _locationData;
    }
  }

  Future getLocation() async {
    try {
      _locationData = await location.getLocation();
      print('lat: ${_locationData.latitude}\nlong: ${_locationData.longitude}');
    } catch (e) {
      print('try again');
    }
  }

  /* Future grantPermission() async {
    try {
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted == PermissionStatus.granted) {
          print('hi to location');
        }
      }
    } catch (e) {}
  }

  Future<bool> serviceEnable(context) async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      return true;
    }
  }

  Future<LocationData> getLocation() async {
    try {
      _locationData = await location.getLocation();
      print('lat: ${_locationData.latitude}\nlong: ${_locationData.longitude}');
      return _locationData;
    } catch (e) {
      print('try again');
    }
  } */
}
