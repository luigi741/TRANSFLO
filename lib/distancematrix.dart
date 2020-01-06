import 'package:flutter_dotenv/flutter_dotenv.dart';

class DistanceMatrix {
	final String apiURL = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&';
	String origins;
	String destinations;
	final String key = DotEnv().env['MAPS_API_KEY'];

	DistanceMatrix({
		apiURL,
		this.origins,
		this.destinations,
		key
	});

	getURL() {
		return apiURL;
	}
}