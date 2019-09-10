import 'dart:convert';
import 'dart:core';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:location_permissions/location_permissions.dart';

class MyHomePage extends StatefulWidget {
	@override
	_MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	var client = http.Client();
	static const LatLng _center = const LatLng(27.918325, -82.341408);
	int _selectedIndex = 0;
	GoogleMapController googleMapController;
	Geolocator geolocator = Geolocator();
	Position userLocation;
	CameraUpdate cameraUpdate;
	CameraPosition cameraPosition = new CameraPosition(
		target: LatLng(40.387019, -105.668516),
		zoom: 5.0
	);
	
	// Make a POST request to the API to get truck stops
	makeHTTP() async {
		try {
			var myLatLong = {
				"lat": 27.918325,
				"lng": -82.341408
			};
			String newObj = jsonEncode(myLatLong);
			var response = await client.post(
				'http://webapp.transflodev.com/svc1.transflomobile.com/api/v3/stations/10',
				body: newObj,
				headers: {
					"Authorization": "Basic amNhdGFsYW5AdHJhbnNmbG8uY29tOnJMVGR6WmdVTVBYbytNaUp6RlIxTStjNmI1VUI4MnFYcEVKQzlhVnFWOEF5bUhaQzdIcjVZc3lUMitPTS9paU8=",
					"Content-Type": "application/json"
				}
			);
			print('Response status: ${response.statusCode}');
			print('Response body: ${response.body}');
		} 
		catch (e) {
			print(e);
		}
	}

	// Use geolocation to get initial position upon app startup
	Future<Position> initialPosition() async {
		Position currentLocation;
		try {
			currentLocation = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
		}
		catch(e) {
			print(e);
			currentLocation = null;
		}
		print(currentLocation);
		getMyLocation(currentLocation.latitude, currentLocation.longitude);
		return currentLocation;
	}

	// Get user's location
	getMyLocation(double lat, double long) {
		print('getMyLocation()');
		googleMapController.animateCamera(CameraUpdate.newCameraPosition(
			CameraPosition(
				target: LatLng(lat, long),
				zoom: 15.0
			)
		));
	}

	// List of markers that will show up on the map
	Set<Marker> myMarkers = Set.from([
		Marker(
			markerId: MarkerId('myLocation'),
			icon: BitmapDescriptor.defaultMarker,
			position: _center
		)
	]);

	// Create an instance of a Google Map
	void _onMapCreated(controller) {
		setState(() {
			googleMapController = controller;
		});
	}

	// Bottom navigation bar
	void _onItemTapped(int index) {
		setState(() {
			_selectedIndex = index;
		});
	}

	// Reset camera to the initial position
	resetCamera() {
		print('resetCamera()');
		googleMapController.animateCamera(CameraUpdate.newCameraPosition(
			CameraPosition(
				target: LatLng(40.387019, -105.668516),
				zoom: 15.0
			)
		));
	}

	// Get user's coordinates
	Future<Position> userLatLong() async {
		Position myLatLong;
		try {
			myLatLong = await geolocator.getCurrentPosition(
				desiredAccuracy: LocationAccuracy.best
			);
		}
		catch(e) {
			print(e);
			myLatLong = null;
		}
		return myLatLong;
	}

	// Calculate 100-mile radius in degrees lat and long
	// 1 deg. lat/long = ~69 miles => 1.45 deg. ~= 100 miles
	// Radius ~= 0.725 | Diameter ~= 1.450
	// 35.3553
	checkLocationServices() async {
		ServiceStatus serviceStatus = await checkServiceStatus();

		if (serviceStatus == ServiceStatus.disabled) {
			print('Location services are currently disabled! Opening app settings...');
			openAppSettings();
		}
		else {
			print('Location services are enabled!');
			Position position = await userLatLong();
			print(position);

			double deltaL = 0.72464;

			double latNE = position.latitude + deltaL;
			double lngNE = position.longitude + deltaL;

			double latSW = position.latitude - deltaL;
			double lngSW = position.longitude - deltaL;

			print('NE Coordinates => Lat: $latNE | Long: $lngNE');
			print('SW Coordinates => Lat: $latSW | Long: $lngSW');

			// deltaL = 0.72464
			// NE => - deltaL latitude | + deltaL longitude
			// SW => + deltaL latitude | - deltaL longitude

			LatLng boundNE = new LatLng(latNE, lngNE);
			LatLng boundSW = new LatLng(latSW, lngSW);

			googleMapController.animateCamera(
				CameraUpdate.newLatLngBounds(LatLngBounds(northeast: boundNE, southwest: boundSW), 0)
			);
		}
	}
	//==============================================================================================
	// Location services and permissions

	// If location services are turned off, then request to be turned on and
	// open app settings
	Future<bool> openAppSettings() async {
		bool isOpened = await LocationPermissions().openAppSettings();
		return isOpened;
	}

	checkLocServices() async {
		PermissionStatus serviceStatus = await LocationPermissions().checkPermissionStatus();
		return serviceStatus;
	}

	turnOnLocations() async {
		bool isShown = await LocationPermissions().shouldShowRequestPermissionRationale();
		return isShown;
	}

	checkServiceStatus() async {
		ServiceStatus serviceStatus = await LocationPermissions().checkServiceStatus();
		return serviceStatus;
	}
	//==============================================================================================

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('TRANSFLO'),
				actions: <Widget>[
					IconButton(
						onPressed: initialPosition,
						icon: Icon(Icons.my_location),
						alignment: Alignment.center,
					),
					IconButton(
						onPressed: resetCamera,
						icon: Icon(Icons.add_location),
						alignment: Alignment.center,
					),
					IconButton(
						onPressed: makeHTTP,
						icon: Icon(Icons.search),
						alignment: Alignment.center,
					)
				],
			),
			body: GoogleMap(
				onMapCreated: _onMapCreated,
				initialCameraPosition: CameraPosition(
					target: _center,
					zoom: 11.0
				),
				/*cameraTargetBounds: CameraTargetBounds(
					LatLngBounds(
						southwest: LatLng(21.0, 31.0),
						northeast: LatLng()
					)
				),*/
				markers: myMarkers
			),
			bottomNavigationBar: BottomNavigationBar(
				items: <BottomNavigationBarItem>[
					BottomNavigationBarItem(
						icon: Icon(Icons.home),
						title: Text('Home')
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.list),
						title: Text('List')
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.history),
						title: Text('History')
					)
				],
				onTap: _onItemTapped,
				currentIndex: _selectedIndex,
			),
			floatingActionButton: FloatingActionButton(
				onPressed: checkLocationServices,
				child: Icon(Icons.add),
				backgroundColor: Colors.indigo,
			),
		);
	}
}