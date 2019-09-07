import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomePage extends StatefulWidget {
	@override
	_MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	Completer<GoogleMapController> _completer = Completer();
	static const LatLng _center = const LatLng(27.918325, -82.341408);

	void _onMapCreated(GoogleMapController mapController) {
		_completer.complete(mapController);
	}

	Set<Marker> myMarkers = Set.from([
		Marker(
			markerId: MarkerId('myLocation'),
			icon: BitmapDescriptor.defaultMarker,
			position: _center
		)
	]);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('TransFLO'),
			),
			body: GoogleMap(
				onMapCreated: _onMapCreated,
				initialCameraPosition: CameraPosition(
					target: _center,
					zoom: 11.0
				),
				markers: myMarkers
			),
		);
	}
}