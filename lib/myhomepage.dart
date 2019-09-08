import 'dart:core';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
	@override
	_MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	GoogleMapController googleMapController;
	Geolocator geolocator = Geolocator();
	Position userLocation;
	CameraUpdate cameraUpdate;
	CameraPosition cameraPosition = new CameraPosition(
		target: LatLng(40.387019, -105.668516),
		zoom: 5.0
	);

	static const LatLng _center = const LatLng(27.918325, -82.341408);
	
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

	getMyLocation(double lat, double long) {
		print('getMyLocation()');
		googleMapController.animateCamera(CameraUpdate.newCameraPosition(
			CameraPosition(
				target: LatLng(lat, long),
				zoom: 15.0
			)
		));
	}

	Set<Marker> myMarkers = Set.from([
		Marker(
			markerId: MarkerId('myLocation'),
			icon: BitmapDescriptor.defaultMarker,
			position: _center
		)
	]);

	void _onMapCreated(controller) {
		setState(() {
			googleMapController = controller;
		});
	}

	int _selectedIndex = 0;

	void _onItemTapped(int index) {
		setState(() {
			_selectedIndex = index;
		});
	}

	resetCamera() {
		print('resetCamera()');
		googleMapController.animateCamera(CameraUpdate.newCameraPosition(
			CameraPosition(
				target: LatLng(40.387019, -105.668516),
				zoom: 15.0
			)
		));
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
						onPressed: () {},
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
		);
	}
}