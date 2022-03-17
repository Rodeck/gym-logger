import 'dart:convert';

class Visit {
  final DateTime date;
  final double lattitude;
  final double longitude;
  final String gymName;
  final String id;

  Visit(this.date, this.lattitude, this.longitude, this.gymName, this.id);

  Visit.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json['date']),
        longitude = double.parse(json['longitude']),
        lattitude = double.parse(json['latitude']),
        id = json['_id'],
        gymName = json['gymName'];

  Map<String, dynamic> toJson() => {
        'longitude': date,
        'lattitude': lattitude,
        'date': longitude,
      };

  static List<Visit> parseVisits(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Visit>((json) => Visit.fromJson(json)).toList();
  }
}
