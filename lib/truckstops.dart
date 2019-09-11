class TruckStops {
	String name;
	String city;
	String state;
	String country;
	String zip;
	String lat;
	String lng;
	String rawLine1;
	String rawLine2;
	String rawLine3;

	TruckStops({
		this.name,
		this.city,
		this.state,
		this.country,
		this.zip,
		this.lat,
		this.lng,
		this.rawLine1,
		this.rawLine2,
		this.rawLine3
	});

	TruckStops.fromJson(Map<String, dynamic> json) {
		name = json['name'];
		city = json['city'];
		state = json['state'];
		country = json['country'];
		zip = json['zip'];
		lat = json['lat'];
		lng = json['lng'];
		rawLine1 = json['rawLine1'];
		rawLine2 = json['rawLine2'];
		rawLine3 = json['rawLine3'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['name'] = this.name;
		data['city'] = this.city;
		data['state'] = this.state;
		data['country'] = this.country;
		data['zip'] = this.zip;
		data['lat'] = this.lat;
		data['lng'] = this.lng;
		data['rawLine1'] = this.rawLine1;
		data['rawLine2'] = this.rawLine2;
		data['rawLine3'] = this.rawLine3;
		return data;
	}
}