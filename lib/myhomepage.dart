import 'dart:convert';
import 'dart:core';
import 'dart:async';

import './stopsapi.dart';
import './distancematrix.dart';

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
	MapType _currentMapType = MapType.normal;
	Geolocator geolocator = Geolocator();
	Position userLocation;
	CameraUpdate cameraUpdate;
	StopsAPI responseAPI;
	CameraPosition cameraPosition = new CameraPosition(
		target: LatLng(40.387019, -105.668516),
		zoom: 5.0
	);
	
	// Make a POST request to the API to get truck stops
	makeHTTP() async {
		Position currLoc = await initialPosition();
		try {
			var myLatLong = {
				"lat": currLoc.latitude,
				"lng": currLoc.longitude
			};
			String newObj = jsonEncode(myLatLong);
			var response = await client.post(
				'http://webapp.transflodev.com/svc1.transflomobile.com/api/v3/stations/100',
				body: newObj,
				headers: {
					"Authorization": "Basic amNhdGFsYW5AdHJhbnNmbG8uY29tOnJMVGR6WmdVTVBYbytNaUp6RlIxTStjNmI1VUI4MnFYcEVKQzlhVnFWOEF5bUhaQzdIcjVZc3lUMitPTS9paU8=",
					"Content-Type": "application/json"
				}
			);
			print('Response status: ${response.statusCode}');

			List<StopsAPI> stopsList;
			var data = json.decode(response.body);
			var rest = data['truckStops'] as List;

			print('$rest\n\n');
			stopsList = rest.map<StopsAPI>((json) => StopsAPI.fromJson(json)).toList();
			
			updateMarkers(rest);
		} 
		catch (e) {
			print(e);
		}
	}

	// Update markers on map based of data fetched from API
	updateMarkers(List list) {
		print('updateMarkers()');
		for (int i = 0; i < list.length; i++) {
			print('Lat: ${list[i]['lat']} | Long: ${list[i]['lng']}');

			LatLng temp = new LatLng(double.parse(list[i]['lat']), double.parse(list[i]['lng']));

			setState(() {
				myMarkers.add(
					Marker(
						markerId: MarkerId('${list[i]['name']}'),
						icon: BitmapDescriptor.defaultMarker,
						position: temp,
						onTap: _showDialog,
						infoWindow: InfoWindow(
							title: '${list[i]['name']}',
							snippet: '${list[i]['rawLine1']}'
						),
					)
				);
			});
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

	void clearMarkers() {
		setState(() {
			myMarkers.clear();
		});
	}

	static void _showDialog() {
		print('Marker tapped!');
	}

	// List of markers that will show up on the map
	Set<Marker> myMarkers = Set.from([]);

	// Create an instance of a Google Map
	void _onMapCreated(controller) {
		setState(() {
			googleMapController = controller;
		});
	}

	// Bottom navigation bar tap even handler
	Future _onItemTapped(int index) async {
		switch (index) {
			case 0: 
				print('Home Tapped.');
				break;
			case 1:
				print('List Tapped.');
				getVisibleRegion();
				break;
			case 2:
				print('History Tapped.');
				Position myLocation = await userLatLong();
				DistanceMatrix distanceMatrixCall = new DistanceMatrix(
					origins: '${myLocation.latitude}|${myLocation.longitude}',
					destinations: '${myMarkers.first.position.latitude}|${myMarkers.first.position.latitude}'
				);
				print(distanceMatrixCall);
				break;
		}

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
	// Toggle map view e.g. Satellite or Street
	void _terrainButtonPressed() {
		print('_terrainButtonPressed()');
		setState(() {
			_currentMapType = _currentMapType == MapType.normal
				? MapType.satellite
				: MapType.normal;
		});
	}

	// When camera stops moving - use the callback to update markers
	void mapCameraIdle() {
		print('Map Camera is Idle!');
	}

	Future<LatLngBounds> getVisibleRegion() async {
		LatLngBounds latLngBounds = await googleMapController.getVisibleRegion();
		print(latLngBounds.northeast.toString());
		print(latLngBounds.southwest.toString());
		return latLngBounds;
	}

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
			body: Stack(
				children: <Widget>[
					GoogleMap(
						onMapCreated: _onMapCreated,
						initialCameraPosition: CameraPosition(
							target: _center,
							zoom: 11.0
						),
						markers: myMarkers,
						mapType: _currentMapType,
						myLocationButtonEnabled: true,
						myLocationEnabled: true,
						onCameraIdle: mapCameraIdle,
					),
					Column(
						mainAxisAlignment: MainAxisAlignment.end,
						children: <Widget>[
							Container(
								padding: EdgeInsets.only(left: 5.0),
								child: FloatingActionButton(
									mini: true,
									onPressed: clearMarkers,
									child: Icon(Icons.clear_all),
									backgroundColor: Colors.indigo
								),
							),
							Container(
								padding: EdgeInsets.only(left: 5.0),
								child: FloatingActionButton(
									mini: true,
									onPressed: _terrainButtonPressed,
									child: Icon(Icons.map),
									backgroundColor: Colors.indigo
								),
							),
							Container(
								padding: EdgeInsets.only(left: 5.0, bottom: 5.0),
								child: FloatingActionButton(
									mini: true,
									onPressed: checkLocationServices,
									child: Icon(Icons.zoom_out),
									backgroundColor: Colors.indigo
								),
							),
						],
					)
				],
			),
			bottomNavigationBar: BottomNavigationBar(
				items: <BottomNavigationBarItem>[
					BottomNavigationBarItem(
						icon: Icon(Icons.home),
						title: Text('Home')
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.list),
						title: Text('List'),
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.history),
						title: Text('History')
					)
				],
				onTap: _onItemTapped,
				currentIndex: _selectedIndex,
			)
		);
	}
}