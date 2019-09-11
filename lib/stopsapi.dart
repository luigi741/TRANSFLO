import 'truckstops.dart';

class StopsAPI {
	List<TruckStops> truckStops;

	StopsAPI({this.truckStops});

	StopsAPI.fromJson(Map<String, dynamic> json) {
		if (json['truckStops'] != null) {
			truckStops = new List<TruckStops>();
			json['truckStops'].forEach((v) {
				truckStops.add(new TruckStops.fromJson(v));
			});
		}
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.truckStops != null) {
			data['truckStops'] = this.truckStops.map((v) => v.toJson()).toList();
		}
		return data;
	}
}