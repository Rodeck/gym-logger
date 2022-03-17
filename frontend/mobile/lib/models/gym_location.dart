import 'dart:convert';

class GymLocation {
  final String name;
  final DateTime createdDate;
  final double lattitude;
  final double longitude;

  GymLocation(this.name, this.lattitude, this.longitude, this.createdDate);

  GymLocation.fromJson(Map<String, dynamic> json)
      : createdDate = DateTime.parse(json['createdDate']),
        longitude = double.parse(json['longitude']),
        name = json['name'],
        lattitude = double.parse(json['latitude']);

  static List<GymLocation> parseGyms(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed
        .map<GymLocation>((json) => GymLocation.fromJson(json))
        .toList();
  }
}
